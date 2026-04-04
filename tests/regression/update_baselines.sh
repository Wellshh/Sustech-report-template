#!/usr/bin/env bash
# Regenerate visual regression baselines from current compiled output.
#
# Run this script INTENTIONALLY after reviewing visual output when:
#   - A new test is added to the regression suite
#   - A deliberate visual change has been made to the template
#
# After running, commit the updated baselines in tests/regression/baselines/.
#
# Usage: bash tests/regression/update_baselines.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
source "${ROOT}/tests/lib/common.sh"
reset_counters

BASELINES_DIR="${ROOT}/tests/regression/baselines"
mkdir -p "$BASELINES_DIR"

# Keep this list in sync with run_regression.sh::REGRESSION_TESTS
REGRESSION_TESTS=(
  "tests/unit/titlepage/test_tp_simple_single.tex"
  "tests/unit/titlepage/test_tp_formal_single.tex"
  "tests/unit/titlepage/test_tp_formal_credit_only.tex"
  "tests/unit/titlepage/test_tp_formal_contrib_only.tex"
  "tests/unit/visual/test_vis_note_boxes.tex"
  "tests/unit/visual/test_vis_table_styles.tex"
  "tests/unit/visual/test_vis_lists.tex"
  "tests/unit/code/test_code_listings_basic.tex"
  "tests/unit/diagrams/test_diag_pipeline.tex"
  "tests/unit/diagrams/test_diag_engineering.tex"
  "tests/integration/backends/test_int_backend_listings.tex"
)

echo "Compiling baseline PDFs..."
compiled=0
failed=0
for tex in "${REGRESSION_TESTS[@]}"; do
  stem=$(basename "${tex%.tex}")
  echo "  -- ${tex}"
  if compile_test "$tex" >/dev/null 2>&1; then
    src="${BUILD_DIR}/${stem}.pdf"
    if [[ -f "$src" ]]; then
      cp "$src" "${BASELINES_DIR}/${stem}.pdf"
      echo "  Saved baseline: ${stem}.pdf"
      compiled=$((compiled + 1))
    else
      echo "  WARN: compiled but PDF not found: ${src}" >&2
      failed=$((failed + 1))
    fi
  else
    echo "  FAIL: could not compile ${tex}" >&2
    failed=$((failed + 1))
  fi
done

echo ""
echo "Baselines updated: ${compiled} PDF(s) written to tests/regression/baselines/"
[[ $failed -gt 0 ]] && echo "Failures: ${failed}" >&2

echo ""
echo "Review the PDFs, then commit:"
echo "  git add tests/regression/baselines/"
echo "  git commit -m 'chore(tests): update visual regression baselines'"

[[ $failed -eq 0 ]]
