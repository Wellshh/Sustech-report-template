#!/usr/bin/env bash
# Acceptance test runner — validates release-facing example documents.
# Run from repository root: bash tests/acceptance/run_acceptance.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
source "${ROOT}/tests/lib/common.sh"
reset_counters

run_acceptance_case() {
  local tex="$1"
  local stem
  stem=$(basename "${tex%.tex}")
  local pdf="${BUILD_DIR}/${stem}.pdf"

  if compile_test "$tex"; then
    case "$stem" in
      minimal-homework)
        assert_pdf_contains "$pdf" \
          "Minimal Homework Example" \
          "Example Student" \
          "Introduction to Engineering Computing" \
          "9.81"
        ;;
      project-report)
        assert_pdf_contains "$pdf" \
          "Project Report Example" \
          "Alice Example" \
          "Bob Example" \
          "Feedback Control of Dynamic Systems" \
          "Controller performance comparison"
        assert_pdf_lacks "$pdf" "??"
        ;;
      example)
        assert_pdf_contains "$pdf" \
          "Modernized Template Smoke Test" \
          "模板冒烟测试" \
          "A Mathematical Theory of Communication" \
          "CRediT-style Contributions"
        assert_pdf_lacks "$pdf" "??"
        ;;
      *)
        : # compile-only fallback
        ;;
    esac
  else
    _SUSTECH_FAILED=$((_SUSTECH_FAILED + 1))
  fi
}

log_section "acceptance / examples"
run_acceptance_case "${ROOT}/examples/minimal-homework.tex"
run_acceptance_case "${ROOT}/examples/project-report.tex"

log_section "acceptance / smoke"
run_acceptance_case "${ROOT}/example.tex"

print_summary "Acceptance Tests"
