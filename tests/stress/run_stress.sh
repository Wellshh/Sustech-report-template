#!/usr/bin/env bash
# Stress / edge-case test runner.
# These tests verify graceful handling of unusual inputs, not visual correctness.
# Run from repository root: bash tests/stress/run_stress.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
source "${ROOT}/tests/lib/common.sh"
reset_counters

# ---------------------------------------------------------------------------
# Per-stem assertion dispatch
# ---------------------------------------------------------------------------
run_assertions() {
  local stem="$1"
  local pdf="$2"

  case "$stem" in

    test_stress_special_chars)
      # Verify that special characters in body did not abort compilation
      # and that basic text fragments survive to the PDF.
      assert_pdf_contains "$pdf" "Special" "STRESS001"
      ;;

    test_stress_long_title)
      # Verify the long title compiles and some text lands in the PDF.
      assert_pdf_contains "$pdf" "STRESS002"
      ;;

    test_stress_invalid_opts)
      # Class must fall back gracefully, not abort.
      assert_pdf_contains "$pdf" "Fallback paths exercised"
      ;;

    *)
      : # compile-only for unknown stems
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Run all stress subdirectories
# ---------------------------------------------------------------------------
run_module() {
  local module="$1"
  local dir="${ROOT}/tests/stress/${module}"
  log_section "stress / ${module}"
  shopt -s nullglob
  for tex in "${dir}"/test_*.tex; do
    local stem
    stem=$(basename "${tex%.tex}")
    if compile_test "$tex"; then
      run_assertions "$stem" "${BUILD_DIR}/${stem}.pdf"
    else
      _SUSTECH_FAILED=$((_SUSTECH_FAILED + 1))
    fi
  done
}

run_module "edge-cases"

print_summary "Stress Tests"
