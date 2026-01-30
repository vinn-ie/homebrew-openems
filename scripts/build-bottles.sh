#!/bin/bash
# Build bottles for all formulas in this tap

set -e

VERSION="${1:-v1.0}"
OUTPUT_DIR="${2:-./bottles}"
TAP_PATH="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Building bottles for release $VERSION ==="
echo "Output directory: $OUTPUT_DIR"
echo "Tap path: $TAP_PATH"
echo ""

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Uninstall existing versions
echo "=== Cleaning up existing installations ==="
brew uninstall openems appcsxcad qcsxcad csxcad fparser 2>/dev/null || true

# Tap from local path
echo "=== Tapping from local path ==="
brew tap vincentfree/openems "$TAP_PATH" 2>/dev/null || true

# Build bottles in dependency order
FORMULAS="fparser csxcad qcsxcad appcsxcad openems"

for formula in $FORMULAS; do
    echo ""
    echo "=== Building bottle for $formula ==="
    brew install --build-bottle "vincentfree/openems/$formula"
    brew bottle --json --root-url "https://github.com/vincentfree/homebrew-openems/releases/download/$VERSION" "vincentfree/openems/$formula"
done

echo ""
echo "=== Done! ==="
echo "Bottles created in: $OUTPUT_DIR"
ls -la *.bottle.tar.gz 2>/dev/null || echo "No bottles found"
echo ""
echo "Next steps:"
echo "1. Create GitHub release '$VERSION' at:"
echo "   https://github.com/vincentfree/homebrew-openems/releases/new"
echo ""
echo "2. Upload all .bottle.tar.gz files to that release"
echo ""
echo "3. Add bottle blocks to each formula using the SHA256 from the .json files:"
cat <<'EOF'

   bottle do
     root_url "https://github.com/vincentfree/homebrew-openems/releases/download/v1.0"
     sha256 cellar: :any, arm64_sequoia: "SHA_FROM_JSON"
     sha256 cellar: :any, arm64_tahoe:   "SHA_FROM_JSON"
   end

EOF
echo "4. Run this script on your other Mac (Tahoe) and combine the SHAs"
