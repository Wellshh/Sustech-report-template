% Original design reference:
% https://github.com/ziqin/LaTeX-SUSTechHomework
%
% This class is being modernized in layers. The current revision focuses on
% a cleaner class architecture, configurable options, and safer defaults.
%
% Layer map (class file architecture):
%   L1  Class declaration, engine guard, option system   (lines ~11-100)
%   L2  Always-loaded packages                           (lines ~100-115)
%   L3  Page geometry                                    (lines ~115-120)
%   L4  Font configuration (Western + CJK)               (lines ~120-140)
%   L5  Color palette and theme system                   (lines ~140-180)
%   L6  Hyperref and PDF metadata (base config)          (lines ~180-200)
%   L7  Math and unit system                             (lines ~200-225)
%   L8  Bibliography (on-demand via \addbibresource)     (lines ~225-270)
%   L9  Figure/table caption system                      (lines ~270-295)
%   L10 Code container visual styles (tcolorbox)         (lines ~295-435)
%   L11 Typographic system (titles, lists, note boxes)   (lines ~435-500)
%   L12 Float and diagram system                         (lines ~500-870)
%   L13 Metadata and multi-author system                 (lines ~870-1170)
%   L14 Title page and running header/footer             (lines ~1170-1235)
%   L15 Code backends (minted/listings, on-demand)       (lines ~1235-end)

% !TEX TS-program = xelatex
% !TEX encoding = UTF-8
% !Mode:: "TeX:UTF-8"

%% ============================================================
%% L1: Class declaration, XeLaTeX engine guard, option system
%% ============================================================

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{SUSTechHomework}[2026/04/04 Modernized SUSTech report template]

\RequirePackage{iftex}
\ifXeTeX\else
  \ClassError{SUSTechHomework}{This class requires XeLaTeX}{Please compile the document with XeLaTeX.}
\fi

\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=sustech,prefix=sustech@}
\DeclareStringOption[listings]{code}
\DeclareStringOption[sustech]{theme}
\DeclareStringOption[auto]{lang}
\DeclareStringOption[simple]{titlepage}
\DeclareStringOption[]{logo}
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessKeyvalOptions*

\LoadClass[a4paper]{article}

%% ============================================================
%% L2: Always-loaded packages
%% Packages here are unconditionally required by all documents.
%% On-demand packages (biblatex, minted, listings) are loaded
%% later in their respective layer sections.
%% ============================================================

\RequirePackage{etoolbox}
\RequirePackage{geometry}
\RequirePackage{graphicx}
\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{mathtools}
\RequirePackage{siunitx}
\RequirePackage{xcolor}
\RequirePackage{fontspec}
\RequirePackage{xeCJK}
\RequirePackage{fancyhdr}
\RequirePackage{lastpage}
\RequirePackage{booktabs}
\RequirePackage{colortbl}
\RequirePackage{caption}
\RequirePackage{subcaption}
\RequirePackage{overpic}
\RequirePackage{parskip}
\RequirePackage{tcolorbox}
% Load only the tcolorbox libraries that are always needed.
% The minted library is intentionally deferred: it requires minted.sty to be
% present and is only loaded when code=minted is active (see backend section).
\tcbuselibrary{breakable,listings,skins}
\RequirePackage{titlesec}
\RequirePackage{enumitem}
\RequirePackage{xparse}
\RequirePackage{hyperref}
\RequirePackage[nameinlink,noabbrev]{cleveref}
\usetikzlibrary{arrows.meta,positioning,shapes.geometric,shapes.symbols}

\newif\ifsustech@useminted
\newif\ifsustech@biblatexloaded
\let\sustech@realaddbibresource\relax

