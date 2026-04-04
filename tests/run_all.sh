#!/usr/bin/env bash
# Master test runner for the SUSTechHomework template test suite.
#
# Usage:
#   bash tests/run_all.sh                    # run all suites
#   bash tests/run_all.sh --skip-regression  # skip visual regression (no diff-pdf needed)
#   bash tests/run_all.sh --skip-performance # skip timed compile tests
#   bash tests/run_all.sh --skip-acceptance  # skip release-facing acceptance suite
#   bash tests/run_all.sh --unit-only        # only unit tests (fastest CI check)
#   bash tests/run_all.sh --strict           # pass --strict to regression runner
#
# Exit codes:
#   0  all enabled suites passed
#   1  one or more suites failed
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# ---------------------------------------------------------------------------
# Parse flags
# ---------------------------------------------------------------------------
SKIP_UNIT=0
SKIP_INTEGRATION=0
SKIP_REGRESSION=0
SKIP_PERFORMANCE=0
SKIP_STRESS=0
SKIP_ACCEPTANCE=0
REGRESSION_FLAGS=()

for arg in "$@"; do
  case "$arg" in
    --skip-unit)         SKIP_UNIT=1        ;;
    --skip-integration)  SKIP_INTEGRATION=1 ;;
    --skip-regression)   SKIP_REGRESSION=1  ;;
    --skip-performance)  SKIP_PERFORMANCE=1 ;;
    --skip-stress)       SKIP_STRESS=1      ;;
    --skip-acceptance)   SKIP_ACCEPTANCE=1  ;;
    --unit-only)
      SKIP_INTEGRATION=1; SKIP_REGRESSION=1
      SKIP_PERFORMANCE=1; SKIP_STRESS=1
      SKIP_ACCEPTANCE=1
      ;;
    --strict) REGRESSION_FLAGS+=(--strict)  ;;
  esac
done

# ---------------------------------------------------------------------------
# Suite runner helper
# ---------------------------------------------------------------------------
total_failed=0

run_suite() {
  local name="$1"
  local script="$2"
  shift 2
  # Do not use a local array + "${arr[@]}" here: with set -u, an empty array
  # expansion is "unbound" on some Bash versions (e.g. macOS/Homebrew Bash).
  # "$@" after shift is always safe when there are zero extra arguments.

  echo ""
  echo "╔══════════════════════════════════════════════════════╗"
  printf  "║  %-52s║\n" "Suite: ${name}"
  echo "╚══════════════════════════════════════════════════════╝"

  if bash "$script" "$@"; then
    echo "  [SUITE PASSED] ${name}"
  else
    echo "  [SUITE FAILED] ${name}" >&2
    total_failed=$((total_failed + 1))
  fi
}

# ---------------------------------------------------------------------------
# Tool hint (non-fatal)
# ---------------------------------------------------------------------------
echo ""
echo "SUSTechHomework Test Suite"
echo "Root: ${ROOT}"
echo "Build dir: ${ROOT}/tests/_build"
echo ""

if [[ $SKIP_REGRESSION -eq 0 ]] && ! command -v diff-pdf >/dev/null 2>&1; then
  echo "HINT: diff-pdf not found; visual regression checks will be skipped."
  echo "      Install: brew install diff-pdf   (macOS)"
  echo "      Or:      apt install diff-pdf    (Debian/Ubuntu, if packaged)"
  echo ""
fi

# ---------------------------------------------------------------------------
# Run suites
# ---------------------------------------------------------------------------
[[ $SKIP_UNIT        -eq 0 ]] && run_suite "Unit Tests"        "tests/unit/run_unit.sh"
[[ $SKIP_INTEGRATION -eq 0 ]] && run_suite "Integration Tests" "tests/integration/run_integration.sh"
[[ $SKIP_ACCEPTANCE  -eq 0 ]] && run_suite "Acceptance Tests"  "tests/acceptance/run_acceptance.sh"
[[ $SKIP_REGRESSION  -eq 0 ]] && run_suite "Regression Tests"  "tests/regression/run_regression.sh" "${REGRESSION_FLAGS[@]}"
[[ $SKIP_PERFORMANCE -eq 0 ]] && run_suite "Performance Tests" "tests/performance/run_perf.sh"
[[ $SKIP_STRESS      -eq 0 ]] && run_suite "Stress Tests"      "tests/stress/run_stress.sh"

# ---------------------------------------------------------------------------
# Final summary
# ---------------------------------------------------------------------------
echo ""
echo "════════════════════════════════════════════════════════"
if [[ $total_failed -eq 0 ]]; then
  echo "  ALL SUITES PASSED"
  exit 0
else
  echo "  ${total_failed} SUITE(S) FAILED" >&2
  exit 1
fi
