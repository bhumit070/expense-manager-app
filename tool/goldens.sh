#!/usr/bin/env bash
# Golden (screenshot) tests for key screens in light and dark.
# They are excluded from CI because text rendering differs between platforms;
# the committed images were generated on macOS.
#
#   tool/goldens.sh           compare against test/goldens/*.png
#   tool/goldens.sh --update  regenerate the images after an intended UI change
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${1:-}" == "--update" ]]; then
  flutter test --tags golden --update-goldens test/goldens
else
  flutter test --tags golden test/goldens
fi
