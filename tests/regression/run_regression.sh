#!/usr/bin/env bash
# Visual regression runner — compiles selected stable tests and diffs against baselines.
#
# Usage:
#   bash tests/regression/run_regression.sh           # WARN on visual diff (default)
#   bash tests/regression/run_regression.sh --strict  # FAIL on visual diff
#
# Prerequisites:
#   - Baselines must already exist in tests/regression/baselines/
#     Run tests/regression/update_baselines.sh once to seed them.
#   - diff-pdf must be installed: brew install diff-pdf (macOS)
#                                 or build from https://vslavik.github.io/diff-pdf/
#
# Diff images (when differences are detected) land in tests/regression/diffs/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
source "${ROOT}/tests/lib/common.sh"
reset_counters

STRICT=0
for arg in "$@"; do
  [[ "$arg" == "--strict" ]] && STRICT=1
done

BASELINES_DIR="${ROOT}/tests/regression/baselines"
CURRENT_DIR="${ROOT}/tests/regression/current"
mkdir -p "$CURRENT_DIR" "${ROOT}/tests/regression/diffs"

# ---------------------------------------------------------------------------
# Stable tests selected for visual regression.
# Criteria: no \today, no dynamic content — output is deterministic per machine.
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Compile + visual diff loop
# ---------------------------------------------------------------------------
log_section "Regression: compile"
for tex in "${REGRESSION_TESTS[@]}"; do
  compile_test "$tex" || _SUSTECH_FAILED=$((_SUSTECH_FAILED + 1))
done

log_section "Regression: visual diff"
for tex in "${REGRESSION_TESTS[@]}"; do
  local_stem=$(basename "${tex%.tex}")
  current_pdf="${BUILD_DIR}/${local_stem}.pdf"
  baseline_pdf="${BASELINES_DIR}/${local_stem}.pdf"

  # Copy current PDF to the dedicated current/ directory for archiving
  if [[ -f "$current_pdf" ]]; then
    cp "$current_pdf" "${CURRENT_DIR}/${local_stem}.pdf"
  fi

  if [[ $STRICT -eq 1 ]]; then
    assert_pdf_visual "$baseline_pdf" "$current_pdf" --strict
  else
    assert_pdf_visual "$baseline_pdf" "$current_pdf"
  fi
done

print_summary "Regression Tests"
