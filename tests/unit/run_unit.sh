#!/usr/bin/env bash
# Unit test runner — compiles every test in tests/unit/** and runs assertions.
# Run from repository root: bash tests/unit/run_unit.sh
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

    # --- metadata ---
    test_meta_fields)
      assert_pdf_contains "$pdf" \
        "CS100" "Engineering Writing" "Spring 2026" \
        "Prof. TestInstructor" "UniqueAuthorFieldXYZ"
      ;;

    test_meta_lang_en)
      # pdflang is stored in the PDF /Lang catalog entry, not visible via pdfinfo.
      # Verify compile succeeds and the title appears (content smoke check).
      assert_pdf_contains "$pdf" "English PDF lang"
      ;;

    test_meta_lang_zh)
      # Same: pdflang not accessible via pdfinfo; verify Chinese body compiles.
      assert_pdf_contains "$pdf" "语言测试"
      ;;

    test_meta_lang_auto)
      : # compile-only: no dynamic content to assert
      ;;

    # --- math ---
    test_math_semantics)
      assert_pdf_contains "$pdf" \
        "UniqueMathQty101" \
        "UniqueMathNum102" \
        "UniqueMathVect103" \
        "UniqueMathNorm104" \
        "UniqueMathDiff105"
      ;;

    # --- references ---
    test_refs_cleveref)
      assert_pdf_contains "$pdf" \
        "UniqueRefSection101" \
        "UniqueRefEquation102" \
        "UniqueRefFigure103" \
        "UniqueRefTable104" \
        "UniqueRefCode105" \
        "UniqueRefCapital106"
      assert_pdf_lacks "$pdf" "??"
      ;;

    test_refs_bibliography)
      assert_pdf_contains "$pdf" \
        "UniqueBibCite101" \
        "UniqueBibCite102" \
        "UniqueBibCite103" \
        "Shannon" \
        "A Mathematical Theory of Communication" \
        "CTAN Team" \
        "Pygments Project"
      assert_pdf_lacks "$pdf" "??"
      ;;

    # --- titlepage ---
    test_tp_simple_single)
      assert_pdf_contains "$pdf" "Minimal Test" "TEST" "Compile Check"
      ;;

    test_tp_simple_two_authors)
      assert_pdf_contains "$pdf" "Team Members" "et al."
      ;;

    test_tp_formal_single)
      assert_pdf_contains "$pdf" "UniqueSoloAuthorGHI" "87654321" "EE200"
      ;;

    test_tp_formal_dual_meta)
      assert_pdf_contains "$pdf" \
        "CRediT-style Contributions" \
        "Contribution Summary" \
        "UniqueMarkerDualMetaXYZ"
      ;;

    test_tp_formal_credit_only)
      assert_pdf_contains "$pdf" \
        "Contribution Summary" \
        "UniqueMarkerCreditOnlyABC"
      assert_pdf_lacks   "$pdf" "CRediT-style Contributions"
      ;;

    test_tp_formal_contrib_only)
      assert_pdf_contains "$pdf" \
        "CRediT-style Contributions" \
        "UniqueContribRoleDEF"
      assert_pdf_lacks   "$pdf" "Contribution Summary"
      ;;

    test_tp_mktitle_compat)
      assert_pdf_contains "$pdf" "mktitle Metadata" "TEST"
      ;;

    # --- visual ---
    test_vis_theme_light)
      assert_pdf_contains "$pdf" "Light Theme"
      ;;

    test_vis_note_boxes)
      assert_pdf_contains "$pdf" \
        "UniqueNoteDefaultMarker101" \
        "UniqueNoteCustomMarker102" \
        "UniqueWarnDefaultMarker103" \
        "UniqueWarnCustomMarker104"
      ;;

    test_vis_table_styles)
      assert_pdf_contains "$pdf" \
        "UniqueColAlpha" "UniqueColBeta" "UniqueColGamma"
      ;;

    test_vis_lists)
      assert_pdf_contains "$pdf" \
        "UniqBulletAlpha" "UniqBulletBeta" \
        "UniqEnumAlpha"   "UniqEnumBeta"   \
        "UniqNestTop"     "UniqNestInner"
      ;;

    test_vis_section_styles)
      assert_pdf_contains "$pdf" \
        "Section Level One" \
        "Subsection Level Two" \
        "Subsubsection Level Three"
      ;;

    # --- code ---
    test_code_listings_basic)
      assert_pdf_contains "$pdf" \
        "UniqueListingPython001" \
        "UniqueListingCpp002"
      ;;

    test_code_listings_langs)
      assert_pdf_contains "$pdf" \
        "UniqueJsonValue101" \
        "UniqueYamlValue102"
      ;;

    test_code_shell_env)
      assert_pdf_contains "$pdf" \
        "UniqueShellOutput201" \
        "UniqueShellNamed202"
      ;;

    test_code_block_wrapper)
      assert_pdf_contains "$pdf" \
        "UniqueWrapperCaption401" \
        "UniqueWrapperBody402" \
        "UniqueWrapperJson403"
      ;;

    test_code_shell_wrapper)
      assert_pdf_contains "$pdf" \
        "UniqueShellWrapper501" \
        "UniqueShellWrapper502"
      ;;

    test_code_inline)
      assert_pdf_contains "$pdf" \
        "UniqueInlineCode301" \
        "UniqueInlineMixed302"
      ;;

    # --- code / stage-4 extended ---
    test_code_langs_extended)
      assert_pdf_contains "$pdf" \
        "UniqueModernCpp701" \
        "UniqueMatlabLang702" \
        "UniqueYamlBool703" \
        "UniqueDiffLang704"
      ;;

    test_code_longcode)
      assert_pdf_contains "$pdf" \
        "UniqueLongCode801" \
        "UniqueLongShell802"
      ;;

    test_code_diff)
      assert_pdf_contains "$pdf" \
        "UniqueDiffEnv901" \
        "UniqueDiffBlock902" \
        "DiffCaption903"
      ;;

    # --- diagrams ---
    test_diag_subfigures)
      assert_pdf_contains "$pdf" \
        "UniqueSubfigGroup401" \
        "UniqueAsideContent402"
      ;;

    test_diag_engineering)
      assert_pdf_contains "$pdf" \
        "UniqueFlowChart501" \
        "UniqueDataStore502"
      ;;

    test_diag_pipeline)
      assert_pdf_contains "$pdf" \
        "UniquePipeline601" \
        "UniqueTimeline602"
      ;;

    test_diag_system)
      assert_pdf_contains "$pdf" \
        "UniqueSystemDiag701" \
        "UniqueArchDiag702" \
        "UniqueChainDiag703"
      ;;

    *)
      : # no extra assertions for unknown stems
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Run all unit subdirectories in logical order
# ---------------------------------------------------------------------------
run_module() {
  local module="$1"
  local dir="${ROOT}/tests/unit/${module}"
  log_section "unit / ${module}"
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

run_module "metadata"
run_module "math"
run_module "references"
run_module "titlepage"
run_module "visual"
run_module "code"
run_module "diagrams"

print_summary "Unit Tests"
