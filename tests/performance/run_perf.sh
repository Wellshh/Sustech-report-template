#!/usr/bin/env bash
# Performance test runner — per-pass XeLaTeX compile time benchmarks.
#
# Usage:
#   bash tests/performance/run_perf.sh
#   MAX_COMPILE_SECONDS=60 bash tests/performance/run_perf.sh
#
# Output:
#   Console: per-document timing table (pass1, biber, pass2, total).
#   File:    tests/_build/perf_report.tsv  (machine-readable; uploaded by CI).
#
# The default compile-time budget per document is document-specific (see the
# time limits table below). Override the global cap via MAX_COMPILE_SECONDS.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
source "${ROOT}/tests/lib/common.sh"
reset_counters

# Default global cap (seconds, two passes total). Per-document limits override.
MAX_SEC="${MAX_COMPILE_SECONDS:-90}"

# ---------------------------------------------------------------------------
# Per-document time limits (seconds, two-pass total).
# Documents that use \addbibresource get a third pass via biber.
# ---------------------------------------------------------------------------
declare -A TIME_LIMITS=(
  [test_perf_minimal]=20
  [test_perf_listings_heavy]=45
  [test_perf_tikz_heavy]=60
  [test_perf_full_features]=90
)

# ---------------------------------------------------------------------------
# TSV report header
# ---------------------------------------------------------------------------
TSV="${BUILD_DIR}/perf_report.tsv"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "stem" "pass1_s" "biber_s" "pass2_s" "pass3_s" "total_s" "status" \
  > "$TSV"

