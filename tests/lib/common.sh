#!/usr/bin/env bash
# Shared utilities for all SUSTechHomework test runners.
# Source this file at the top of every runner script.
#
# Usage:
#   ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
#   source "${ROOT}/tests/lib/common.sh"

# ---------------------------------------------------------------------------
# Path resolution: callers set ROOT before sourcing this file.
# ---------------------------------------------------------------------------
: "${ROOT:?ROOT must be set before sourcing common.sh}"
BUILD_DIR="${ROOT}/tests/_build"
mkdir -p "$BUILD_DIR"

# ---------------------------------------------------------------------------
# Tool discovery
# ---------------------------------------------------------------------------
# Homebrew poppler is often not on PATH; probe common locations.
for _bin in /opt/homebrew/opt/poppler/bin /usr/local/opt/poppler/bin; do
  if [[ -x "${_bin}/pdftotext" ]]; then
    PATH="${_bin}:${PATH}"; export PATH; break
  fi
done

PDFTOTEXT_CMD=$(command -v pdftotext 2>/dev/null || true)
PDFINFO_CMD=$(command -v pdfinfo   2>/dev/null || true)
DIFFPDF_CMD=$(command -v diff-pdf  2>/dev/null || true)
BIBER_CMD=$(command -v biber      2>/dev/null || true)

# ---------------------------------------------------------------------------
# Global counters (each runner resets these at the top via reset_counters)
# ---------------------------------------------------------------------------
_SUSTECH_FAILED=0
_SUSTECH_PASSED=0
_SUSTECH_SKIPPED=0

reset_counters() {
  _SUSTECH_FAILED=0
  _SUSTECH_PASSED=0
  _SUSTECH_SKIPPED=0
}

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
log_section() { echo ""; echo "=== $* ==="; }
log_pass()    { echo "    PASS: $*";         _SUSTECH_PASSED=$((_SUSTECH_PASSED  + 1)); }
log_fail()    { echo "    FAIL: $*" >&2;     _SUSTECH_FAILED=$((_SUSTECH_FAILED  + 1)); }
log_skip()    { echo "    SKIP: $*";         _SUSTECH_SKIPPED=$((_SUSTECH_SKIPPED + 1)); }
log_warn()    { echo "    WARN: $*"; }

print_summary() {
  local suite_name="${1:-Tests}"
  echo ""
  echo "--- ${suite_name} Summary ---"
  echo "  Passed:  ${_SUSTECH_PASSED}"
  echo "  Failed:  ${_SUSTECH_FAILED}"
  echo "  Skipped: ${_SUSTECH_SKIPPED}"
  if [[ ${_SUSTECH_FAILED} -ne 0 ]]; then
    echo "  STATUS: FAILED" >&2
    return 1
  fi
  echo "  STATUS: PASSED"
  return 0
}

# ---------------------------------------------------------------------------
# compile_test <path/to/test.tex>
#   Compile a .tex file from ROOT.
#   If the source uses biblatex, automatically run biber between XeLaTeX passes.
#   Output goes to BUILD_DIR (flat; all test stems are globally unique).
#   Returns 0 on success, 1 on any compilation error.
# ---------------------------------------------------------------------------
tex_needs_biber() {
  local tex="$1"
  grep -Eq '\\(addbibresource|printbibliography|sustechprintbibliography|textcite|parencite|autocite)' "$tex"
}

run_biber() {
  local stem="$1"
  local bcf="${BUILD_DIR}/${stem}.bcf"
  if [[ ! -f "$bcf" ]]; then
    log_fail "missing BCF file for ${stem}; cannot run biber"
    return 1
  fi
  if [[ -z "$BIBER_CMD" ]]; then
    log_fail "biber not found but bibliography support is required for ${stem}"
    return 1
  fi
  if ! BIBINPUTS="${ROOT}:${ROOT}/examples:${BIBINPUTS:-}" \
       "$BIBER_CMD" --input-directory="${BUILD_DIR}" \
       --output-directory="${BUILD_DIR}" "${stem}" \
       >"${BUILD_DIR}/${stem}.biber.stdout" 2>&1; then
    log_fail "biber failed for ${stem}"
    return 1
  fi
  log_pass "processed bibliography for ${stem}"
  return 0
}

