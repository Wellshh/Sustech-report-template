#!/usr/bin/env bash
# Integration test runner — tests combining multiple features together.
# Run from repository root: bash tests/integration/run_integration.sh
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

    test_int_ma_3authors)
      assert_pdf_contains "$pdf" \
        "UniqueAlice" "UniqueBob" "UniqueCarol" \
        "10001" \
        "CRediT-style Contributions" \
        "Contribution Summary" \
        "et al."
      ;;

    test_int_ma_5authors)
      assert_pdf_contains "$pdf" \
        "Author One" "Author Two" "Author Three" \
        "Author Four" "Author Five" \
        "20001" \
        "et al."
      ;;

    test_int_theme_sustech)
      assert_pdf_contains "$pdf" \
        "UniqueThemeSUSTechNote901" \
        "UniqueThemeSUSTechWarn902" \
        "UniqueThemeCode903" \
        "UniqueThemeTable904"
      ;;

    test_int_theme_light)
      assert_pdf_contains "$pdf" \
        "UniqueThemeLightNote911" \
        "UniqueThemeLightWarn912" \
        "UniqueThemeLightCode913" \
        "UniqueThemeLightTable914"
      ;;

    test_int_backend_listings)
      assert_pdf_contains "$pdf" \
        "UniqueIntClass401" \
        "UniqueIntJson402" \
        "UniqueIntShell403" \
        "UniqueIntInline404" \
        "UniqueIntNote405"
      ;;

    minimal-homework)
      assert_pdf_contains "$pdf" \
        "Minimal Homework Example" \
        "Introduction to Engineering Computing" \
        "9.81" \
        "Minimal code example"
      ;;

    project-report)
      assert_pdf_contains "$pdf" \
        "Project Report Example" \
        "Embedded Systems Design" \
        "Controller performance comparison" \
        "Feedback Control of Dynamic Systems" \
        "CTAN Team"
      assert_pdf_lacks "$pdf" "??"
      ;;

    *)
      : # compile-only check for unknown stems
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Run all integration subdirectories
# ---------------------------------------------------------------------------
run_module() {
  local module="$1"
  local dir="${ROOT}/tests/integration/${module}"
  log_section "integration / ${module}"
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

run_module "multi-author"
run_module "themes"
run_module "backends"

log_section "integration / examples"
for tex in \
  "${ROOT}/examples/minimal-homework.tex" \
  "${ROOT}/examples/project-report.tex"; do
  stem=$(basename "${tex%.tex}")
  if compile_test "$tex"; then
    run_assertions "$stem" "${BUILD_DIR}/${stem}.pdf"
  else
    _SUSTECH_FAILED=$((_SUSTECH_FAILED + 1))
  fi
done

print_summary "Integration Tests"
