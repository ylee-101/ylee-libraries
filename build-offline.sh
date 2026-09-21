#!/usr/bin/env bash
# Builds this project without contacting a remote repository.
set -euo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
offline_home="$project_dir/.gradle-offline"
sdk_dir="$project_dir/.android-sdk"
jdk_home="$offline_home/jdks/eclipse_adoptium-21-aarch64-os_x.2/jdk-21.0.7+6/Contents/Home"
jdk_lib_dir="$jdk_home/lib"
jdk_modules="$jdk_lib_dir/modules"
jdk_modules_parts="$jdk_lib_dir/modules.parts"
jdk_modules_checksum="$jdk_lib_dir/modules.sha256"

if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
  echo "This offline bundle contains a macOS Apple Silicon JDK and Android SDK." >&2
  echo "Use a platform-matched offline bundle on this machine." >&2
  exit 1
fi

for required_path in "$offline_home" "$sdk_dir" "$jdk_home"; do
  if [[ ! -d "$required_path" ]]; then
    echo "Missing offline build component: $required_path" >&2
    exit 1
  fi
done

if [[ ! -f "$jdk_modules_checksum" ]]; then
  echo "Missing offline build checksum: $jdk_modules_checksum" >&2
  exit 1
fi

# GitHub rejects individual files over 100 MB. The Java runtime image is
# therefore versioned as 64 MiB chunks and restored locally before Gradle runs.
if [[ ! -f "$jdk_modules" ]]; then
  if [[ ! -d "$jdk_modules_parts" ]]; then
    echo "Missing offline Java runtime chunks: $jdk_modules_parts" >&2
    exit 1
  fi
  temporary_modules="$jdk_modules.tmp"
  rm -f "$temporary_modules"
  for part in "$jdk_modules_parts"/modules.part-*; do
    [[ -f "$part" ]] || continue
    cat "$part" >> "$temporary_modules"
  done
  mv "$temporary_modules" "$jdk_modules"
fi

if ! (cd "$jdk_lib_dir" && shasum -a 256 -c "$(basename "$jdk_modules_checksum")"); then
  rm -f "$jdk_modules"
  echo "The offline Java runtime image failed checksum verification." >&2
  exit 1
fi

export GRADLE_USER_HOME="$offline_home"
export ANDROID_SDK_ROOT="$sdk_dir"
export ANDROID_HOME="$sdk_dir"
export JAVA_HOME="$jdk_home"
export PATH="$JAVA_HOME/bin:$PATH"
export OFFLINE_BUNDLE_ACTIVE=1

exec "$project_dir/gradlew" assembleDebug --offline --stacktrace -PofflineMavenOnly=true "$@"
