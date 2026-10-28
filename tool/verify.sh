#!/usr/bin/env bash
# Runs every quality gate: format, analyze, tests and 100% line coverage.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get >/dev/null
dart format --output=none --set-exit-if-changed --line-length 200 lib test tool
flutter analyze
flutter test --coverage --exclude-tags golden,perf
dart run tool/check_coverage.dart 100
