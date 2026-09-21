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

`settings.gradle.kts` always checks this repository first. During migration it
can fall back to Google Maven, Maven Central, and the Gradle Plugin Portal.

To verify that this directory is complete, run:

```bash
./build-from-local-maven.sh --no-daemon
```

That command sets `offlineMavenOnly=true`, so Gradle sees only this directory
and must also run with `--offline`. Once it succeeds in a clean clone with an
empty Gradle user home, `.gradle-offline/caches/modules-2` can be removed from
version control.

The Gradle distribution, JDK, and Android SDK are not Maven artifacts and
remain in their existing project-local bundle directories.
