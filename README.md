# Offline Android build

This branch (`without-cache`) builds the debug APK without network access after
the repository has been cloned. Dependencies are versioned in
[`offline-maven/`](offline-maven/) as normal Maven artifacts and metadata;
Gradle's `modules-2` cache is not part of the source of truth.

## Supported environment

The bundled JDK and Android SDK are for **macOS on Apple Silicon (`arm64`)**.
No system Java or Android SDK installation is required on that platform. The
offline entrypoint uses the project JDK 21 and project Android SDK.

Intel macOS, Windows, and Linux need a matching JDK/SDK bundle or a separately
adapted build script; this branch intentionally stops early on those platforms.

## Clone while online

Cloning is the only network-dependent step. Run it before moving to an
offline machine or disabling the network.

```bash
git clone --branch without-cache git@github.com:ylee-101/ylee-libraries.git
cd ylee-libraries
```

## Build while offline

Disconnect from the network, then run the normal Gradle command:

```bash
./gradlew assembleDebug --offline --stacktrace
```

The wrapper delegates to `build-offline.sh`, which:

1. Restores the bundled Java runtime image from its Git-tracked split files on
   the first run and verifies its SHA-256 checksum.
2. Uses project-local JDK 21, Android SDK, Gradle distribution, and Gradle user
   home.
3. Enables `offlineMavenOnly`, so Gradle resolves only
   [`offline-maven/`](offline-maven/) and cannot fall back to Google Maven,
   Maven Central, or the Gradle Plugin Portal.

A successful build ends with `BUILD SUCCESSFUL`. The APK is written to:

```text
app/build/outputs/apk/debug/app-debug.apk
```

## Strict local-repository verification

To explicitly run the local-Maven-only entrypoint, for example after updating
dependencies, use:

```bash
./build-from-local-maven.sh --no-daemon --rerun-tasks
```

It must also finish with `BUILD SUCCESSFUL`. `--rerun-tasks` is useful for
confirming that existing build outputs did not hide a missing dependency.

## What is versioned

- `offline-maven/`: required JAR/AAR artifacts, POMs, and Gradle `.module`
  metadata for plugins and application dependencies.
- `.gradle-offline/wrapper/`: Gradle 9.2.1 distribution.
- `.gradle-offline/jdks/`: bundled macOS Apple Silicon JDK 21. Its `lib/modules`
  runtime file is reconstructed locally from split parts because GitHub rejects
  individual files above 100MB.
- `.android-sdk/`: Android platform 36.1, build-tools 36.0.0, and platform
  tools required by this project.

Generated Gradle caches, daemon data, reconstructed runtime files, locks, and
`app/build/` outputs are intentionally ignored. Do not add them to Git.

## Troubleshooting

- **"This offline bundle contains a macOS Apple Silicon JDK and Android SDK"**
  means the current machine is not macOS `arm64`. Use a platform-matched bundle
  or adapt the scripts and verify the build again.
- **"Missing offline build component"** means the clone is incomplete or the
  project bundle was removed. Re-clone the `without-cache` branch while online.
- **A missing Maven coordinate or artifact** means `offline-maven/` is
  incomplete for a dependency change. Do not copy a Gradle cache into Git;
  fetch the missing artifact plus its POM/`.module` metadata from the
  authoritative repository, then repeat strict local-repository verification.