\newcommand{\sustech@validateoptions}{%
  \ifdefstring{\sustech@code}{minted}{%
    \sustech@usemintedtrue
  }{%
    \ifdefstring{\sustech@code}{listings}{%
      \sustech@usemintedfalse
    }{%
      \ClassWarning{SUSTechHomework}{Unknown code backend `\sustech@code'. Falling back to `listings'.}%
      \def\sustech@code{listings}%
      \sustech@usemintedfalse
    }%
  }%
  \ifdefstring{\sustech@theme}{sustech}{}{%
    \ifdefstring{\sustech@theme}{light}{}{%
      \ClassWarning{SUSTechHomework}{Unknown theme `\sustech@theme'. Falling back to `sustech'.}%
      \def\sustech@theme{sustech}%
    }%
  }%
  \ifdefstring{\sustech@titlepage}{simple}{}{%
    \ifdefstring{\sustech@titlepage}{formal}{}{%
      \ClassWarning{SUSTechHomework}{Unknown titlepage mode `\sustech@titlepage'. Falling back to `simple'.}%
      \def\sustech@titlepage{simple}%
    }%
  }%
  \ifdefstring{\sustech@lang}{auto}{}{%
    \ifdefstring{\sustech@lang}{zh}{}{%
      \ifdefstring{\sustech@lang}{en}{}{%
        \ifdefstring{\sustech@lang}{bilingual}{}{%
          \ClassWarning{SUSTechHomework}{Unknown lang `\sustech@lang'. Falling back to `auto'.}%
          \def\sustech@lang{auto}%
        }%
      }%
    }%
  }%
}
\sustech@validateoptions

%% ============================================================
%% L3: Page geometry and global spacing
%% ============================================================

\geometry{
  left=.85in,
  right=.85in,
  top=1in,
  bottom=.8in,
  bindingoffset=.15in
}

\setlength{\parindent}{0pt}
\setlength{\headheight}{19pt}
\linespread{1.08}\selectfont

%% ============================================================
%% L4: Font configuration — Western (fontspec) and CJK (xeCJK)
%% Priority order: system fonts first, TeX distribution as fallback.
%% ============================================================

\defaultfontfeatures{Ligatures=TeX,Scale=MatchLowercase}

\IfFontExistsTF{TeX Gyre Pagella}{%
  \setmainfont{TeX Gyre Pagella}%
}{}

\IfFontExistsTF{TeX Gyre Heros}{%
  \setsansfont{TeX Gyre Heros}%
}{}

% Prefer platform fonts first, then fall back to TeX-distributed CJK fonts.
\newcommand{\sustech@setcjkfonts}[1]{%
  \setCJKmainfont{#1}%
  \setCJKsansfont{#1}%
  \setCJKmonofont{#1}%
}

\IfFontExistsTF{Songti SC}{%
  \sustech@setcjkfonts{Songti SC}%
}{%
  \IfFontExistsTF{PingFang SC}{%
    \sustech@setcjkfonts{PingFang SC}%
  }{%
    \IfFontExistsTF{FandolSong-Regular}{%
      \sustech@setcjkfonts{FandolSong-Regular}%
    }{}%
  }%
}

%% ============================================================
%% L5: Color palette, brand tokens, and theme system
%% SUSTechPrimary / SUSTechAccent / SUSTechAuxiliary are the
%% canonical aliases. All visual components reference these.
%% ============================================================

\definecolor{SUSTechGreen}{HTML}{003F43}
\definecolor{SUSTechOrange}{HTML}{ED6C00}
\definecolor{SUSTechCyan}{HTML}{2BB7B3}
% Auxiliary VIS color (legacy alias kept for compatibility).
\colorlet{SUSTechAtlantisGreen}{SUSTechCyan}
\definecolor{SUSTechDark}{HTML}{1E293B}
\definecolor{SUSTechMuted}{HTML}{64748B}
\definecolor{SUSTechBorder}{HTML}{CBD5E1}
\definecolor{SUSTechCodeBg}{HTML}{F8FAFC}
\definecolor{SUSTechCodeTitleBg}{HTML}{F2F7F7}
\definecolor{SUSTechShellBg}{HTML}{0F172A}
\definecolor{SUSTechShellText}{HTML}{E2E8F0}
\definecolor{SUSTechInlineCodeBg}{HTML}{F2F7F7}
\definecolor{SUSTechInfoBg}{HTML}{F2F7F7}
\definecolor{SUSTechWarnBg}{HTML}{FFF1E6}
\definecolor{SUSTechTableHeaderBg}{HTML}{F2F7F7}
% VIS: primary structure = SUSTech Green; emphasis = Orange; auxiliary = Cyan.
\colorlet{SUSTechPrimary}{SUSTechGreen}
\colorlet{SUSTechAccent}{SUSTechOrange}
\colorlet{SUSTechAuxiliary}{SUSTechCyan}
% Diff view: semantic green/red tokens. Kept intentionally subdued to stay
% readable against white and against the code background.
\definecolor{SUSTechDiffAdd}{HTML}{15803D}
\definecolor{SUSTechDiffDel}{HTML}{B91C1C}
\definecolor{SUSTechDiffHunk}{HTML}{1D4ED8}
\definecolor{SUSTechDiffAddBg}{HTML}{F0FDF4}
\definecolor{SUSTechDiffDelBg}{HTML}{FFF1F2}

% Softer neutrals for theme=light while keeping brand colors unchanged.
\newcommand{\sustech@applytheme}{%
  \ifdefstring{\sustech@theme}{light}{%
    \definecolor{SUSTechDark}{HTML}{334155}%
    \definecolor{SUSTechMuted}{HTML}{94A3B8}%
    \definecolor{SUSTechBorder}{HTML}{E2E8F0}%
    \definecolor{SUSTechCodeBg}{HTML}{FCFCFD}%
    \definecolor{SUSTechCodeTitleBg}{HTML}{F2F7F7}%
    \definecolor{SUSTechInfoBg}{HTML}{F2F7F7}%
    \definecolor{SUSTechWarnBg}{HTML}{FFF4ED}%
    \definecolor{SUSTechTableHeaderBg}{HTML}{F2F7F7}%
    \definecolor{SUSTechInlineCodeBg}{HTML}{F2F7F7}%
  }{}%
}
\sustech@applytheme

%% ============================================================
%% L6: Hyperref base config + URL style
%% Full PDF metadata (title, author, subject) is injected later
%% at \maketitle time once all metadata fields are resolved.
%% ============================================================

\hypersetup{
  unicode=true,
  colorlinks=true,
  linkcolor=SUSTechPrimary,
  citecolor=SUSTechPrimary,
  urlcolor=SUSTechAccent,
  linktoc=all,
  bookmarksopen=true,
  bookmarksnumbered=true,
  pdfdisplaydoctitle=true,
  pdfstartview=FitH
}
\urlstyle{same}

%% ============================================================
%% L7: Math and unit system
%% Semantic primitives: \vect, \mat, \diff, \e, \ii, etc.
%% \siunitx base config. No physics package (conflicts with siunitx).
%% NOTE: \e, \ii, \vect, \mat are public non-prefixed commands.
%% They are intentional convenience aliases; document users should
%% avoid redefining them. A \sustech-prefixed version is not
%% provided to keep equation source readable.
%% ============================================================

% Equation numbers use SUSTech Orange trim (VIS). Do not call \makeatother here:
% this .cls relies on @-letter for internal command names below.
\makeatletter
\def\tagform@#1{\maketag@@@{\textcolor{SUSTechAccent}{(#1)}}}

\sisetup{
  detect-all,
  per-mode=symbol
}

% Provide stable math primitives without pulling in heavier opinionated packages.
\DeclarePairedDelimiter{\abs}{\lvert}{\rvert}
\DeclarePairedDelimiter{\norm}{\lVert}{\rVert}
\DeclarePairedDelimiter{\paren}{\lparen}{\rparen}
\DeclarePairedDelimiter{\bracket}{\lbrack}{\rbrack}
\DeclarePairedDelimiter{\set}{\lbrace}{\rbrace}
\NewDocumentCommand{\vect}{m}{\boldsymbol{#1}}
\NewDocumentCommand{\mat}{m}{\mathbf{#1}}
\NewDocumentCommand{\trans}{}{\mathsf{T}}
\NewDocumentCommand{\hermitian}{}{\mathsf{H}}
\NewDocumentCommand{\diff}{}{\mathop{}\!\mathrm{d}}
\NewDocumentCommand{\e}{}{\mathrm{e}}
\NewDocumentCommand{\ii}{}{\mathrm{i}}

%% ============================================================
%% L8: Bibliography system (on-demand via \addbibresource)
%% biblatex + biber are NOT loaded unless the user calls
%% \addbibresource{}. This keeps clean documents fast.
%% ============================================================

\newcommand{\sustech@bibtitle}{References}
\ifdefstring{\sustech@lang}{zh}{%
  \renewcommand{\sustech@bibtitle}{参考文献}%
}{%
  \ifdefstring{\sustech@lang}{bilingual}{%
    \renewcommand{\sustech@bibtitle}{References / 参考文献}%
  }{}%
}
\newcommand{\sustech@bibliographyrequiredmessage}[1]{%
  \ClassError{SUSTechHomework}{Bibliography command #1 requires \string\addbibresource\space in the preamble}{Add \string\addbibresource{...} before \string\begin{document} so the template can load biblatex only when needed.}%
}
\NewDocumentCommand{\sustechprintbibliography}{O{}}{%
  \sustech@bibliographyrequiredmessage{\string\sustechprintbibliography}%
}
\newcommand{\sustech@loadbiblatex}{%
  \ifsustech@biblatexloaded\else
    \global\sustech@biblatexloadedtrue
    \RequirePackage{xurl}%
    \csundef{addbibresource}%
    \RequirePackage[
      backend=biber,
      style=numeric,
      sorting=nyt,
      giveninits=true,
      maxbibnames=99,
      doi=true,
      url=true,
      isbn=false
    ]{biblatex}%
    \let\sustech@realaddbibresource\addbibresource
    \RenewDocumentCommand{\addbibresource}{m}{%
      \sustech@realaddbibresource{##1}%
    }%
    \DefineBibliographyStrings{english}{%
      urlseen = {accessed}%
    }%
    \DeclareFieldFormat{doi}{%
      DOI\addcolon\space\href{https://doi.org/##1}{\nolinkurl{##1}}%
    }%
    \DeclareFieldFormat{url}{\url{##1}}%
    \RenewDocumentCommand{\sustechprintbibliography}{O{}}{%
      \printbibliography[heading=bibintoc,title={\sustech@bibtitle},##1]%
    }%
  \fi
}
\NewDocumentCommand{\addbibresource}{m}{%
  \sustech@loadbiblatex
  \sustech@realaddbibresource{#1}%
}

%% ============================================================
%% L9: Figure and table caption system
%% ============================================================

\captionsetup{
  font=small,
  labelfont={sf,bf,color=SUSTechPrimary},
  textfont={sf,color=SUSTechDark},
  labelsep=quad
}

\captionsetup[figure]{justification=centering}
\captionsetup[table]{justification=raggedright,singlelinecheck=false}
\captionsetup[subfigure]{
  font=small,
  labelfont={sf,bf,color=SUSTechPrimary},
  textfont={sf,color=SUSTechDark},
  justification=centering,
  singlelinecheck=false
}
\captionsetup[subtable]{
  font=small,
  labelfont={sf,bf,color=SUSTechPrimary},
  textfont={sf,color=SUSTechDark},
  justification=raggedright,
  singlelinecheck=false
}

%% ============================================================
%% L10: Code container visual styles (tcolorbox)
%% Defines the tcolorbox styles and inline code box used by
%% both minted and listings backends. Backend environments
%% (sustechcode, sustechshell, etc.) are defined in L15.
%% ============================================================

\tcbset{
  sustechcodebox/.style={
    enhanced,
    breakable,
    boxrule=0.55pt,
    arc=2mm,
    colback=SUSTechCodeBg,
    colframe=SUSTechBorder,
    borderline west={1.5pt}{0pt}{SUSTechPrimary},
    left=1.2mm,
    right=1.2mm,
    top=0.9mm,
    bottom=0.9mm,
    fonttitle=\sffamily\bfseries\small,
    coltitle=SUSTechDark,
    colbacktitle=SUSTechCodeTitleBg,
    attach boxed title to top left={xshift=1.2mm,yshift*=-\tcboxedtitleheight/2},
    boxed title style={
      boxrule=0.45pt,
      arc=1.4mm,
      colframe=SUSTechPrimary,
      colback=SUSTechCodeTitleBg,
      left=1.1mm,
      right=1.1mm,
      top=0.45mm,
      bottom=0.45mm
    }
  },
  sustechshellbox/.style={
    enhanced,
    breakable,
    boxrule=0.55pt,
    arc=2mm,
    colback=SUSTechShellBg,
    colframe=SUSTechShellBg,
    borderline west={1.5pt}{0pt}{SUSTechPrimary},
    left=1.2mm,
    right=1.2mm,
    top=0.9mm,
    bottom=0.9mm,
    fonttitle=\sffamily\bfseries\small,
    coltitle=white,
    colbacktitle=SUSTechPrimary,
    attach boxed title to top left={xshift=1.2mm,yshift*=-\tcboxedtitleheight/2},
    boxed title style={
      boxrule=0pt,
      arc=1.4mm,
      colframe=SUSTechPrimary,
      colback=SUSTechPrimary,
      left=1.1mm,
      right=1.1mm,
      top=0.45mm,
      bottom=0.45mm
    }
  }
}

\newtcbox{\sustechinlinecodebox}{
  on line,
  boxrule=0.35pt,
  arc=1.1mm,
  colback=SUSTechInlineCodeBg,
  colframe=SUSTechBorder,
  left=0.55mm,
  right=0.55mm,
  top=0.15mm,
  bottom=0.15mm,
  boxsep=0pt
}

\newcounter{sustechlisting}
\renewcommand{\thesustechlisting}{\arabic{sustechlisting}}
\providecommand{\sustechlistingautorefname}{Code}
\crefname{section}{Section}{Sections}
\Crefname{section}{Section}{Sections}
\crefname{subsection}{Section}{Sections}
\Crefname{subsection}{Section}{Sections}
\crefname{subsubsection}{Section}{Sections}
\Crefname{subsubsection}{Section}{Sections}
\crefname{figure}{Figure}{Figures}
\Crefname{figure}{Figure}{Figures}
\crefname{subfigure}{Figure}{Figures}
\Crefname{subfigure}{Figure}{Figures}
\crefname{table}{Table}{Tables}
\Crefname{table}{Table}{Tables}
\crefname{subtable}{Table}{Tables}
\Crefname{subtable}{Table}{Tables}
\crefname{equation}{Equation}{Equations}
\Crefname{equation}{Equation}{Equations}
\crefname{sustechlisting}{Code}{Codes}
\Crefname{sustechlisting}{Code}{Codes}
\providecommand{\sustechcoderef}[1]{\cref{#1}}

\NewDocumentCommand{\sustechcodetitlecontent}{m m}{%
  {\sffamily\bfseries\small #1}%
  \ifstrempty{#2}{}{\hfill{\ttfamily\scriptsize\nolinkurl{#2}}}%
}

\NewDocumentCommand{\sustechcodecontext}{m o}{%
  \begin{tcolorbox}[
    enhanced,
    boxrule=0.45pt,
    arc=1.4mm,
    colback=SUSTechCodeTitleBg,
    colframe=SUSTechBorder,
    left=1.1mm,
    right=1.1mm,
    top=0.55mm,
    bottom=0.55mm,
    before skip=0.5em,
    after skip=0.35em
  ]
    {\sffamily\bfseries\small\color{SUSTechDark}#1}%
    \IfValueT{#2}{\hfill{\ttfamily\scriptsize\color{SUSTechMuted}#2}}%
  \end{tcolorbox}%
}

\NewDocumentCommand{\sustechcodeanchor}{m}{%
  \refstepcounter{sustechlisting}%
  \label{#1}%
}

\NewDocumentCommand{\sustechcodecaption}{O{} m}{%
  \refstepcounter{sustechlisting}%
  \ifstrempty{#1}{}{\label{#1}}%
  \par\noindent
  \smallskip
  {\small\sffamily
    \textcolor{SUSTechPrimary}{\bfseries Code~\thesustechlisting}\quad
    \textcolor{SUSTechMuted}{#2}%
  }\par
}

\NewDocumentCommand{\sustechmaybeinsertcodecaption}{m m}{%
  \ifstrempty{#1}{%
    \ifstrempty{#2}{}{\sustechcodeanchor{#2}}%
  }{%
    \sustechcodecaption[#2]{#1}%
  }%
}

%% ============================================================
%% L11: Typographic system — section titles, lists, note boxes
%% ============================================================

\titleformat{\section}
  {\Large\sffamily\bfseries\color{SUSTechPrimary}}
  {\thesection}
  {0.7em}
  {}

\titleformat{\subsection}
  {\large\sffamily\bfseries\color{SUSTechPrimary}}
  {\thesubsection}
  {0.65em}
  {}

\titleformat{\subsubsection}
  {\normalsize\sffamily\bfseries\color{SUSTechDark}}
  {\thesubsubsection}
  {0.6em}
  {}

\titlespacing*{\section}{0pt}{1.4em}{0.7em}
\titlespacing*{\subsection}{0pt}{1.1em}{0.55em}
\titlespacing*{\subsubsection}{0pt}{0.9em}{0.4em}

\setlist[itemize]{
  leftmargin=1.8em,
  itemsep=0.3em,
  topsep=0.45em,
  label=\textcolor{SUSTechPrimary}{\small\textbullet}
}

\setlist[enumerate]{
  leftmargin=2.2em,
  itemsep=0.3em,
  topsep=0.45em,
  label=\textcolor{SUSTechPrimary}{\arabic*.}
}

\newtcolorbox{sustechnote}[1][]{
  breakable,
  colback=SUSTechInfoBg,
  colframe=SUSTechPrimary,
  boxrule=0.7pt,
  arc=2mm,
  left=1.2mm,
  right=1.2mm,
  top=1mm,
  bottom=1mm,
  title=Note,
  fonttitle=\sffamily\bfseries,
  coltitle=SUSTechPrimary,
  #1
}

\newtcolorbox{sustechwarning}[1][]{
  breakable,
  colback=SUSTechWarnBg,
  colframe=SUSTechAccent,
  boxrule=0.7pt,
  arc=2mm,
  left=1.2mm,
  right=1.2mm,
  top=1mm,
  bottom=1mm,
  title=Warning,
  fonttitle=\sffamily\bfseries,
  coltitle=SUSTechAccent,
  #1
}

\newtcolorbox{sustechaside}[1][]{
  breakable,
  colback=white,
  colframe=SUSTechBorder,
  boxrule=0.4pt,
  borderline west={1.6pt}{0pt}{SUSTechPrimary},
  arc=1.5mm,
  left=1.6mm,
  right=1.4mm,
  top=1.1mm,
  bottom=1.1mm,
  #1
}

\newcommand{\sustechthead}[1]{%
  {\sffamily\bfseries\color{SUSTechDark}#1}%
}

%% ============================================================
%% L12: Float and diagram system
%% Subfigure/subtable groups, wide floats, overpic annotations,
%% side-by-side layouts, and TikZ diagram template library.
%% ============================================================

\newcommand{\sustechheaderrow}{%
  \rowcolor{SUSTechTableHeaderBg}%
}

\newcommand{\sustechtableheader}[1]{%
  \sustechthead{#1}%
}

\NewDocumentCommand{\sustechfloatsep}{}{%
  \hfill
}

\NewDocumentCommand{\sustechplaceholdergraphic}{O{\linewidth} O{3cm}}{%
  \fbox{\rule{0pt}{#2}\rule{#1}{0pt}}%
}

\NewDocumentCommand{\sustechoverlaylabel}{m}{%
  \begingroup
    \setlength{\fboxsep}{3pt}%
    \colorbox{SUSTechPrimary}{%
      \color{white}\sffamily\bfseries\scriptsize #1%
    }%
  \endgroup
}

\NewDocumentCommand{\sustechoverlaytext}{m}{%
  {\color{SUSTechPrimary}\sffamily\bfseries\scriptsize #1}%
}

\NewDocumentCommand{\sustechannotate}{m m m}{%
  \put(#1,#2){\makebox(0,0)[lb]{\sustechoverlaylabel{#3}}}%
}

\NewDocumentCommand{\sustechannotatetext}{m m m}{%
  \put(#1,#2){\makebox(0,0)[lb]{\sustechoverlaytext{#3}}}%
}

\NewDocumentCommand{\sustechsidebyside}{O{0.58\linewidth} O{0.36\linewidth} +m +m}{%
  \begin{minipage}[t]{#1}
    \centering
    #3
  \end{minipage}\hfill
  \begin{minipage}[t]{#2}
    \raggedright
    #4
  \end{minipage}%
}

\NewDocumentCommand{\sustechasideheading}{m}{%
  {\sffamily\bfseries\color{SUSTechPrimary}#1}\par
}

\NewDocumentCommand{\sustechfigurewithaside}{O{htbp} O{0.58\linewidth} O{0.36\linewidth} +m +m m}{%
  \begin{figure}[#1]
    \centering
    \sustechsidebyside[#2][#3]{#4}{#5}
    \caption{#6}
  \end{figure}
}

\NewDocumentCommand{\sustechtablewithaside}{O{htbp} O{0.56\linewidth} O{0.38\linewidth} +m +m m}{%
  \begin{table}[#1]
    \centering
    \sustechsidebyside[#2][#3]{#4}{#5}
    \caption{#6}
  \end{table}
}

\tikzset{
  sustech diagram base/.style={
    font=\small\sffamily,
    line width=0.7pt,
    draw=SUSTechBorder,
    text=SUSTechDark,
    align=center
  },
  sustech flow arrow/.style={
    draw=SUSTechPrimary,
    line width=0.9pt,
    -{Latex[length=2.5mm,width=1.8mm]}
  },
  sustech feedback arrow/.style={
    sustech flow arrow,
    draw=SUSTechAccent,
    dashed
  },
  sustech auxiliary arrow/.style={
    sustech flow arrow,
    draw=SUSTechMuted,
    line width=0.75pt
  },
  sustech highlight arrow/.style={
    sustech flow arrow,
    draw=SUSTechAccent,
    line width=1.2pt
  },
  sustech callout arrow/.style={
    sustech auxiliary arrow,
    -{Latex[length=2mm,width=1.5mm]}
  },
  sustech edge label/.style={
    midway,
    fill=white,
    inner sep=1.5pt,
    text=SUSTechMuted,
    font=\scriptsize\sffamily
  },
  sustech process/.style={
    sustech diagram base,
    rectangle,
    rounded corners=2pt,
    fill=SUSTechInfoBg,
    minimum width=24mm,
    minimum height=8.5mm
  },
  sustech decision/.style={
    sustech diagram base,
    diamond,
    aspect=2,
    fill=SUSTechWarnBg,
    inner xsep=1.8ex,
    inner ysep=1.15ex
  },
  sustech terminator/.style={
    sustech diagram base,
    rectangle,
    rounded corners=5pt,
    fill=SUSTechTableHeaderBg,
    minimum width=24mm,
    minimum height=8.5mm
  },
  sustech io/.style={
    sustech diagram base,
    trapezium,
    trapezium left angle=75,
    trapezium right angle=105,
    fill=white,
    minimum width=26mm,
    minimum height=8.5mm
  },
  sustech datastore/.style={
    sustech diagram base,
    cylinder,
    shape border rotate=90,
    aspect=0.28,
    fill=white,
    minimum height=11mm,
    minimum width=16mm
  },
  sustech note node/.style={
    sustech diagram base,
    rectangle,
    rounded corners=2pt,
    fill=white,
    text width=34mm,
    inner sep=4pt
  },
  sustech module/.style={
    sustech process,
    fill=white,
    minimum width=28mm,
    minimum height=10mm
  },
  sustech layer/.style={
    sustech module,
    fill=SUSTechInfoBg,
    minimum width=26mm
  },
  sustech device/.style={
    sustech module,
    fill=white,
    minimum width=23mm
  },
  sustech phase/.style={
    sustech process,
    fill=SUSTechTableHeaderBg,
    minimum width=23mm
  },
  sustech timeline axis/.style={
    sustech auxiliary arrow,
    line width=1pt,
    draw=SUSTechBorder
  },
  sustech timeline point/.style={
    circle,
    fill=SUSTechPrimary,
    draw=SUSTechPrimary,
    minimum size=4.5mm,
    inner sep=0pt
  },
  sustech timeline title/.style={
    font=\small\sffamily\bfseries,
    text=SUSTechDark,
    align=center
  },
  sustech timeline note/.style={
    font=\scriptsize\sffamily,
    text=SUSTechMuted,
    align=center,
    text width=24mm
  }
}

\NewDocumentEnvironment{sustechdiagram}{O{}}{%
  \begin{tikzpicture}[
    node distance=11mm and 15mm,
    every node/.style={font=\small\sffamily},
    #1
  ]
}{%
  \end{tikzpicture}
}

\NewDocumentEnvironment{sustechsystemdiagram}{O{}}{%
  \begin{sustechdiagram}[node distance=11mm and 16mm,#1]
}{%
  \end{sustechdiagram}
}

\NewDocumentEnvironment{sustechpipelinediagram}{O{}}{%
  \begin{sustechdiagram}[node distance=9mm and 10mm,#1]
}{%
  \end{sustechdiagram}
}

\NewDocumentEnvironment{sustecharchitecturediagram}{O{}}{%
  \begin{sustechdiagram}[node distance=10mm and 7mm,#1]
}{%
  \end{sustechdiagram}
}

\NewDocumentEnvironment{sustechchaindiagram}{O{}}{%
  \begin{sustechdiagram}[node distance=10mm and 7mm,#1]
}{%
  \end{sustechdiagram}
}

\NewDocumentEnvironment{sustechoverviewtimeline}{O{}}{%
  \begin{tikzpicture}[
    x=2.3cm,
    y=1cm,
    every node/.style={font=\small\sffamily},
    #1
  ]
}{%
  \end{tikzpicture}
}

\NewDocumentCommand{\sustechmodulebox}{O{} m m m}{%
  \node[sustech module,#1] (#2) [#3] {#4};
}

\NewDocumentCommand{\sustechphasebox}{O{} m m m}{%
  \node[sustech phase,#1] (#2) [#3] {#4};
}

\NewDocumentCommand{\sustechtimelineaxis}{m m}{%
  \draw[sustech timeline axis] #1 -- #2;
}

\NewDocumentCommand{\sustechtimelineevent}{O{} m m m m}{%
  \node[sustech timeline point,#1] (#2) at #3 {};
  \node[sustech timeline title,above=3mm of #2] {#4};
  \node[sustech timeline note,below=3mm of #2] {#5};
}

\NewDocumentCommand{\sustechmodulerow}{O{sustech module} m m m}{%
  \def\sustech@rowprev{}%
  \foreach[count=\i] \sustech@label in {#4}{%
    \ifnum\i=1
      \node[#1] (#2-\i) [#3] {\sustech@label};
    \else
      \node[#1] (#2-\i) [right=of \sustech@rowprev] {\sustech@label};
    \fi
    \xdef\sustech@rowprev{#2-\i}%
  }%
}

\NewDocumentCommand{\sustechconnectwith}{m o m m}{%
  \IfValueTF{#2}{%
    \draw[#1] (#3) -- node[sustech edge label]{#2} (#4);
  }{%
    \draw[#1] (#3) -- (#4);
  }%
}

\NewDocumentCommand{\sustechconnect}{o m m}{%
  \sustechconnectwith{sustech flow arrow}[#1]{#2}{#3}%
}

\NewDocumentCommand{\sustechconnecttowith}{m O{} o m m}{%
  \IfValueTF{#3}{%
    \path (#4) edge[#1,#2] node[sustech edge label]{#3} (#5);
  }{%
    \path (#4) edge[#1,#2] (#5);
  }%
}

\NewDocumentCommand{\sustechconnectto}{O{} o m m}{%
  \sustechconnecttowith{sustech flow arrow}[#1][#2]{#3}{#4}%
}

\NewDocumentEnvironment{sustechfiguregroup}{O{htbp}}{%
  \begin{figure}[#1]
    \centering
}{%
  \end{figure}
}

\NewDocumentEnvironment{sustechtablegroup}{O{htbp}}{%
  \begin{table}[#1]
    \centering
}{%
  \end{table}
}

\NewDocumentEnvironment{sustechwidefigure}{O{t}}{%
  \begin{figure*}[#1]
    \centering
}{%
  \end{figure*}
}

\NewDocumentEnvironment{sustechwidetable}{O{t}}{%
  \begin{table*}[#1]
    \centering
}{%
  \end{table*}
}

\NewDocumentEnvironment{sustechsubfigure}{O{0.48\linewidth} o}{%
  \begin{subfigure}[t]{#1}
    \centering
}{%
    \IfValueT{#2}{\caption{#2}}
  \end{subfigure}
}

\NewDocumentEnvironment{sustechsubtable}{O{0.48\linewidth} o}{%
  \begin{subtable}[t]{#1}
    \centering
}{%
    \IfValueT{#2}{\caption{#2}}
  \end{subtable}
}

\NewDocumentEnvironment{sustechoverpic}{O{\linewidth} m}{%
  \begin{overpic}[width=#1]{#2}
}{%
  \end{overpic}
}

%% ============================================================
%% L13: Metadata and multi-author system
%% Single-author legacy fields (\sid, \coursename, etc.) and
%% the structured multi-author API (\clearauthors/\addauthor).
%% ============================================================

% Single-value metadata setters follow the standard LaTeX class \def pattern:
%   \def\<field>#1{\gdef\@<field>{#1}}   -- user-facing setter
%   \def\@<field>{<default>}             -- internal storage with default
% This is intentional: \def always overwrites, which is the correct behavior
% for class-level metadata commands. Do NOT convert to \newcommand (would
% error if a package has pre-defined the same name) or \providecommand
% (would silently do nothing on re-definition).
%
% Public fields (documented in README):
%   \sid / \studentid  \coursename  \coursecode  \semester
%   \instructor        \department  \college     \email    \reporttype
%
% Internal / underdocumented:
%   \univ -- sets the university name token used in two-side page headers.
%   Intentionally not in README; advanced users may override if needed.

\def\sid#1{\gdef\@sid{#1}}
\def\@sid{}
% \studentid is a legacy alias for \sid kept for backward compatibility.
\newcommand{\studentid}[1]{\sid{#1}}

\def\coursename#1{\gdef\@coursename{#1}}
\def\@coursename{\@latex@error{No \noexpand\coursename given}\@ehc}

\def\coursecode#1{\gdef\@coursecode{#1}}
\def\@coursecode{\@latex@error{No \noexpand\coursecode given}\@ehc}

% \univ is an internal override hook, not part of the primary public API.
\def\univ#1{\gdef\@univ{#1}}
\def\@univ{SUSTech}

% ---- Logo rendering size (controls how large the image is drawn) ----
% \sustechformallogosize{max-width}{max-height} -- formal cover page
% \sustechsimplelogosize{max-height}            -- simple inline title
% The image is always kept at its original aspect ratio (keepaspectratio).
\def\sustech@formalogowidth{0.52\linewidth}
\def\sustech@formalogoheight{3.5cm}
\def\sustech@simplelogoheight{2.2cm}
\newcommand{\sustechformallogosize}[2]{%
  \def\sustech@formalogowidth{#1}%
  \def\sustech@formalogoheight{#2}%
}
\newcommand{\sustechsimplelogosize}[1]{\def\sustech@simplelogoheight{#1}}

% ---- Logo overlay position (TikZ anchor on current page, zero impact on flow) ----
% \sustechlogopos{x-offset}{y-offset}: shifts the overlay node from page top-center.
%   TikZ convention: positive x = right, positive y = up.
%   Default: centered, top-edge of logo sits 1.8 cm below the page top edge.
\def\sustech@logox{0cm}
\def\sustech@logoy{-1.8cm}
\newcommand{\sustechlogopos}[2]{%
  \def\sustech@logox{#1}%
  \def\sustech@logoy{#2}%
}

% ---- Vertical space reserved in the content flow (independent of logo size/position) ----
% Changing logo size or position does NOT move the title/author block.
% Adjust only when you want to shift the entire content block up or down.
% \sustechlogospace{height}       -- formal title (default 3.5cm)
% \sustechsimplelogospace{height} -- simple title (default 2.2cm)
\def\sustech@logospaceh{3.5cm}
\def\sustech@simplelogospace{2.2cm}
\newcommand{\sustechlogospace}[1]{\def\sustech@logospaceh{#1}}
\newcommand{\sustechsimplelogospace}[1]{\def\sustech@simplelogospace{#1}}

\def\semester#1{\gdef\@semester{#1}}
\def\@semester{}

\def\instructor#1{\gdef\@instructor{#1}}
\def\@instructor{}

\def\department#1{\gdef\@department{#1}}
\def\@department{}

\def\college#1{\gdef\@college{#1}}
\def\@college{}

\def\email#1{\gdef\@email{#1}}
\def\@email{}

\def\reporttype#1{\gdef\@reporttype{#1}}
\def\@reporttype{Course Report}

\newcounter{sustech@authorcount}
\newcounter{sustech@creditcount}
\newcounter{sustech@contributioncount}
\def\sustech@authorentries{}
\def\sustech@authorgridcontent{}
\def\sustech@titleauthors{}
\def\sustech@pdfauthors{}
\def\sustech@creditentries{}
\def\sustech@contributionentries{}

\newcommand{\clearauthors}{%
  \setcounter{sustech@authorcount}{0}%
  \gdef\sustech@authorentries{}%
  \gdef\sustech@authorgridcontent{}%
  \gdef\sustech@titleauthors{}%
  \gdef\sustech@pdfauthors{}%
}

\newcommand{\clearcredits}{%
  \setcounter{sustech@creditcount}{0}%
  \gdef\sustech@creditentries{}%
}

\newcommand{\clearcontributions}{%
  \setcounter{sustech@contributioncount}{0}%
  \gdef\sustech@contributionentries{}%
}

\newcommand{\sustech@appendtitleauthor}[2]{%
  \ifdefempty{\sustech@titleauthors}{%
    \gdef\sustech@titleauthors{\sustech@titleauthorentry{#1}{#2}}%
  }{%
    \g@addto@macro\sustech@titleauthors{\sustech@titleauthorentry{#1}{#2}}%
  }%
}

\newcommand{\sustech@appendpdfauthor}[1]{%
  \ifdefempty{\sustech@pdfauthors}{%
    \gdef\sustech@pdfauthors{#1}%
  }{%
    \g@addto@macro\sustech@pdfauthors{; #1}%
  }%
}

\newcommand{\sustech@authorentry}[6]{%
  \par\noindent
  {\normalsize\sffamily\bfseries\color{SUSTechDark} #1\par}%
  \ifblank{#2}{}{%
    {\small\color{SUSTechMuted}Student ID: #2\par}%
  }%
  \ifblank{#3}{}{%
    {\small\nolinkurl{#3}\par}%
  }%
  \ifblank{#4}{%
    \ifblank{#5}{}{%
      {\small #5\par}%
    }%
  }{%
    {\small #4\ifblank{#5}{}{ / #5}\par}%
  }%
  \ifblank{#6}{}{%
    {\small\color{SUSTechMuted}Role: #6\par}%
  }%
  \vspace{0.45em}%
}

\newcommand{\sustech@titleauthorentry}[2]{%
  {\small\sffamily\bfseries #1\par}%
  \ifblank{#2}{}{{\scriptsize\color{SUSTechMuted}#2\par}}%
  \vspace{0.25em}%
}

% Author card for the two-column grid on formal title pages.
% #1=name  #2=sid  #3=email  #4=department  #5=college  #6=role
% Layout: left accent border, name+role on first line, then contact details.
\newcommand{\sustech@authorgridcard}[6]{%
  \begin{tcolorbox}[
    enhanced,
    boxrule=0.4pt,
    arc=2mm,
    colback=white,
    colframe=SUSTechBorder,
    borderline west={2pt}{0pt}{SUSTechPrimary},
    left=2.5mm, right=2mm, top=1.8mm, bottom=1.5mm,
    before skip=0pt, after skip=0pt
  ]
    % Name and role on the same line (role right-aligned when present)
    \noindent
    {\small\sffamily\bfseries\color{SUSTechDark}#1}%
    \ifblank{#6}{}{\hfill{\scriptsize\itshape\color{SUSTechAccent}#6}}%
    \par
    % Contact row: email
    \ifblank{#3}{}{%
      \vspace{0.2em}%
      {\scriptsize\ttfamily\color{SUSTechMuted}#3\par}%
    }%
    % SID and dept/college on one condensed line
    \ifblank{#2#4#5}{}{%
      {\scriptsize\color{SUSTechMuted}%
        \ifblank{#2}{}{#2}%
        \ifblank{#4}{}{%
          \ifblank{#2}{}{\enspace\textbullet\enspace}%
          #4%
        }%
      \par}%
    }%
  \end{tcolorbox}%
}

\newcommand{\sustech@creditentry}[2]{%
  \par\noindent
  {\small\sffamily\bfseries\color{SUSTechDark} #1\par}%
  {\small\color{SUSTechMuted}#2\par}%
  \vspace{0.25em}%
}

\newcommand{\sustech@contributionentry}[2]{%
  \par\noindent
  {\small\sffamily\bfseries\color{SUSTechDark} #1\par}%
  {\small\color{SUSTechMuted}Roles: #2\par}%
  \vspace{0.25em}%
}

\newcommand{\sustech@teamlabel}{%
  Team Members (\arabic{sustech@authorcount})
}

\NewDocumentCommand{\addauthor}{m m m m m m}{%
  \stepcounter{sustech@authorcount}%
  \ifnum\value{sustech@authorcount}=1
    \gdef\@author{#1}%
    \gdef\@sid{#2}%
    \gdef\@email{#3}%
    \ifblank{#4}{}{\gdef\@department{#4}}%
    \ifblank{#5}{}{\gdef\@college{#5}}%
  \fi
  % Accumulate the vertical list used for single-author block and legacy paths.
  \g@addto@macro\sustech@authorentries{\sustech@authorentry{#1}{#2}{#3}{#4}{#5}{#6}\vspace{0.5em}}%
  % Accumulate two-column card grid content.
  % Odd-numbered authors start a new row (left column).
  % Even-numbered authors close the row (right column + paragraph break).
  \ifodd\value{sustech@authorcount}
    \g@addto@macro\sustech@authorgridcontent{%
      \noindent\begin{minipage}[t]{0.47\linewidth}%
        \sustech@authorgridcard{#1}{#2}{#3}{#4}{#5}{#6}%
      \end{minipage}%
    }%
  \else
    \g@addto@macro\sustech@authorgridcontent{%
      \hfill%
      \begin{minipage}[t]{0.47\linewidth}%
        \sustech@authorgridcard{#1}{#2}{#3}{#4}{#5}{#6}%
      \end{minipage}%
      \par\vspace{0.4em}%
    }%
  \fi
  \sustech@appendtitleauthor{#1}{#6}%
  \sustech@appendpdfauthor{#1}%
}

\NewDocumentCommand{\addcredit}{m m}{%
  \stepcounter{sustech@creditcount}%
  \g@addto@macro\sustech@creditentries{\sustech@creditentry{#1}{#2}}%
}

\NewDocumentCommand{\addcontribution}{m m}{%
  \stepcounter{sustech@contributioncount}%
  \g@addto@macro\sustech@contributionentries{\sustech@contributionentry{#1}{#2}}%
}

\newcommand{\sustech@twopartline}[2]{%
  \ifdefempty{#1}{#2}{#1\ifdefempty{#2}{}{ \,|\, #2}}%
}

\newcommand{\sustech@authorline}{%
  \ifnum\value{sustech@authorcount}>1
    \@author\ et al.
  \else
    \@author\ifdefempty{\@sid}{}{ / \@sid}%
  \fi
}

\newcommand{\sustech@courseline}{%
  \@coursecode\ifdefempty{\@coursename}{}{ \,|\, \@coursename}%
}

\newcommand{\sustech@runningtitle}{%
  \sustech@courseline\ifdefempty{\@title}{}{ \,|\, \@title}%
}

\newcommand{\sustech@pdfsubject}{%
  \@coursecode\ifdefempty{\@coursename}{}{ - \@coursename}%
}

\newcommand{\sustech@titleauthorblock}{%
  \ifnum\value{sustech@authorcount}>1
    {\small\sffamily\bfseries\color{SUSTechPrimary}\sustech@teamlabel\par}%
    \vspace{0.35em}%
    \sustech@titleauthors
  \else
    {\large\sffamily\bfseries\@author\par}%
    \ifdefempty{\@sid}{}{{\small\color{SUSTechMuted}\@sid\par}}%
    \ifdefempty{\@email}{}{{\small\ttfamily\@email\par}}%
  \fi
}

\newcommand{\sustech@formalauthorheading}{%
  {\small\sffamily\bfseries\color{SUSTechPrimary}%
    \ifnum\value{sustech@authorcount}>1
      \sustech@teamlabel
    \else
      Author
    \fi
  \par}%
  \vspace{0.2cm}%
}

\newcommand{\sustech@formalcreditheading}{%
  {\small\sffamily\bfseries\color{SUSTechPrimary}Contribution Summary\par}%
  \vspace{0.15cm}%
}

\newcommand{\sustech@formalcontributionheading}{%
  {\small\sffamily\bfseries\color{SUSTechPrimary}CRediT-style Contributions\par}%
  \vspace{0.15cm}%
}

\newcommand{\sustech@formalauthorblock}{%
  \ifnum\value{sustech@authorcount}>1
    % Multi-author: two-column card grid at full content width.
    \begin{minipage}{0.92\linewidth}
      \raggedright
      \sustech@formalauthorheading
      \sustech@authorgridcontent
      % Close the last unclosed row when author count is odd.
      \ifodd\value{sustech@authorcount}\par\fi
    \end{minipage}
  \else
    % Single author: centered full-detail block.
    \begin{minipage}{0.78\linewidth}
      \raggedright
      \sustech@formalauthorheading
      \ifnum\value{sustech@authorcount}>0
        \sustech@authorentries
      \else
        \sustech@authorentry{\@author}{\@sid}{\@email}{\@department}{\@college}{}%
      \fi
    \end{minipage}
  \fi
}

\newcommand{\sustech@formalcreditblock}{%
  \ifnum\value{sustech@creditcount}>0
    \begin{minipage}{0.78\linewidth}
      \raggedright
      \sustech@formalcreditheading
      \sustech@creditentries
    \end{minipage}
  \fi
}

\newcommand{\sustech@formalcontributionblock}{%
  \ifnum\value{sustech@contributioncount}>0
    \begin{minipage}{0.78\linewidth}
      \raggedright
      \sustech@formalcontributionheading
      \sustech@contributionentries
    \end{minipage}
  \fi
}

\newcommand{\sustech@detailline}[2]{%
  \ifdefempty{#2}{}{%
    {\sffamily\small\textcolor{SUSTechMuted}{#1:} #2\par}%
  }%
}

\newcommand{\sustech@simpletitle}{%
  % In simple mode, draw logo as a TikZ page overlay (zero height in flow).
  % Content position is controlled solely by \sustech@simplelogospace.
  \ifdefempty{\sustech@logo}{}{%
    \begin{tikzpicture}[remember picture, overlay]
      \node[anchor=north, xshift=\sustech@logox, yshift=\sustech@logoy]
        at (current page.north) {%
          \includegraphics[height=\sustech@simplelogoheight,keepaspectratio]{\sustech@logo}%
        };
    \end{tikzpicture}%
    % Reserve a fixed vertical gap; independent of logo size/position.
    \vspace*{\sustech@simplelogospace}\vspace{0.4em}%
  }%
  \noindent
  \makebox[\linewidth]{%
    \begin{minipage}[b]{.64\linewidth}
      {\Large\sffamily\color{SUSTechPrimary}\sustech@courseline\par}
      \vspace{0.35em}
      {\huge\bfseries\color{SUSTechDark}\@title\par}
      \vspace{0.55em}
      {\small\color{SUSTechMuted}%
        \sustech@twopartline{\@semester}{\@instructor}%
      \par}
    \end{minipage}\hfill
    \begin{minipage}[b]{.32\linewidth}
      \raggedleft
      \sustech@titleauthorblock
      \vspace{0.35em}
      {\small\@date\par}
    \end{minipage}%
  }
  \par\vspace{0.65em}
  \noindent\color{SUSTechPrimary}\rule{\linewidth}{1.5pt}
  \par\vspace{1.0em}
  \thispagestyle{empty}
}

\newcommand{\sustech@formaltitle}{%
  \thispagestyle{empty}
  \begingroup
    \centering
    \ifdefempty{\sustech@logo}{%
      {\Large\sffamily\color{SUSTechPrimary}\@univ\par}%
      \vspace{0.7cm}%
    }{%
      \begin{tikzpicture}[remember picture, overlay]
        \node[anchor=north, xshift=\sustech@logox, yshift=\sustech@logoy]
          at (current page.north) {%
            \includegraphics[width=\sustech@formalogowidth,height=\sustech@formalogoheight,keepaspectratio]{\sustech@logo}%
          };
      \end{tikzpicture}%
      \vspace*{\sustech@logospaceh}%
      \vspace{0.7cm}%
    }%
    {\large\sffamily\@reporttype\par}
    \vspace{0.35cm}
    {\Large\sffamily\color{SUSTechPrimary}\sustech@courseline\par}
    \vspace{0.6cm}
    {\Huge\bfseries\color{SUSTechDark}\@title\par}
    \vspace{0.8cm}
    \sustech@formalauthorblock
    % Contributions and credits are independent: show each block when non-empty
    % (previously credits were skipped whenever contributions existed).
    \ifnum\value{sustech@contributioncount}>0
      \vspace{0.35cm}%
      \sustech@formalcontributionblock
    \fi
    \ifnum\value{sustech@creditcount}>0
      \vspace{0.35cm}%
      \sustech@formalcreditblock
    \fi
    \vspace{0.35cm}
    \begin{minipage}{0.78\linewidth}
      \raggedright
      \sustech@detailline{Instructor}{\@instructor}
      \sustech@detailline{Semester}{\@semester}
    \end{minipage}\par
    \vfill
    {\@date\par}
  \endgroup
  \clearpage
  \setcounter{page}{1}%
}

% \mktitle is a LEGACY alias for \maketitle kept for backward compatibility
% with documents that used an older version of this class.
% New documents should always use \maketitle.
\newcommand{\mktitle}{%
  \sustech@applypdfmetadata
  \ifdefstring{\sustech@titlepage}{formal}{%
    \sustech@formaltitle
  }{%
    \sustech@simpletitle
  }%
}

\newcommand{\sustech@applypdfmetadata}{%
  \hypersetup{
    pdftitle={\@title},
    pdfauthor={\ifdefempty{\sustech@pdfauthors}{\@author}{\sustech@pdfauthors}},
    pdfsubject={\sustech@pdfsubject},
    pdfcreator={XeLaTeX with SUSTechHomework}
  }%
  \ifdefstring{\sustech@lang}{zh}{%
    \hypersetup{pdflang=zh-CN}%
  }{%
    \ifdefstring{\sustech@lang}{en}{%
      \hypersetup{pdflang=en-US}%
    }{%
      \ifdefstring{\sustech@lang}{bilingual}{%
        \hypersetup{pdflang=zh-CN}%
      }{}%
    }%
  }%
}

\renewcommand{\maketitle}{%
  \sustech@applypdfmetadata
  \ifdefstring{\sustech@titlepage}{formal}{%
    \sustech@formaltitle
  }{%
    \if@twocolumn
      \twocolumn[\sustech@simpletitle]%
    \else
      \sustech@simpletitle
    \fi
  }%
}

%% ============================================================
%% L14: Title page renderers and running header/footer
%% \maketitle dispatches to \sustech@simpletitle or
%% \sustech@formaltitle based on titlepage= option.
%% \mktitle is a legacy alias kept for backward compatibility.
%% ============================================================

\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0.3pt}
\renewcommand{\headrule}{%
  \hbox to\headwidth{\color{SUSTechPrimary}\leaders\hrule height \headrulewidth\hfill}%
}

\if@twoside
  \fancyhead[EL]{\footnotesize\sffamily\color{SUSTechPrimary}\sustech@courseline}
  \fancyhead[EC]{\footnotesize\sffamily\color{SUSTechMuted}\@title}
  \fancyhead[ER]{\footnotesize\sffamily\thepage/\pageref{LastPage}}
  \fancyhead[OL]{\footnotesize\sffamily\color{SUSTechPrimary}\sustech@authorline}
  \fancyhead[OC]{\footnotesize\sffamily\color{SUSTechMuted}\@univ}
  \fancyhead[OR]{\footnotesize\sffamily\thepage/\pageref{LastPage}}
\else
  \lhead{\footnotesize\sffamily\color{SUSTechPrimary}\sustech@authorline}
  \chead{\footnotesize\sffamily\color{SUSTechMuted}\sustech@runningtitle}
  \rhead{\footnotesize\sffamily\thepage/\pageref{LastPage}}
\fi

% ---- Code repository URL footer ----
% \codeurl{<url>}: when set, displays a clickable "Code available at: <url>"
% line in the page footer.  Leave unset (default) to keep the footer empty.
%
% \detokenize stores _ as catcode-12 so URLs with underscores never enter math
% mode when expanded.  \href provides a correct PDF URI.  The visible text uses
% \color (not \textcolor): \textcolor calls \leavevmode, which is unsafe inside
% fancyhdr's output-routine boxing context.
\def\sustech@codeurl{}
\newcommand{\codeurl}[1]{\edef\sustech@codeurl{\detokenize{#1}}}

\renewcommand{\footrulewidth}{0pt}
\AtBeginDocument{%
  \ifdefempty{\sustech@codeurl}{}{%
    \renewcommand{\footrulewidth}{0.3pt}%
    \renewcommand{\footrule}{%
      \hbox to\headwidth{%
        {\color{SUSTechPrimary!40}\leaders\hrule height\footrulewidth\hfill}%
      }%
    }%
    \lfoot{%
      {\footnotesize\sffamily
       \color{SUSTechMuted}Code available at:\enspace
       \href{\sustech@codeurl}{{\color{SUSTechPrimary}\ttfamily\sustech@codeurl}}}%
    }%
  }%
}

%% ============================================================
%% L15: Code backends (minted / listings, mutually exclusive)
%% Both backends define the same public environments:
%%   sustechcode, sustechshell, sustechcodeblock, sustechshellblock
%% Only one backend is active per document, controlled by code= option.
%% ============================================================

\ifsustech@useminted
  \IfFileExists{minted.sty}{%
    \RequirePackage{fvextra}
    \RequirePackage{minted}
    % Load the tcolorbox minted binding only after minted.sty is available.
    \tcbuselibrary{minted}
    \setminted{
      breaklines,
      autogobble,
      linenos,
      fontsize=\small,
      tabsize=2
    }
    \NewTCBListing{sustechcode}{O{} m}{
      sustechcodebox,
      listing engine=minted,
      listing only,
      breakable,
      title={#2},
      minted language=#2,
      minted options={
        bgcolor=SUSTechCodeBg,
        breaklines,
        autogobble,
        linenos,
        fontsize=\small,
        tabsize=2,
        #1
      }
    }
    \NewTCBListing{sustechshell}{O{}}{
      sustechshellbox,
      listing engine=minted,
      listing only,
      breakable,
      title={Shell},
      minted language=text,
      minted options={
        bgcolor=SUSTechShellBg,
        breaklines,
        autogobble,
        linenos=false,
        fontsize=\small,
        #1
      }
    }
    \NewTCBListing{sustechcodeblock}{m O{} O{} O{} O{}}{
      sustechcodebox,
      listing engine=minted,
      listing only,
      breakable,
      title={\sustechcodetitlecontent{\ifstrempty{#2}{#1}{#2}}{#3}},
      minted language=#1,
      minted options={
        bgcolor=SUSTechCodeBg,
        breaklines,
        autogobble,
        linenos,
        fontsize=\small,
        tabsize=2
      },
      after={\sustechmaybeinsertcodecaption{#4}{#5}}
    }
    \NewTCBListing{sustechshellblock}{O{Shell} O{} O{} O{}}{
      sustechshellbox,
      listing engine=minted,
      listing only,
      breakable,
      title={\sustechcodetitlecontent{#1}{#2}},
      minted language=text,
      minted options={
        bgcolor=SUSTechShellBg,
        breaklines,
        autogobble,
        linenos=false,
        fontsize=\small
      },
      after={\sustechmaybeinsertcodecaption{#3}{#4}}
    }
  }{%
    \ClassWarning{SUSTechHomework}{Option `code=minted' requested, but minted.sty was not found. Falling back to `listings'.}%
    \sustech@usemintedfalse
  }
\fi

\ifsustech@useminted\else
  \RequirePackage{listings}
  \lstdefinelanguage{json}{
    basicstyle=\small\ttfamily,
    showstringspaces=false,
    breaklines=true,
    morestring=[b]",
    stringstyle=\color{SUSTechAccent},
    literate=
      *{:}{{{\color{SUSTechMuted}{:}}}}{1}
       {,}{{{\color{SUSTechMuted}{,}}}}{1}
       {\{}{{{\color{SUSTechPrimary}{\{}}}}{1}
       {\}}{{{\color{SUSTechPrimary}{\}}}}}{1}
       {[}{{{\color{SUSTechPrimary}{[}}}}{1}
       {]}{{{\color{SUSTechPrimary}{]}}}}{1}
  }
  % Enhanced YAML: anchors/aliases, boolean/null keywords, list markers.
  \lstdefinelanguage{yaml}{
    basicstyle=\small\ttfamily,
    showstringspaces=false,
    breaklines=true,
    morecomment=[l]{\#},
    commentstyle=\color{SUSTechMuted},
    morestring=[b]",
    morestring=[b]',
    stringstyle=\color{SUSTechAccent},
    % Boolean and null values as keywords
    keywords={true, false, null, yes, no, on, off},
    keywordstyle=\color{SUSTechPrimary}\bfseries,
    sensitive=false,
    literate=
      *{:}{{{\color{SUSTechMuted}{:}}}}{1}
       {-}{{{\color{SUSTechPrimary}{-}}}}{1}
       {&}{{{\color{SUSTechAuxiliary}{\&}}}}{1}
       {*}{{{\color{SUSTechAuxiliary}{*}}}}{1}
       {|}{{{\color{SUSTechMuted}{|}}}}{1}
       {>}{{{\color{SUSTechMuted}{>}}}}{1}
  }
  % Modern C++ (C++11 through C++23 keywords on top of ANSI C++).
  % Internal dialect: [Modern]C++ (extends [ANSI]C++).
  % User-facing alias: moderncpp  (avoids bracket issues in listing options).
  \lstdefinelanguage{[Modern]C++}{
    language={[ANSI]C++},
    morekeywords={
      % C++11 core keywords
      auto, nullptr, constexpr, noexcept, override, final,
      static_assert, decltype, thread_local, alignas, alignof,
      % C++20 concepts and modules
      concept, requires, export, import, module,
      % C++20 coroutines
      co_await, co_return, co_yield,
      % Common fixed-width integer types
      int8_t, int16_t, int32_t, int64_t,
      uint8_t, uint16_t, uint32_t, uint64_t,
      size_t, ptrdiff_t, intptr_t, uintptr_t,
      % Smart pointers
      unique_ptr, shared_ptr, weak_ptr,
      % STL utilities commonly seen in code examples
      make_unique, make_shared, move, forward, declval
    }
  }
  % Bracket-free alias; use language=moderncpp in sustechcode/sustechlongcode.
  \lstalias{moderncpp}{[Modern]C++}
  % MATLAB: extended keyword list covering MATLAB R2020+ built-ins.
  % Internal dialect: [SUSTech]MATLAB.
  % User-facing alias: matlab  (avoids bracket issues in listing options).
  \lstdefinelanguage{[SUSTech]MATLAB}{
    keywords={
      break, case, catch, classdef, continue, else, elseif,
      end, for, function, global, if, methods, nargin, nargout,
      otherwise, parfor, persistent, properties, return, spmd,
      switch, try, while, arguments, events,
      % Common built-in functions treated as keywords for visual emphasis
      disp, fprintf, sprintf, num2str, str2num, str2double,
      size, length, numel, zeros, ones, eye, rand, randn,
      plot, hold, figure, subplot, xlabel, ylabel, title, legend,
      linspace, logspace, reshape, transpose, inv, det, eig, svd,
      sum, prod, max, min, abs, sqrt, exp, log, sin, cos, tan
    },
    keywordstyle=\color{SUSTechPrimary}\bfseries,
    comment=[l]{\%},
    morecomment=[l]{\%\%},
    commentstyle=\color{SUSTechAtlantisGreen},
    % Single-quoted strings (also used for transpose -- unavoidable ambiguity)
    morestring=[m]',
    morestring=[b]",
    stringstyle=\color{SUSTechAccent},
    sensitive=false
  }
  % Bracket-free alias; use language=matlab in sustechcode/sustechlongcode.
  \lstalias{matlab}{[SUSTech]MATLAB}
  % Unified diff format: +/- lines, @@ hunks, file headers.
  % Full-line coloring via morecomment=[f] (matches lines starting with token).
  % NOTE: +++ and --- (file headers) are colored by +/- rules -- intentional.
  \lstdefinelanguage{diff}{
    basicstyle=\small\ttfamily,
    showstringspaces=false,
    breaklines=true,
    % File headers and hunk markers
    morecomment=[f][\color{SUSTechDiffHunk}\bfseries]{@@},
    morecomment=[f][\color{SUSTechMuted}]{index },
    % Added and removed lines (also covers +++ / --- file header lines)
    morecomment=[f][\color{SUSTechDiffAdd}]{+},
    morecomment=[f][\color{SUSTechDiffDel}]{-},
    sensitive=true
  }
  \lstdefinestyle{sustechbase}{
    backgroundcolor=\color{SUSTechCodeBg},
    basicstyle=\small\ttfamily,
    aboveskip=0pt,
    belowskip=0pt,
    breaklines=true,
    columns=fullflexible,
    commentstyle=\color{SUSTechAtlantisGreen},
    frame=none,
    framesep=0pt,
    keepspaces=true,
    keywordstyle=\color{SUSTechPrimary}\bfseries,
    numbers=left,
    numbersep=8pt,
    numberstyle=\scriptsize\color{SUSTechMuted},
    rulecolor=\color{SUSTechBorder},
    showstringspaces=false,
    stringstyle=\color{SUSTechAccent},
    tabsize=2,
    xleftmargin=0.8em,
    framexleftmargin=0pt
  }
  \lstdefinestyle{sustechshell}{
    style=sustechbase,
    backgroundcolor=\color{SUSTechShellBg},
    basicstyle=\small\ttfamily\color{SUSTechShellText},
    commentstyle=\color{SUSTechShellText},
    keywordstyle=\color{SUSTechShellText},
    numbers=none,
    rulecolor=\color{SUSTechShellBg},
    stringstyle=\color{SUSTechShellText}
  }
  \NewTCBListing{sustechcode}{O{} m}{
    sustechcodebox,
    listing engine=listings,
    listing only,
    breakable,
    title={#2},
    listing options={style=sustechbase,language=#2,#1}
  }
  \NewTCBListing{sustechshell}{O{}}{
    sustechshellbox,
    listing engine=listings,
    listing only,
    breakable,
    title={Shell},
    listing options={style=sustechshell,#1}
  }
  \NewTCBListing{sustechcodeblock}{m O{} O{} O{} O{}}{
    sustechcodebox,
    listing engine=listings,
    listing only,
    breakable,
    title={\sustechcodetitlecontent{\ifstrempty{#2}{#1}{#2}}{#3}},
    listing options={style=sustechbase,language=#1},
    after={\sustechmaybeinsertcodecaption{#4}{#5}}
  }
  \NewTCBListing{sustechshellblock}{O{Shell} O{} O{} O{}}{
    sustechshellbox,
    listing engine=listings,
    listing only,
    breakable,
    title={\sustechcodetitlecontent{#1}{#2}},
    listing options={style=sustechshell},
    after={\sustechmaybeinsertcodecaption{#3}{#4}}
  }
\fi

%% ============================================================
%% L16: Extended code environments (both backends)
%% sustechlongcode / sustechlongshell -- multi-page code with
%%   automatic "continued" title on continuation pages.
%% sustechdiff / sustechdiffblock -- unified diff display
%%   using the diff language definition (listings) or lexer (minted).
%% Each environment dispatches to the active backend.
%% ============================================================

% Continuation title shown by sustechlongcode/sustechlongshell on break pages.
% #1 = original language/title label.
\newcommand{\sustech@codetitlecont}[1]{%
  {\sffamily\small\color{SUSTechMuted}#1\enspace\textit{(continued)}}%
}

\ifsustech@useminted
  % ---- minted backend: long code with continuation ----
  % #1=language  #2=optional title (default: language name)  #3=optional filename label
  \NewTCBListing{sustechlongcode}{m O{} O{}}{
    sustechcodebox,
    listing engine=minted,
    listing only,
    breakable,
    title={\sustechcodetitlecontent{\ifstrempty{#2}{#1}{#2}}{#3}},
    title after break={\sustech@codetitlecont{\ifstrempty{#2}{#1}{#2}}},
    minted language=#1,
    minted options={
      bgcolor=SUSTechCodeBg,
      breaklines,
      autogobble,
      linenos,
      fontsize=\small,
      tabsize=2
    }
  }
  % #1=optional title (default: Shell)  #2=optional filename label
  \NewTCBListing{sustechlongshell}{O{} O{}}{
    sustechshellbox,
    listing engine=minted,
    listing only,
    breakable,
    title={\sustechcodetitlecontent{\ifstrempty{#1}{Shell}{#1}}{#2}},
    title after break={\sustech@codetitlecont{\ifstrempty{#1}{Shell}{#1}}},
    minted language=text,
    minted options={
      bgcolor=SUSTechShellBg,
      breaklines,
      autogobble,
      linenos=false,
      fontsize=\small
    }
  }
  % ---- minted backend: diff ----
  % Minted uses the Pygments 'diff' lexer which colors additions/removals
  % natively. sustechdiff is a thin wrapper around sustechcode{diff}.
  \NewTCBListing{sustechdiff}{O{}}{
    sustechcodebox,
    listing engine=minted,
    listing only,
    breakable,
    title={Diff},
    minted language=diff,
    minted options={
      bgcolor=SUSTechCodeBg,
      breaklines,
      autogobble,
      linenos,
      fontsize=\small,
      #1
    }
  }
  \NewTCBListing{sustechdiffblock}{O{Diff} O{} O{} O{}}{
    sustechcodebox,
    listing engine=minted,
    listing only,
    breakable,
    title={\sustechcodetitlecontent{#1}{#2}},
    minted language=diff,
    minted options={
      bgcolor=SUSTechCodeBg,
      breaklines,
      autogobble,
      linenos,
      fontsize=\small
    },
    after={\sustechmaybeinsertcodecaption{#3}{#4}}
  }
\else
  % ---- listings backend: long code with continuation ----
  % #1=language  #2=optional title (default: language name)  #3=optional filename label
  \NewTCBListing{sustechlongcode}{m O{} O{}}{
    sustechcodebox,
    listing engine=listings,
    listing only,
    breakable,
    title={\sustechcodetitlecontent{\ifstrempty{#2}{#1}{#2}}{#3}},
    title after break={\sustech@codetitlecont{\ifstrempty{#2}{#1}{#2}}},
    listing options={style=sustechbase,language=#1}
  }
  % #1=optional title (default: Shell)  #2=optional filename label
  \NewTCBListing{sustechlongshell}{O{} O{}}{
    sustechshellbox,
    listing engine=listings,
    listing only,
    breakable,
    title={\sustechcodetitlecontent{\ifstrempty{#1}{Shell}{#1}}{#2}},
    title after break={\sustech@codetitlecont{\ifstrempty{#1}{Shell}{#1}}},
    listing options={style=sustechshell}
  }
  % ---- listings backend: diff ----
  % Uses the 'diff' language defined above with morecomment=[f]
  % for full-line coloring of +/- lines.
  \NewTCBListing{sustechdiff}{O{}}{
    sustechcodebox,
    listing engine=listings,
    listing only,
    breakable,
    title={Diff},
    listing options={style=sustechbase,language=diff,#1}
  }
  \NewTCBListing{sustechdiffblock}{O{Diff} O{} O{} O{}}{
    sustechcodebox,
    listing engine=listings,
    listing only,
    breakable,
    title={\sustechcodetitlecontent{#1}{#2}},
    listing options={style=sustechbase,language=diff},
    after={\sustechmaybeinsertcodecaption{#3}{#4}}
  }
\fi

% \code is a short convenience command for inline code snippets.
% It wraps content in the branded inline code box.
% COLLISION RISK: the name \code is generic and may conflict with
% user-defined commands or packages (e.g. some math or linguistics packages).
% If a conflict occurs, users may redefine it with:
%   \renewcommand{\code}[1]{...}
% The underlying implementation is always accessible via:
%   \sustechinlinecodebox{\ttfamily #1}
\providecommand{\code}[1]{\sustechinlinecodebox{\ttfamily #1}}