clean_artifacts_for_stem() {
  local dir="$1"
  local stem="$2"
  rm -f \
    "${dir}/${stem}.aux" \
    "${dir}/${stem}.bbl" \
    "${dir}/${stem}.bcf" \
    "${dir}/${stem}.blg" \
    "${dir}/${stem}.fdb_latexmk" \
    "${dir}/${stem}.fls" \
    "${dir}/${stem}.listing" \
    "${dir}/${stem}.log" \
    "${dir}/${stem}.out" \
    "${dir}/${stem}.pdf" \
    "${dir}/${stem}.run.xml" \
    "${dir}/${stem}.stdout1" \
    "${dir}/${stem}.stdout2" \
    "${dir}/${stem}.stdout3" \
    "${dir}/${stem}.synctex.gz" \
    "${dir}/${stem}.toc" \
    "${dir}/${stem}.biber.stdout"
}

clean_build_artifacts() {
  local tex_dir="$1"
  local stem="$2"
  clean_artifacts_for_stem "${BUILD_DIR}" "$stem"
  if [[ "$tex_dir" != "$BUILD_DIR" ]]; then
    clean_artifacts_for_stem "$tex_dir" "$stem"
  fi
}

compile_test() {
  local tex="$1"
  local stem
  stem=$(basename "${tex%.tex}")
  local needs_biber=0
  local tex_dir tex_name

  tex_dir=$(cd "$(dirname "$tex")" && pwd)
  tex_name=$(basename "$tex")
  local log="${BUILD_DIR}/${stem}.log"

  echo "  -- ${tex}"

  clean_build_artifacts "$tex_dir" "$stem"

  if tex_needs_biber "$tex"; then
    needs_biber=1
  fi

  # First pass
  if ! (
       cd "$tex_dir" &&
       TEXINPUTS="${ROOT}:${ROOT}/examples:${TEXINPUTS:-}" \
       BIBINPUTS="${ROOT}:${ROOT}/examples:${BIBINPUTS:-}" \
       xelatex -interaction=nonstopmode -halt-on-error \
         -output-directory="${BUILD_DIR}" "${tex_name}"
     ) >"${BUILD_DIR}/${stem}.stdout1" 2>&1; then
    log_fail "xelatex pass 1 failed for ${tex}"
    grep -E '^! |LaTeX Error:|Emergency stop|Fatal error' "$log" 2>/dev/null | head -10 >&2 || true
    return 1
  fi

  if [[ $needs_biber -eq 1 ]]; then
    if ! run_biber "$stem"; then
      return 1
    fi
  fi

  # Second pass (cross-references, bibliography, LastPage)
  if ! (
       cd "$tex_dir" &&
       TEXINPUTS="${ROOT}:${ROOT}/examples:${TEXINPUTS:-}" \
       BIBINPUTS="${ROOT}:${ROOT}/examples:${BIBINPUTS:-}" \
       xelatex -interaction=nonstopmode -halt-on-error \
         -output-directory="${BUILD_DIR}" "${tex_name}"
     ) >"${BUILD_DIR}/${stem}.stdout2" 2>&1; then
    log_fail "xelatex pass 2 failed for ${tex}"
    grep -E '^! |LaTeX Error:|Emergency stop|Fatal error' "$log" 2>/dev/null | head -10 >&2 || true
    return 1
  fi

  # Third pass is only needed when bibliography data was injected by biber.
  if [[ $needs_biber -eq 1 ]]; then
    if ! (
         cd "$tex_dir" &&
         TEXINPUTS="${ROOT}:${ROOT}/examples:${TEXINPUTS:-}" \
         BIBINPUTS="${ROOT}:${ROOT}/examples:${BIBINPUTS:-}" \
         xelatex -interaction=nonstopmode -halt-on-error \
           -output-directory="${BUILD_DIR}" "${tex_name}"
       ) >"${BUILD_DIR}/${stem}.stdout3" 2>&1; then
      log_fail "xelatex pass 3 failed for ${tex}"
      grep -E '^! |LaTeX Error:|Emergency stop|Fatal error' "$log" 2>/dev/null | head -10 >&2 || true
      return 1
    fi
  fi

  # Hard-error scan on the log
  if [[ -f "$log" ]] && grep -Eq '^! |LaTeX Error:|Emergency stop|Fatal error' "$log"; then
    log_fail "LaTeX errors in log for ${tex}"
    grep -E '^! |LaTeX Error:|Emergency stop|Fatal error' "$log" | head -10 >&2
    return 1
  fi

  log_pass "compiled ${stem}"
  return 0
}

