#!/usr/bin/env bash
# Timing checks on 10k transactions (excluded from CI: depends on the machine).
set -euo pipefail
cd "$(dirname "$0")/.."
flutter test --tags perf test/perf
