# Project-local Maven repository

This directory will replace `.gradle-offline/caches/modules-2` as the
versioned source of Gradle plugins and dependencies needed for offline builds.
It uses the standard Maven layout:

```text
offline-maven/<group path>/<artifact>/<version>/<artifact>-<version>.<extension>
```

For every resolved component, commit the artifact (`.jar` or `.aar`) and its
dependency metadata (`.pom` and, when published, `.module`). Metadata is
required to resolve transitive dependencies and Gradle plugin markers; copying
only JAR/AAR files is not sufficient.

The offline build path sets `offlineMavenOnly=true`, so Gradle sees only this
repository. Google Maven, Maven Central, and the Gradle Plugin Portal remain
available only for deliberate online dependency refreshes.

To verify that this directory is complete, run:

```bash
./build-from-local-maven.sh --no-daemon
```

That command must run with `--offline` and sees only this directory. The normal
`./gradlew assembleDebug --offline --stacktrace` command uses the same mode.

The Gradle distribution, JDK, and Android SDK are not Maven artifacts and
remain in their existing project-local bundle directories.