# ---------------------------------------------------------------------------
# Compile and then run per-test assertions.
# compile_and_assert <tex> [assertion-function]
#   If assertion-function is provided it is called with (stem, pdf_path).
# ---------------------------------------------------------------------------
compile_and_assert() {
  local tex="$1"
  local assert_fn="${2:-}"
  local stem
  stem=$(basename "${tex%.tex}")
  local pdf="${BUILD_DIR}/${stem}.pdf"

  if compile_test "$tex"; then
    if [[ -n "$assert_fn" ]] && declare -f "$assert_fn" >/dev/null 2>&1; then
      "$assert_fn" "$stem" "$pdf" || true
    fi
  fi
}

# ---------------------------------------------------------------------------
# assert_pdf_contains <pdf> <strings...>
#   Checks that pdftotext output contains every supplied string.
# ---------------------------------------------------------------------------
assert_pdf_contains() {
  local pdf="$1"; shift
  if [[ -z "$PDFTOTEXT_CMD" ]]; then
    log_skip "pdftotext not found – text checks skipped for $(basename "$pdf")"
    return 0
  fi
  if [[ ! -f "$pdf" ]]; then
    log_fail "missing PDF: ${pdf}"
    return 1
  fi
  local text
  text=$("$PDFTOTEXT_CMD" "$pdf" - 2>/dev/null) || true
  local ok=0
  for s in "$@"; do
    if ! grep -Fq "$s" <<< "$text"; then
      log_fail "PDF $(basename "$pdf") missing expected text: '${s}'"
      ok=1
    fi
  done
  return $ok
}

# ---------------------------------------------------------------------------
# assert_pdf_lacks <pdf> <strings...>
#   Checks that none of the supplied strings appear in the PDF text.
# ---------------------------------------------------------------------------
assert_pdf_lacks() {
  local pdf="$1"; shift
  if [[ -z "$PDFTOTEXT_CMD" ]]; then
    log_skip "pdftotext not found – text exclusion checks skipped for $(basename "$pdf")"
    return 0
  fi
  [[ -f "$pdf" ]] || return 0
  local text
  text=$("$PDFTOTEXT_CMD" "$pdf" - 2>/dev/null) || true
  local ok=0
  for s in "$@"; do
    if grep -Fq "$s" <<< "$text"; then
      log_fail "PDF $(basename "$pdf") must NOT contain: '${s}'"
      ok=1
    fi
  done
  return $ok
}

