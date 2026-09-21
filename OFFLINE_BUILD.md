# Offline Android build bundle

Run this project without network access on **macOS Apple Silicon**:

```bash
./build-offline.sh
```

The script uses only project-local components:

- `.gradle-offline/wrapper/dists`: Gradle 9.2.1 distribution
- `.gradle-offline/caches/modules-2`: resolved plugins and Maven/Google artifacts, with metadata
- `.gradle-offline/jdks`: Eclipse Temurin Java 21 for macOS Apple Silicon
- `.android-sdk/platforms/android-36.1`: Android API 36.1 platform required by `minorApiLevel = 1`
- `.android-sdk/build-tools/36.0.0`: Android Build Tools 36.0.0

Do not use `local.properties` for this workflow: it contains a machine-specific SDK path and remains ignored by Git.

The included JDK and Android SDK are platform-specific. Build a separate bundle from a machine of each required OS/CPU architecture before expecting offline builds there.

GitHub's normal Git service rejects individual files larger than 100 MB. The Java runtime image is consequently stored as 64 MiB chunks under `modules.parts`. `build-offline.sh` restores and verifies it automatically on the first build.
