#!/usr/bin/env bash
# Backward-compatibility shim.
# The test suite has been migrated to a layered structure under tests/unit/,
# tests/integration/, tests/regression/, tests/performance/, and tests/stress/.
#
# This script now delegates to the master runner (tests/run_all.sh).
# All original tests are preserved — they live in their respective subdirectories.
#
# Quick reference:
#   bash tests/run_tests.sh                     # equivalent to run_all.sh
#   bash tests/run_tests.sh --unit-only         # fast CI smoke check
#   bash tests/run_tests.sh --skip-regression   # skip visual diff (no diff-pdf needed)
#
# For the new layered entry point, use directly:
#   bash tests/run_all.sh [flags]
exec bash "$(dirname "$0")/run_all.sh" "$@"
