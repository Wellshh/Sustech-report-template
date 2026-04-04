# Makefile for SUSTech Report Template
#
# Common targets:
#   make example       Compile example.tex → example.pdf  (xelatex + biber + 2nd pass)
#   make test          Run the full test suite
#   make test-unit     Run unit tests only (fastest check, ~5 min)
#   make test-full     Run full suite, skip visual regression
#   make perf          Run performance benchmarks
#   make clean         Remove LaTeX build artefacts from the project root
#   make dist          Package a release zip (VERSION=v1.2.3 optional)
#   make help          Show this message
#
# Optional variables:
#   LATEXMK=1          Use latexmk instead of plain xelatex (requires latexmk)
#   VERSION=vX.Y.Z     Set the version tag for 'make dist' (default: dev)

SHELL   := /usr/bin/env bash
.DEFAULT_GOAL := help

# ---------------------------------------------------------------------------
# Tool detection
# ---------------------------------------------------------------------------
XELATEX  := xelatex
BIBER    := biber
LATEXMK  := latexmk

HAVE_LATEXMK := $(shell command -v latexmk 2>/dev/null && echo yes || echo no)

# Override compilation engine when LATEXMK=1 is set.
USE_LATEXMK ?= 0
ifeq ($(LATEXMK),1)
  USE_LATEXMK := 1
endif

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
VERSION  ?= dev
DIST_DIR  = dist
DIST_NAME = SUSTech-report-template-$(VERSION)
DIST_ZIP  = $(DIST_DIR)/$(DIST_NAME).zip

# ---------------------------------------------------------------------------
# Targets
# ---------------------------------------------------------------------------

.PHONY: help
help:
	@echo ""
	@echo "SUSTech Report Template — Makefile targets"
	@echo "-------------------------------------------"
	@echo "  make example          Compile example.tex → example.pdf"
	@echo "  make test             Run the full test suite"
	@echo "  make test-unit        Unit tests only (fastest)"
	@echo "  make test-full        Full suite, skip visual regression"
	@echo "  make perf             Run performance benchmarks"
	@echo "  make clean            Remove root-level build artefacts"
	@echo "  make dist             Package release zip (VERSION=vX.Y.Z)"
	@echo "  make help             Show this message"
	@echo ""
	@echo "Options:"
	@echo "  LATEXMK=1             Use latexmk instead of plain xelatex"
	@echo "  VERSION=vX.Y.Z        Set version for 'dist' target"
	@echo ""

# ---------------------------------------------------------------------------
# example: compile example.tex with full xelatex + biber pipeline
# ---------------------------------------------------------------------------
.PHONY: example
example: example.pdf

ifeq ($(USE_LATEXMK),1)
example.pdf: example.tex example.bib SUSTechHomework.cls
	$(LATEXMK) -xelatex -bibtex -interaction=nonstopmode example.tex
else
example.pdf: example.tex example.bib SUSTechHomework.cls
	$(XELATEX) -interaction=nonstopmode example.tex
	$(BIBER) example
	$(XELATEX) -interaction=nonstopmode example.tex
	$(XELATEX) -interaction=nonstopmode example.tex
endif

# ---------------------------------------------------------------------------
# Test targets
# ---------------------------------------------------------------------------
.PHONY: test test-unit test-full perf

test:
	bash tests/run_all.sh

test-unit:
	bash tests/run_all.sh --unit-only

test-full:
	bash tests/run_all.sh --skip-regression

perf:
	bash tests/performance/run_perf.sh

# ---------------------------------------------------------------------------
# clean: remove root-level LaTeX build artefacts (not tests/_build/)
# ---------------------------------------------------------------------------
.PHONY: clean
clean:
	rm -f \
	  example.aux example.bbl example.bcf example.blg \
	  example.fdb_latexmk example.fls example.listing \
	  example.log example.out example.run.xml \
	  example.synctex.gz example.toc \
	  examples/minimal-homework.aux examples/minimal-homework.log \
	  examples/project-report.aux  examples/project-report.log \
	  *.aux *.log *.out *.toc *.listing

# ---------------------------------------------------------------------------
# dist: package a release zip
#   Includes: .cls, example sources/PDF, examples/, assets/, README.md,
#             TROUBLESHOOTING.md, and PLAN.md.
# ---------------------------------------------------------------------------
.PHONY: dist
dist: example
	@mkdir -p $(DIST_DIR)
	@echo "Packaging $(DIST_ZIP) ..."
	zip -r "$(DIST_ZIP)" \
	  SUSTechHomework.cls \
	  example.tex \
	  example.bib \
	  example.pdf \
	  examples/ \
	  assets/ \
	  README.md \
	  TROUBLESHOOTING.md \
	  -x "*.aux" -x "*.log" -x "*.out" -x "*.toc" \
	  -x "*.bbl" -x "*.bcf" -x "*.blg" -x "*.run.xml" \
	  -x "*.synctex.gz" -x "*.listing" -x "*.fls" -x "*.fdb_latexmk"
	@echo "Created: $(DIST_ZIP)"

# Include PLAN.md only when it exists (not required for end-users).
ifneq ($(wildcard PLAN.md),)
dist: _dist_plan
.PHONY: _dist_plan
_dist_plan:
	zip "$(DIST_ZIP)" PLAN.md
endif
