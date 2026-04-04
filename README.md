# SUSTech Report Template

## 导读

- ✅ **想马上开始**：直接看下面的「最小单作者示例」。
- ✅ **小组作业 / 项目报告**：看「多作者示例」和 `examples/project-report.tex`。
- ⏳ **编译报错**：先翻「常见报错排查」，仍卡住再打开仓库里的 `TROUBLESHOOTING.md`。
- ➡️ **参与开发 / 提 PR**：分支策略、本地测试与 CI 说明见 [CONTRIBUTE.md](CONTRIBUTE.md)。
- ➡️ **授权**：本仓库以 [MIT License](LICENSE) 发布；若你修改后再分发，请保留许可证与版权说明。

如果你在找一份**能直接写作业、实验报告和课程项目**的 LaTeX 模板，可以试试本仓库。我们把标题页、代码高亮、图表浮动体、参考文献这些「容易和编译器较劲」的部分尽量封装好，你可以把精力放在内容本身。

## 设计从哪里来？

- **版式与整体思路**沿用了 [ziqin/LaTeX-SUSTechHomework](https://github.com/ziqin/LaTeX-SUSTechHomework) 一脉的南科作业模板（感谢原作者与社区的长期维护）。
- **配色**参考学校视觉识别系统页面的标准色说明：[南方科技大学 · 学校标识](https://www.sustech.edu.cn/zh/school_logo.html)。若要在正式对外材料中使用校徽、校名组合等，请务必阅读并遵守校方发布的标识使用规范。

在此之上，本仓库对类文件做了较大扩展与现代化（多作者、代码双后端、`biblatex`、图表与工程图组件等），与上游旧版接口已不完全相同；建议以本仓库示例为准上手，迁移旧稿时不必逐行对齐上游的每一条命令。

## 使用前认准两件事

- 请用 **XeLaTeX** 编译（本类会检测引擎，用错会直接报错提示）。
- 代码高亮默认 `code=listings` 最省心；需要更强语义高亮时用 `code=minted`，但要自行安装 Pygments，并开启 `-shell-escape`（详见下文）。

## 模板能做什么

- 支持课程信息与作者元数据字段：
  - `\coursecode`
  - `\coursename`
  - `\sid`
  - `\email`
  - `\semester`
  - `\instructor`
  - `\department`
  - `\college`
  - `\reporttype`
- 支持两种作者录入方式：
  - 兼容旧接口：`\author` + `\sid` + `\email`
  - 新接口：`\clearauthors` + `\addauthor`
- 支持轻量贡献声明接口：
  - `\clearcredits`
  - `\addcredit`
- 支持结构化贡献接口：
  - `\clearcontributions`
  - `\addcontribution`
- 支持基础视觉组件：
  - 以 `SUSTech Green` 为主色、`SUSTech Orange` 为强调色的品牌化章节标题
  - `sustechnote` / `sustechwarning` 提示框
  - `\sustechheaderrow` / `\sustechtableheader` / `\sustechthead` 表头样式工具
  - 图表标题与列表样式统一
- 支持基础图表组织接口：
  - `sustechfiguregroup` / `sustechtablegroup`
  - `sustechsubfigure` / `sustechsubtable`
  - `sustechwidefigure` / `sustechwidetable`
  - `\sustechfloatsep`
  - `\sustechplaceholdergraphic`
  - `sustechoverpic`
- 支持高级图表表达接口：
  - `\sustechannotate` / `\sustechannotatetext`
  - `\sustechoverlaylabel` / `\sustechoverlaytext`
  - `\sustechsidebyside`
  - `sustechaside`
  - `\sustechasideheading`
  - `\sustechfigurewithaside` / `\sustechtablewithaside`
- 支持基础工程图绘制接口：
  - `sustechdiagram`
  - `\sustechconnect`
  - `\sustechconnectto`
  - `\sustechconnectwith` / `\sustechconnecttowith`
  - `sustech process` / `sustech decision` / `sustech terminator`
  - `sustech io` / `sustech datastore` / `sustech note node`
  - `sustech feedback arrow` / `sustech auxiliary arrow` / `sustech highlight arrow`
- 支持第一轮工程图模板库：
  - `sustechsystemdiagram` + `\sustechmodulebox`
  - `sustechpipelinediagram` + `\sustechphasebox`
  - `sustechoverviewtimeline` + `\sustechtimelineaxis` + `\sustechtimelineevent`
- 支持第二轮工程图模板库与轻量布局辅助：
  - `sustecharchitecturediagram`
  - `sustechchaindiagram`
  - `\sustechmodulerow`
  - `sustech layer` / `sustech device`
- 支持标题页模式：
  - `titlepage=simple`
  - `titlepage=formal`
- 支持现代数学与单位接口：
  - `\qty` / `\num` / `\unit`
  - `\vect` / `\mat`
  - `\abs*{...}` / `\norm*{...}`
  - `\diff` / `\e` / `\ii`
- 支持智能引用与数字阅读能力：
  - `\cref` / `\Cref`
  - 目录跳转与编号书签
  - 自动显示 PDF 标题
  - 代码块统一引用命令 `\sustechcoderef`
- 支持现代参考文献系统：
  - `biblatex` + `biber`
  - `\addbibresource`
  - `\textcite` / `\parencite`
  - `\sustechprintbibliography`
  - DOI / URL / access date 显示
- 支持代码后端选项：
  - `code=listings`
  - `code=minted`
- 支持统一代码展示接口：
  - `sustechcode`
  - `sustechshell`
  - `\code`
- 支持高级代码块包装接口：
  - `sustechcodeblock`
  - `sustechshellblock`
- 支持组合式代码语义原语：
  - `\sustechcodecontext`
  - `\sustechcodecaption`
  - `\sustechcoderef`
- 支持代码框视觉能力：
  - 品牌化标题栏
  - 圆角代码容器
  - 左侧强调边线
  - 自动换行与行号
  - 深色终端风格
  - `listings` 后端：`json` / `yaml` / `[Modern]C++` / `[SUSTech]MATLAB` / `diff` 语言定义
  - 代码块标题说明、文件名说明与可引用 caption
- 支持长代码分页接口：
  - `sustechlongcode`
  - `sustechlongshell`
- 支持 diff 风格代码接口：
  - `sustechdiff`
  - `sustechdiffblock`

## 最小单作者示例

```tex
\documentclass[titlepage=formal,code=listings]{SUSTechHomework}

\title{Modernized Template Smoke Test / 模板冒烟测试}
\author{Wells}
\sid{12345678}
\email{wells@example.com}
\coursecode{CS100}
\coursename{Engineering Report Writing / 工程报告写作}
\semester{Spring 2026}
\instructor{Prof. Example}
\department{Department of Computer Science and Engineering}
\college{Shuren College}
\reporttype{Course Project Report}
\date{\today}

\begin{document}
\maketitle
\section{Introduction}
Hello SUSTech.
\end{document}
```

## 多作者示例

多作者信息建议放在 `\begin{document}` 之后、`\maketitle` 之前录入。这样做的原因是：标题页和 PDF 元数据都会在 `\maketitle` 时统一读取这些信息。

多作者模式下：

- 简洁标题会显示团队人数和成员角色。
- 正式标题页会显示完整成员信息块。
- PDF 作者元数据会自动聚合所有作者姓名。
- 如果使用 `\addcontribution`，正式标题页会优先显示更接近 CRediT 的结构化贡献块。
- 如果只使用 `\addcredit`，正式标题页会回退为自由文本贡献摘要块。

```tex
\documentclass[titlepage=formal,code=listings]{SUSTechHomework}

\title{Team Report}
\coursecode{EE101}
\coursename{Introduction to Engineering}
\semester{Spring 2026}
\instructor{Prof. Example}
\date{\today}

\begin{document}

\clearauthors
\addauthor{Alice}{12340001}{alice@example.com}{Department A}{College A}{Writing}
\addauthor{Bob}{12340002}{bob@example.com}{Department B}{College B}{Experiment}

\clearcontributions
\addcontribution{Alice}{Conceptualization, Writing - Original Draft}
\addcontribution{Bob}{Investigation, Validation, Visualization}

\clearcredits
\addcredit{Writing}{Alice drafted the report and organized the final narrative.}
\addcredit{Experiment}{Bob prepared the experiment workflow and validation notes.}

\maketitle

\section{Introduction}
Hello team.
\end{document}
```

## 编译方式

如果文档不包含参考文献，推荐直接使用 `XeLaTeX` 两次编译：

```bash
xelatex example.tex
xelatex example.tex
```

如果使用 `minted`：

- 需要本地已安装 `Pygments`
- 需要开启 `-shell-escape`

示例：

```bash
xelatex -shell-escape example.tex
xelatex -shell-escape example.tex
```

## 示例工程

仓库现在提供两套独立示例：

- `examples/minimal-homework.tex`
  适合单人平时作业、快速开题、最小可编译模板。
- `examples/project-report.tex`
  适合课程项目、实验报告、团队协作文档，包含目录、多人作者、代码块、子图、数学和参考文献。

根目录的 `example.tex` 仍然保留，作为更完整的综合冒烟示例。

## 常见选项

最常用的类选项如下：

- `titlepage=simple|formal`
  控制标题输出模式，平时作业建议 `simple`，正式项目报告建议 `formal`。
- `code=listings|minted`
  控制代码后端；默认 `listings` 更稳，`minted` 高亮更强但需要 `-shell-escape`。
- `theme=sustech|light`
  控制模板的视觉主题；默认使用品牌化 `sustech` 风格。
- `lang=auto|zh|en|bilingual`
  控制 PDF 语言元数据与部分文档语言行为。

## 常用命令

日常最常用的命令通常只有这几条：

```bash
# Compile the main smoke example
xelatex example.tex

# Compile the bibliography-enabled example
xelatex example.tex && biber example && xelatex example.tex && xelatex example.tex

# Run unit tests
bash tests/unit/run_unit.sh

# Run unit + integration + acceptance tests
bash tests/run_all.sh --skip-regression --skip-performance --skip-stress

# Run the release-facing acceptance suite only
bash tests/acceptance/run_acceptance.sh
```

如果使用 `biblatex` 参考文献：

```bash
xelatex example.tex
biber example
xelatex example.tex
xelatex example.tex
```

如果同时使用 `minted` 与 `biblatex`：

```bash
xelatex -shell-escape example.tex
biber example
xelatex -shell-escape example.tex
xelatex -shell-escape example.tex
```

## `minted` 缓存与 shell escape 说明

使用 `code=minted` 时，模板本质上会调用 Python 的 `Pygments` 做高亮，所以有两个现实约束：

- 必须开启 `-shell-escape`
- 首次编译通常会比 `listings` 更慢

如果你只是想稳定交作业，优先使用 `code=listings`。如果你更重视语义高亮质量，再切换到 `minted`。

如果你已经启用了 `minted`：

- 本地开发时，建议连续编译同一份文档，避免频繁清空辅助文件。
- CI 或受限环境里，如果不能开启 `-shell-escape`，不要强行保留 `minted`，直接切回 `code=listings`。
- Overleaf 上也应确认 shell escape 已开启，否则错误通常不是模板本身的问题。

## 数学与单位示例

推荐使用 `align`、`mathtools` 和 `siunitx` 的原生命令，而不是继续沿用 `eqnarray` 等旧写法。

```tex
\begin{align}
  \vect{v}(t) &= \begin{bmatrix} x(t) \\ y(t) \\ z(t) \end{bmatrix}, \\
  \mat{K}\vect{x} &= \vect{b}, \\
  \norm*{\vect{x}}_2 &\le \abs*{\alpha} + \qty{2.5}{\newton}, \\
  I &= \int_{0}^{T} \e^{-t} \sin(\omega t)\,\diff t.
\end{align}

The measured acceleration is \qty{9.81}{\meter\per\second\squared}.
```

## 智能引用示例

模板已经接入 `cleveref`，建议优先使用 `\cref` / `\Cref`，减少手写 `Figure`、`Table`、`Equation` 前缀的负担。

```tex
\tableofcontents

\section{Method}\label{sec:method}

\begin{equation}
  E = mc^2
  \label{eq:energy}
\end{equation}

\begin{figure}[htbp]
  \centering
  \fbox{\rule{0pt}{3cm}\rule{0.7\linewidth}{0pt}}
  \caption{Reference figure}
  \label{fig:reference}
\end{figure}

See \cref{sec:method,eq:energy,fig:reference}.
```

## 参考文献示例

模板现在直接支持 `biblatex` + `biber`。推荐使用 `\textcite`、`\parencite` 和 `\sustechprintbibliography`，而不是继续使用旧式 `\bibliography` / `\bibliographystyle` 工作流。

```tex
\addbibresource{references.bib}

As shown by \textcite{lamport1994latex}, structured markup improves
document maintainability. A package page can be cited with
\parencite{ctan-biblatex}.

\sustechprintbibliography
```

## Overleaf 使用说明

如果你在 Overleaf 使用本模板，建议按下面方式配置：

1. 编译器选择 `XeLaTeX`。
2. 如果使用参考文献，Bibliography tool 选择 `Biber`。
3. 如果使用 `minted`，需要在 Overleaf 项目设置里开启 shell escape。
4. 如果字体与本地略有差异，优先保持 `XeLaTeX`，不要切回 `pdfLaTeX`。

## 字体回退说明

模板当前采用“优先系统字体，失败时回退到 TeX 发行版字体”的策略：

- 西文字体优先尝试 `TeX Gyre Pagella` 与 `TeX Gyre Heros`
- 中文字体优先尝试 `Songti SC`
- 若缺失，再尝试 `PingFang SC`
- 如果仍不可用，再回退到 `FandolSong-Regular`

这意味着：

- 在 macOS 上，通常会优先命中系统中文字体，视觉更自然。
- 在 TeX Live 环境或一些 Linux 环境上，通常会回退到 `Fandol` 系列。
- 只要你坚持使用 `XeLaTeX`，大多数情况下都能得到可编译结果；差异更多体现在视觉风格，而不是功能是否可用。

## 常见报错排查

- 报错 `This class requires XeLaTeX`
  说明你用了错误的编译器，切换到 `XeLaTeX`。
- 报错 `Please (re)run Biber`
  说明文档启用了 `biblatex`，但还没有执行 `biber`。
- 报错 `minted.sty was not found`
  说明本地没有安装 `minted` 或 `Pygments`，要么安装依赖，要么切回 `code=listings`。
- 中文字体显示异常
  说明本机缺少优先字体，模板会尝试自动回退；如果仍不理想，优先检查系统 CJK 字体是否完整。
- 交叉引用显示为 `??`
  说明文档还没有完成足够轮次的编译，通常再跑一到两次 `XeLaTeX` 即可；若使用文献，还要先执行 `biber`。

## 交作业 / 发 release 前自查

如果你要交 PDF、或要给仓库打 tag 发版，建议至少确认：

- `examples/minimal-homework.tex` 可以成功编译。
- `examples/project-report.tex` 可以通过 `XeLaTeX + Biber` 成功编译。
- 根目录 `example.tex` 可以成功编译，且目录、引用、参考文献正常。
- 单作者和多作者标题页都能正常显示。
- 中文、公式、代码块、图表、参考文献至少各有一处真实示例。
- `bash tests/acceptance/run_acceptance.sh` 可以通过。
- `bash tests/run_all.sh --skip-regression --skip-performance --skip-stress` 可以通过。

## 视觉组件示例

### 代码块

```tex
The inline API supports \code{print("Hello SUSTech")} in running text.

\begin{sustechcodeblock}{Python}[Greeting Helper][src/greet.py][Reference implementation for the greeting helper.][code:greet]
def greet(name: str) -> None:
    print(f"Hello, {name}!")
\end{sustechcodeblock}

\begin{sustechshellblock}[Build Log][terminal://xelatex][Typical XeLaTeX build output.]
$ xelatex example.tex
Output written on example.pdf.
\end{sustechshellblock}

See \sustechcoderef{code:greet} for the referenced code block.
```

### 提示框

```tex
\begin{sustechnote}[title=Design Note]
This is a highlighted note box.
\end{sustechnote}

\begin{sustechwarning}[title=Compile Warning]
Enable shell escape only when using minted.
\end{sustechwarning}
```

### 表格表头

```tex
\begin{tabular}{ll}
  \sustechheaderrow
  \sustechtableheader{Item} & \sustechtableheader{Status} \\
  Template Core & Stable \\
\end{tabular}
```

### 图表标题与列表

```tex
\begin{figure}[htbp]
  \centering
  \fbox{\rule{0pt}{3cm}\rule{0.7\linewidth}{0pt}}
  \caption{Styled figure caption example}
\end{figure}

\begin{itemize}
  \item SUSTech Green is the primary tone, while orange is reserved for emphasis.
\end{itemize}

\begin{enumerate}
  \item Build the metadata layer.
\end{enumerate}
```

### 子图与并排表格

```tex
\begin{sustechfiguregroup}
  \begin{sustechsubfigure}[0.48\linewidth][Baseline result]
    \sustechplaceholdergraphic[0.92\linewidth][3cm]
  \end{sustechsubfigure}
  \sustechfloatsep
  \begin{sustechsubfigure}[0.48\linewidth][Improved result]
    \sustechplaceholdergraphic[0.92\linewidth][3cm]
  \end{sustechsubfigure}
  \caption{Two subfigures in one grouped figure}
\end{sustechfiguregroup}

\begin{sustechtablegroup}
  \begin{sustechsubtable}[0.48\linewidth][Experiment A]
    \begin{tabular}{ll}
      \sustechheaderrow
      \sustechtableheader{Metric} & \sustechtableheader{Value} \\
      Accuracy & 91\% \\
    \end{tabular}
  \end{sustechsubtable}
  \sustechfloatsep
  \begin{sustechsubtable}[0.48\linewidth][Experiment B]
    \begin{tabular}{ll}
      \sustechheaderrow
      \sustechtableheader{Metric} & \sustechtableheader{Value} \\
      Accuracy & 94\% \\
    \end{tabular}
  \end{sustechsubtable}
  \caption{Two subtables in one grouped table}
\end{sustechtablegroup}
```

### 宽图与图上标注

```tex
\begin{sustechwidefigure}
  \includegraphics[width=0.9\textwidth]{result-overview}
  \caption{Wide figure placeholder for future two-column layouts}
\end{sustechwidefigure}

\begin{figure}[htbp]
  \centering
  \begin{sustechoverpic}[0.72\linewidth]{experiment-setup}
    \put(18,72){\color{SUSTechPrimary}\bfseries Sensor}
    \put(58,30){\color{SUSTechPrimary}\bfseries Controller}
  \end{sustechoverpic}
  \caption{Annotated figure with overlay labels}
\end{figure}
```

### 侧边说明型图表

```tex
\sustechfigurewithaside
  {\includegraphics[width=0.95\linewidth]{result-overview}}
  {
    \begin{sustechaside}
    \sustechasideheading{Interpretation}
    \small
    Use the right panel for assumptions, observations, or reading guidance
    that would be too dense for a short caption.
    \end{sustechaside}
  }
  {Side-by-side figure with explanatory aside}
```

### 工程流程图

```tex
\begin{figure}[htbp]
  \centering
  \begin{sustechdiagram}
    \node[sustech terminator] (start) {Start};
    \node[sustech io, below=of start] (collect) {Collect Data};
    \node[sustech process, below=of collect] (clean) {Clean Samples};
    \node[sustech decision, below=14mm of clean] (check) {Quality OK?};
    \node[sustech process, below left=14mm and 18mm of check] (revise) {Revise Setup};
    \node[sustech process, below right=14mm and 18mm of check] (train) {Train Model};

    \sustechconnect{start}{collect}
    \sustechconnect{collect}{clean}
    \sustechconnectwith{sustech highlight arrow}{clean}{check}
    \sustechconnecttowith{sustech feedback arrow}[bend right=18][No]{check}{revise}
    \sustechconnecttowith{sustech highlight arrow}[bend left=18][Yes]{check}{train}
  \end{sustechdiagram}
  \caption{Branded engineering flowchart example}
\end{figure}
```

### 系统框图、管线图与时间线

```tex
\begin{figure}[htbp]
  \centering
  \begin{sustechsystemdiagram}
    \sustechmodulebox{input}{at={(0,0)}}{Input Signal}
    \sustechmodulebox{controller}{right=of input}{Controller}
    \sustechmodulebox{plant}{right=of controller}{Plant}
    \sustechmodulebox[sustech datastore]{output}{right=of plant}{Output}
    \node[sustech io, below=of plant] (sensor) {Sensor};

    \sustechconnect{input}{controller}
    \sustechconnectwith{sustech highlight arrow}{controller}{plant}
    \sustechconnectto[out=-90,in=0][Measure]{plant}{sensor}
    \sustechconnecttowith{sustech feedback arrow}[out=180,in=-90][Feedback]{sensor}{controller}
  \end{sustechsystemdiagram}
\end{figure}

\begin{figure}[htbp]
  \centering
  \begin{sustechpipelinediagram}
    \sustechphasebox{collectphase}{at={(0,0)}}{Collect}
    \sustechphasebox{cleanphase}{right=of collectphase}{Clean}
    \sustechphasebox{featurephase}{right=of cleanphase}{Extract}
    \sustechphasebox{trainphase}{right=of featurephase}{Train}
    \sustechphasebox{evalphase}{right=of trainphase}{Evaluate}
  \end{sustechpipelinediagram}
\end{figure}

\begin{figure}[htbp]
  \centering
  \begin{sustechoverviewtimeline}
    \sustechtimelineaxis{(0,0)}{(4,0)}
    \sustechtimelineevent{kickoff}{(0,0)}{Week 1}{Project kickoff}
    \sustechtimelineevent{delivery}{(4,0)}{Week 8}{Final delivery}
  \end{sustechoverviewtimeline}
\end{figure}
```

### 架构图与采集链路图

```tex
\begin{figure}[htbp]
  \centering
  \begin{sustecharchitecturediagram}
    \sustechmodulerow[sustech io]{inputs}{at={(0,0)}}{{Image\\Input},{Sensor\\Stream},{Context\\Metadata}}
    \sustechmodulerow[sustech layer]{backbone}{below=14mm of inputs-2}{Encoder,Fusion Layer,Decoder}
    \sustechmodulerow[sustech module]{outputs}{below=14mm of backbone-2}{{Detection\\Head},{State\\Estimator},{Report\\Output}}
  \end{sustecharchitecturediagram}
\end{figure}

\begin{figure}[htbp]
  \centering
  \begin{sustechchaindiagram}
    \sustechmodulerow[sustech device]{chain}{at={(0,0)}}{Sensor,Signal Conditioning,DAQ,Controller,Actuator}
  \end{sustechchaindiagram}
\end{figure}
```
