#!/usr/bin/env bash
# Verifies that all Gradle plugins and dependencies are supplied by
# ./offline-maven, without falling back to Google, Maven Central, or the
# Gradle Plugin Portal.
set -euo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"

exec "$project_dir/build-offline.sh" -PofflineMavenOnly=true "$@"