# ---------------------------------------------------------------------------
# assert_pdf_metadata <pdf> <field> <expected-substring>
#   Uses pdfinfo to check a metadata field (Title, Author, Subject, etc.)
# ---------------------------------------------------------------------------
assert_pdf_metadata() {
  local pdf="$1"
  local field="$2"
  local expected="$3"
  if [[ -z "$PDFINFO_CMD" ]]; then
    log_skip "pdfinfo not found – metadata check skipped for $(basename "$pdf")"
    return 0
  fi
  if [[ ! -f "$pdf" ]]; then
    log_fail "missing PDF: ${pdf}"
    return 1
  fi
  local actual
  actual=$("$PDFINFO_CMD" "$pdf" 2>/dev/null | grep "^${field}:" | sed 's/^[^:]*:[[:space:]]*//')
  if [[ "$actual" != *"$expected"* ]]; then
    log_fail "PDF metadata [${field}]: expected '${expected}', got '${actual}'"
    return 1
  fi
  log_pass "metadata [${field}] contains '${expected}'"
  return 0
}

# ---------------------------------------------------------------------------
# assert_pdf_visual <baseline_pdf> <current_pdf> [--strict]
#   Compares two PDFs visually using diff-pdf.
#   Without --strict, a difference is a WARN (not FAIL) to tolerate
#   cross-machine font rendering variations.
#   With --strict, a difference is a hard FAIL.
#
#   Diff images (if any) are written to tests/regression/diffs/.
# ---------------------------------------------------------------------------
assert_pdf_visual() {
  local baseline="$1"
  local current="$2"
  local strict=0
  [[ "${3:-}" == "--strict" ]] && strict=1

  if [[ -z "$DIFFPDF_CMD" ]]; then
    log_skip "diff-pdf not found – visual regression skipped (install: brew install diff-pdf)"
    return 0
  fi
  if [[ ! -f "$baseline" ]]; then
    log_skip "no baseline for $(basename "$current") – run update_baselines.sh first"
    return 0
  fi
  if [[ ! -f "$current" ]]; then
    log_fail "current PDF not found: ${current}"
    return 1
  fi

  local diff_dir="${ROOT}/tests/regression/diffs"
  mkdir -p "$diff_dir"
  local stem
  stem=$(basename "${current%.pdf}")
  local diff_out="${diff_dir}/${stem}_diff.pdf"

  # --dpi=72 --channel-tolerance=15: tolerant enough for cross-machine differences
  if "$DIFFPDF_CMD" --dpi=72 --channel-tolerance=15 \
       --output-diff="$diff_out" "$baseline" "$current" 2>/dev/null; then
    log_pass "visual regression OK for ${stem}"
    rm -f "$diff_out"   # clean up no-diff output
    return 0
  else
    if [[ $strict -eq 1 ]]; then
      log_fail "visual regression FAILED for ${stem} (diff: ${diff_out})"
      return 1
    else
      log_warn "visual regression differs for ${stem} (diff saved: ${diff_out})"
      return 0
    fi
  fi
}

# ---------------------------------------------------------------------------
# measure_compile_time <tex> <max_seconds>
#   Compiles a .tex file and records wall-clock time.
#   Fails if the total time (2 passes) exceeds max_seconds.
# ---------------------------------------------------------------------------
measure_compile_time() {
  local tex="$1"
  local max_sec="$2"
  local stem
  stem=$(basename "${tex%.tex}")
  local tex_dir
  tex_dir=$(cd "$(dirname "$tex")" && pwd)

  clean_build_artifacts "$tex_dir" "$stem"

  local t_start t_end elapsed
  t_start=$(date +%s)

  xelatex -interaction=nonstopmode -halt-on-error \
    -output-directory="${BUILD_DIR}" "${tex}" >/dev/null 2>&1 || true
  xelatex -interaction=nonstopmode -halt-on-error \
    -output-directory="${BUILD_DIR}" "${tex}" >/dev/null 2>&1 || true

  t_end=$(date +%s)
  elapsed=$(( t_end - t_start ))

  echo "  Compile time for ${stem}: ${elapsed}s (limit: ${max_sec}s)"
  if [[ $elapsed -le $max_sec ]]; then
    log_pass "compile time ${elapsed}s ≤ ${max_sec}s"
  else
    log_fail "compile time ${elapsed}s > ${max_sec}s for ${stem}"
  fi
}
