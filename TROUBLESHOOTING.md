# Troubleshooting — SUSTech Report Template

This guide covers the most common errors encountered when compiling
`SUSTechHomework.cls`-based documents. Each entry shows the error text as it
appears in the terminal or log file, explains the root cause, and provides
step-by-step fixes.

> **Quick diagnostic**: Run `xelatex -interaction=nonstopmode your_file.tex`
> and check the last 20 lines of `your_file.log`. The first `!` line is
> usually the real error; later errors are often cascades.

---

## Table of Contents

1. [Font Not Found](#1-font-not-found)
2. [Windows / MiKTeX Path Problems](#2-windows--miktex-path-problems)
3. [TeX Live Version Mismatches](#3-tex-live-version-mismatches)
4. [Wrong Compilation Engine](#4-wrong-compilation-engine)
5. [tcolorbox / listings Internal Errors](#5-tcolorbox--listings-internal-errors)
6. [Compilation Performance](#6-compilation-performance)

---

## 1. Font Not Found

### 1.1 Western font missing

**Error message**
```
! fontspec error: "font-not-found"
! The font "TeX Gyre Pagella" cannot be found.
```

**Cause**  
The template tries to load *TeX Gyre Pagella* (main font), *TeX Gyre Heros*
(sans-serif), and *TeX Gyre Cursor* (monospace) via `fontspec`. If they are
not installed in your TeX distribution or system font paths, `fontspec` aborts.

**Fix — Option A: install TeX Gyre fonts**

| System | Command |
|--------|---------|
| TeX Live (any OS) | `tlmgr install tex-gyre` |
| Ubuntu / Debian | `sudo apt install fonts-texgyre` |
| macOS (Homebrew) | `brew install --cask font-tex-gyre-pagella` |
| Windows MiKTeX | MiKTeX Console → Packages → search `tex-gyre` → Install |

After installation, rebuild the font cache:
```bash
fc-cache -fv      # Linux / macOS
```

**Fix — Option B: fall back to Computer Modern**  
The class uses `\IfFontExistsTF` guards, so if the fonts are simply absent it
silently falls back to Computer Modern. If the error still fires, you may have
a corrupted `fontconfig` cache. Rebuild it and recompile:
```bash
fc-cache -fv && xelatex your_file.tex
```

---

### 1.2 CJK / Chinese font missing

**Error message**
```
! xeCJK Error: (xeCJK) CJK family `\CJKfamilydefault` cannot be set up.
```
or
```
kpathsea: Running mktexpk --mfmode / --bdpi 600 --mag 1 --dpi 600 ...
```

**Cause**  
`xeCJK` cannot locate a CJK font. The template requests *Noto Serif CJK SC*
(main) and *Noto Sans CJK SC* (sans) with `Source Han Serif SC` / `PingFang SC`
/ `Songti SC` as fallbacks. If none of these are installed, `xeCJK` falls back
to bitmap fonts which may produce garbled output or abort compilation.

**Fix — Linux (Ubuntu / Debian)**
```bash
sudo apt install fonts-noto-cjk fonts-wqy-zenhei fonts-wqy-microhei
fc-cache -fv
```

**Fix — macOS**  
PingFang SC and Songti SC ship with macOS 10.11+. If they are missing:
```bash
# Install Noto CJK via Homebrew Cask
brew install --cask font-noto-serif-cjk-sc font-noto-sans-cjk-sc
```

**Fix — Windows**  
Install *Microsoft YaHei* (already present on most Windows 10/11) or download
[Noto CJK](https://github.com/googlefonts/noto-cjk/releases) and install via
Settings → Fonts.

**Verify installed fonts**
```bash
fc-list :lang=zh | head -20
```

---

## 2. Windows / MiKTeX Path Problems

### 2.1 `\addbibresource` cannot find the `.bib` file

**Error message**
```
WARN - BibTeX data source 'example.bib' not found
```
or biber exits with `ERROR - Cannot find 'example.bib'!`

**Cause**  
MiKTeX and biber look for `.bib` files relative to the *working directory*,
which may differ from the `.tex` file's directory when compiling from a GUI
(e.g. TeXworks, TeXstudio) that launches from a different CWD.

**Fix**  
Either compile from the directory that contains both `.tex` and `.bib`:
```powershell
cd C:\Users\you\Documents\report
xelatex -interaction=nonstopmode example.tex
biber example
xelatex -interaction=nonstopmode example.tex
```

Or use an absolute path in the preamble (not recommended for portability):
```latex
\addbibresource{C:/Users/you/Documents/report/example.bib}
```

---

### 2.2 PowerShell / cmd quoting issues

**Symptom**  
Running `xelatex example.tex` in PowerShell produces unexpected errors about
`{` or `}` characters, or the file is not found.

**Cause**  
PowerShell may interpret curly braces, backticks, and dollar signs in ways that
differ from bash. The `%` character also needs escaping in `cmd.exe`.

**Fix**  
Wrap the filename in double quotes and use `-interaction` explicitly:
```powershell
xelatex -interaction=nonstopmode "example.tex"
```

For multi-pass compilation in PowerShell:
```powershell
xelatex -interaction=nonstopmode "example.tex"
biber "example"
xelatex -interaction=nonstopmode "example.tex"
xelatex -interaction=nonstopmode "example.tex"
```

---

### 2.3 MiKTeX package not installed on-the-fly

**Error message**
```
! LaTeX Error: File `tcolorbox.sty' not found.
```

**Cause**  
MiKTeX's automatic package installer may be disabled or unable to reach the
network.

**Fix**  
Open *MiKTeX Console* → *Packages* and install the missing package manually,
or enable automatic package installation in *Settings → General*.

---

## 3. TeX Live Version Mismatches

### 3.1 `tcolorbox` version too old

**Error message**
```
! Package tcolorbox Error: Option 'breakable' unknown.
```
or
```
! Undefined control sequence. \tcbuselibrary ...breakable
```

**Cause**  
The template requires `tcolorbox` ≥ 5.0 (released 2022). The `breakable`
and `skins` libraries changed their internal API in version 5.

**Fix**

| Distribution | Command |
|---|---|
| TeX Live | `tlmgr update tcolorbox` |
| MiKTeX | MiKTeX Console → Updates |
| Ubuntu 20.04 (ships TL 2019) | `sudo apt install texlive-full` or use [TeX Live installer](https://www.tug.org/texlive/) directly |

Check current version:
```bash
texdoc --just-show tcolorbox | head -5
# or
kpsewhich tcolorbox.sty | xargs grep ProvidesPackage
```

---

### 3.2 `biblatex` / `biber` version mismatch

**Error message**
```
ERROR - Biblatex version 3.17 is not compatible with biber version 2.19
```

**Cause**  
`biblatex` and `biber` must be updated together; they share an internal data
format that increments with each release.

**Fix**  
Update both packages simultaneously:
```bash
tlmgr update biblatex biber
```

Verify versions:
```bash
biber --version          # e.g. biber version: 2.20
texdoc --just-show biblatex | head -3
```

Required versions for this template: `biblatex` ≥ 3.18, `biber` ≥ 2.18.

---

### 3.3 Ubuntu / Debian system TeX Live is too old

Ubuntu 20.04 ships TeX Live 2019; Ubuntu 22.04 ships TeX Live 2021. Several
required packages (`tcolorbox 5.x`, `biblatex 3.18+`) require TeX Live 2022+.

**Fix — install the official TeX Live installer**
```bash
# Download from https://www.tug.org/texlive/
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
cd install-tl-*
sudo perl install-tl --no-interaction
# Then add /usr/local/texlive/2024/bin/x86_64-linux to PATH
```

---

## 4. Wrong Compilation Engine

### 4.1 Compiled with `pdflatex` instead of `xelatex`

**Error message**
```
! LaTeX Error: File `fontspec.sty' not found.
```
or
```
! Package fontspec Error: "cannot-use-pdftex"
! The fontspec package requires either XeTeX or LuaTeX.
```

**Cause**  
`fontspec` and `xeCJK` are XeLaTeX-only packages. `pdflatex` cannot load them.

**Fix**  
Switch the compilation engine to XeLaTeX:

| Editor / Tool | How to switch |
|---|---|
| TeXstudio | Options → Configure TeXstudio → Build → Default Compiler → XeLaTeX |
| Overleaf | Menu (top-left) → Compiler → XeLaTeX |
| VS Code (LaTeX Workshop) | Add `% !TEX program = xelatex` as the first line of your `.tex` file |
| Command line | Replace `pdflatex` with `xelatex` |

All provided example files already include the magic comment:
```latex
% !TEX program = xelatex
```

---

### 4.2 Missing `--shell-escape` for `minted` backend

**Error message**
```
! Package minted Error: You must invoke LaTeX with the -shell-escape flag.
```

**Cause**  
The `minted` backend (selected with `\documentclass[code=minted]{SUSTechHomework}`)
calls the Pygments syntax highlighter via a shell subprocess, which requires the
`-shell-escape` (or `-enable-write18` on MiKTeX) flag.

**Fix**

```bash
# Linux / macOS
xelatex -shell-escape -interaction=nonstopmode your_file.tex

# MiKTeX (Windows)
xelatex -enable-write18 -interaction=nonstopmode your_file.tex
```

In editors:

| Editor | Setting |
|---|---|
| TeXstudio | Options → Build → XeLaTeX → append `--shell-escape` |
| LaTeX Workshop (VS Code) | `latex-workshop.latex.tools` → add `"-shell-escape"` to args |

Alternatively, switch to the default `listings` backend which requires no
shell access: `\documentclass[code=listings]{SUSTechHomework}`.

---

## 5. tcolorbox / listings Internal Errors

### 5.1 `\begin{tcb@savebox} ended by \end{document}`

**Full error in log**
```
! LaTeX Error: \begin{tcb@savebox} on input line NNN ended by \end{document}.
! You can't use `\end' in internal vertical mode.
```

**Cause**  
A `tcolorbox`-based environment (e.g. `sustechcode`, `sustechlongcode`,
`sustechdiff`) was opened but TeX ran out of input before the matching `\end`
was found. Common triggers:

1. **Unclosed environment** — `\end{sustechcode}` is missing or misspelled.
2. **Language dialect in mandatory argument** — passing `{[Modern]C++}` or
   `{[SUSTech]MATLAB}` directly to a `NewTCBListing` environment causes the
   `[...]` to be misinterpreted by the tcolorbox key-value parser (see §5.2).
3. **Unbalanced braces inside the listing body** — a stray `{` or `}` in the
   code content can confuse the argument scanner on some `tcolorbox` versions.

**Fix for unclosed environment**  
Search for the matching `\begin{sustechcode}` and ensure the corresponding
`\end{sustechcode}` is present and spelled correctly.

**Fix for dialect brackets**  
Use the bracket-free aliases provided by the class (see §5.2 below).

**Fix for unbalanced braces in code**  
This should not normally occur in a verbatim-like listing, but if your code
contains a lone `}` at the start of a line in rare edge cases, wrap it with an
escape: `\}`.

---

### 5.2 `listings` dialect `[dialect]language` key-value parsing failure

**Full error in log**
```
! Paragraph ended before \lstKV@OptArg@@ was complete.
<to be read again> \par
l.NNN ...
```

**Cause**  
The `listings` package supports language dialects with the syntax
`language=[dialect]basename` (e.g. `language=[Modern]C++`). However, when
this string is passed through tcolorbox's pgfkeys-based `listing options={...}`
parser, the square brackets `[...]` are misinterpreted as an additional optional
argument, breaking the key-value parse.

**Fix**  
Use the **bracket-free aliases** that the class pre-defines with `\lstalias`:

| Dialect name | Correct alias to use |
|---|---|
| `[Modern]C++` | `moderncpp` |
| `[SUSTech]MATLAB` | `matlab` |

```latex
% Wrong (triggers parse error):
\begin{sustechcode}{[Modern]C++}

% Correct:
\begin{sustechcode}{moderncpp}
\begin{sustechcode}{matlab}
```

The same aliases work in `sustechlongcode`, `sustechcodeblock`, etc.

If you define your own dialect language and encounter this issue, register an
alias in the preamble:
```latex
\lstalias{myalias}{[MyDialect]SomeLanguage}
```

---

### 5.3 `sustechlongcode` extra argument miscount

**Symptom**  
Code that should be inside the listing appears before the block, or the block
title is wrong.

**Cause**  
`sustechlongcode` takes the arguments `{language}[title][filename]`. Passing
more than three optional brackets results in the surplus content being treated
as the start of the listing body.

**Fix**
```latex
% Signature: {mandatory-language} [optional-title] [optional-filename]
\begin{sustechlongcode}{Python}[Signal Processing][src/pipeline.py]
... code ...
\end{sustechlongcode}

% Minimal (title defaults to language name):
\begin{sustechlongcode}{Python}
... code ...
\end{sustechlongcode}
```

---

## 6. Compilation Performance

### 6.1 Why is my document slow to compile?

XeLaTeX is inherently slower than pdfLaTeX because it processes Unicode fonts
at runtime. The following operations add the most overhead:

| Cause | Typical cost |
|---|---|
| `fontspec` / `xeCJK` font scanning | +2–4 s (first run only) |
| `tcolorbox` with `breakable` | +0.3–0.5 s per block |
| Each TikZ diagram | +0.5–2 s per figure |
| `minted` via shell-escape | +1–3 s per block (Python subprocess) |
| Full bibliography (biber) | +2–5 s (extra pass) |

---

### 6.2 Use `latexmk` for faster iterative builds

`latexmk` automatically detects which passes are needed and skips unnecessary
recompilations. Install it (usually bundled with TeX Live) and run:

```bash
latexmk -xelatex -interaction=nonstopmode example.tex
```

Create a `.latexmkrc` file in your project root to persist options:

```perl
# .latexmkrc
$pdf_mode      = 5;            # 5 = xelatex
$xelatex       = 'xelatex -interaction=nonstopmode -halt-on-error %O %S';
$biber         = 'biber %O %B';
$clean_ext     = 'aux bbl bcf blg listing log out run.xml synctex.gz toc';
```

Then use `make example LATEXMK=1` (if using the provided `Makefile`) or simply
`latexmk` directly.

---

### 6.3 TikZ-heavy documents

When a document contains many TikZ diagrams (e.g. six or more engineering
flowcharts), each XeLaTeX pass may take 30–60 seconds. Strategies to mitigate:

**Option A — draft mode**  
Add the `draft` option to temporarily skip TikZ rendering (shows bounding box
placeholders):
```latex
\documentclass[draft]{SUSTechHomework}
```

Note: `draft` also disables image inclusion and some other expensive operations.

**Option B — `\tikzexternalize`**  
Pre-render TikZ figures to separate PDFs and cache them:
```latex
% Add to preamble (requires -shell-escape):
\usetikzlibrary{external}
\tikzexternalize[prefix=tikz-cache/]
```

Then compile with:
```bash
mkdir -p tikz-cache
xelatex -shell-escape -interaction=nonstopmode your_file.tex
```

Subsequent compilations reuse the cached PDFs and skip TikZ processing, often
cutting compile time by 50–80% for diagram-heavy documents.

**Option C — move diagrams to `\input` files**  
Keep each diagram in a separate `.tex` file and `\input` it. This makes it easy
to comment out individual diagrams while writing.

---

### 6.4 Checking compile time with the performance benchmark

The repository ships performance fixtures in `tests/performance/compile-time/`.
Run them to establish a baseline on your machine:

```bash
bash tests/performance/run_perf.sh
# Or via Makefile:
make perf
```

The runner outputs a TSV report at `tests/_build/perf_report.tsv`:

```
stem                      pass1_s  biber_s  pass2_s  pass3_s  total_s  status
test_perf_minimal             3        0        2        0        5     PASS
test_perf_listings_heavy      8        0        7        0       15     PASS
test_perf_tikz_heavy         18        0       16        0       34     PASS
test_perf_full_features      12        4       10        8       34     PASS
```

If a fixture exceeds its time limit, the status column shows `SLOW`. This
indicates either a machine-specific bottleneck or a regression introduced by a
recent class change.

---

## Still stuck?

1. Search the [LaTeX Stack Exchange](https://tex.stackexchange.com) for the
   exact error message.
2. Check the [tcolorbox manual](https://ctan.org/pkg/tcolorbox) (Section 18
   covers `NewTCBListing`).
3. Check the [xeCJK documentation](https://ctan.org/pkg/xecjk) for CJK font
   configuration.
4. Open an issue on the project repository and attach:
   - The minimal `.tex` file that reproduces the error.
   - The last 40 lines of the `.log` file.
   - Your TeX Live / MiKTeX version (`xelatex --version`).