# ---------------------------------------------------------------------------
# measure_compile_time_detailed <tex> <max_seconds>
#   Runs up to three XeLaTeX passes (with biber when needed) and records the
#   wall-clock time for each individual step.
#   Fails if total time exceeds max_seconds.
# ---------------------------------------------------------------------------
measure_compile_time_detailed() {
  local tex="$1"
  local max_sec="$2"
  local stem
  stem=$(basename "${tex%.tex}")
  local tex_dir
  tex_dir=$(cd "$(dirname "$tex")" && pwd)
  local tex_name
  tex_name=$(basename "$tex")
  local log="${BUILD_DIR}/${stem}.log"

  clean_build_artifacts "$tex_dir" "$stem"

  local needs_biber=0
  tex_needs_biber "$tex" && needs_biber=1

  local t0 t1 t2 t3 t4
  local pass1_s=0 biber_s=0 pass2_s=0 pass3_s=0 total_s=0
  local status="PASS"

  # Pass 1
  t0=$(date +%s)
  if ! (
       cd "$tex_dir" &&
       TEXINPUTS="${ROOT}:${ROOT}/examples:${TEXINPUTS:-}" \
       BIBINPUTS="${ROOT}:${ROOT}/examples:${BIBINPUTS:-}" \
       xelatex -interaction=nonstopmode -halt-on-error \
         -output-directory="${BUILD_DIR}" "${tex_name}"
     ) >"${BUILD_DIR}/${stem}.stdout1" 2>&1; then
    status="FAIL(pass1)"
    t1=$(date +%s)
    pass1_s=$(( t1 - t0 ))
    total_s=$pass1_s
    _record_and_fail "$stem" "$pass1_s" "0" "0" "0" "$total_s" "$status" "$max_sec"
    return 1
  fi
  t1=$(date +%s)
  pass1_s=$(( t1 - t0 ))

  # Biber (when needed)
  if [[ $needs_biber -eq 1 ]]; then
    t0=$(date +%s)
    if ! run_biber "$stem"; then
      status="FAIL(biber)"
      t2=$(date +%s)
      biber_s=$(( t2 - t0 ))
      total_s=$(( pass1_s + biber_s ))
      _record_and_fail "$stem" "$pass1_s" "$biber_s" "0" "0" "$total_s" "$status" "$max_sec"
      return 1
    fi
    t2=$(date +%s)
    biber_s=$(( t2 - t0 ))
  fi

  # Pass 2
  t0=$(date +%s)
  if ! (
       cd "$tex_dir" &&
       TEXINPUTS="${ROOT}:${ROOT}/examples:${TEXINPUTS:-}" \
       BIBINPUTS="${ROOT}:${ROOT}/examples:${BIBINPUTS:-}" \
       xelatex -interaction=nonstopmode -halt-on-error \
         -output-directory="${BUILD_DIR}" "${tex_name}"
     ) >"${BUILD_DIR}/${stem}.stdout2" 2>&1; then
    status="FAIL(pass2)"
    t3=$(date +%s)
    pass2_s=$(( t3 - t0 ))
    total_s=$(( pass1_s + biber_s + pass2_s ))
    _record_and_fail "$stem" "$pass1_s" "$biber_s" "$pass2_s" "0" "$total_s" "$status" "$max_sec"
    return 1
  fi
  t3=$(date +%s)
  pass2_s=$(( t3 - t0 ))

  # Pass 3 (only when biber ran, to resolve bibliography labels)
  if [[ $needs_biber -eq 1 ]]; then
    t0=$(date +%s)
    if ! (
         cd "$tex_dir" &&
         TEXINPUTS="${ROOT}:${ROOT}/examples:${TEXINPUTS:-}" \
         BIBINPUTS="${ROOT}:${ROOT}/examples:${BIBINPUTS:-}" \
         xelatex -interaction=nonstopmode -halt-on-error \
           -output-directory="${BUILD_DIR}" "${tex_name}"
       ) >"${BUILD_DIR}/${stem}.stdout3" 2>&1; then
      status="FAIL(pass3)"
      t4=$(date +%s)
      pass3_s=$(( t4 - t0 ))
      total_s=$(( pass1_s + biber_s + pass2_s + pass3_s ))
      _record_and_fail "$stem" "$pass1_s" "$biber_s" "$pass2_s" "$pass3_s" "$total_s" "$status" "$max_sec"
      return 1
    fi
    t4=$(date +%s)
    pass3_s=$(( t4 - t0 ))
  fi

  total_s=$(( pass1_s + biber_s + pass2_s + pass3_s ))

  # Check hard-error log
  if [[ -f "$log" ]] && grep -Eq '^! |LaTeX Error:|Emergency stop|Fatal error' "$log"; then
    status="FAIL(errors)"
    _record_and_fail "$stem" "$pass1_s" "$biber_s" "$pass2_s" "$pass3_s" "$total_s" "$status" "$max_sec"
    return 1
  fi

  # Time budget check
  if [[ $total_s -gt $max_sec ]]; then
    status="SLOW"
    log_fail "compile time ${total_s}s > ${max_sec}s for ${stem}"
  else
    log_pass "compile time ${total_s}s ≤ ${max_sec}s for ${stem}"
  fi

  # Print timing breakdown
  printf '  %-40s  pass1=%3ds  biber=%3ds  pass2=%3ds  pass3=%3ds  total=%3ds\n' \
    "$stem" "$pass1_s" "$biber_s" "$pass2_s" "$pass3_s" "$total_s"

  # Append to TSV
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$stem" "$pass1_s" "$biber_s" "$pass2_s" "$pass3_s" "$total_s" "$status" \
    >> "$TSV"
}

# Record a failed run to TSV and mark as failed.
_record_and_fail() {
  local stem="$1" pass1="$2" biber="$3" pass2="$4" pass3="$5" total="$6" status="$7" max="$8"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$stem" "$pass1" "$biber" "$pass2" "$pass3" "$total" "$status" >> "$TSV"
  log_fail "${status} for ${stem} (${total}s / limit ${max}s)"
}

# ---------------------------------------------------------------------------
# Run all fixtures in tests/performance/compile-time/
# ---------------------------------------------------------------------------
log_section "performance / compile-time"

echo ""
printf '  %-40s  %s\n' "Fixture" "Timing breakdown"
printf '  %s\n' "$(printf '%0.s-' {1..75})"

shopt -s nullglob
for tex in "${ROOT}/tests/performance/compile-time"/test_*.tex; do
  stem=$(basename "${tex%.tex}")
  # Use per-document limit if defined, else fall back to global MAX_SEC.
  limit="${TIME_LIMITS[$stem]:-$MAX_SEC}"
  measure_compile_time_detailed "$tex" "$limit"
done

echo ""
echo "  Performance report written to: ${TSV}"
echo ""

print_summary "Performance Tests"
