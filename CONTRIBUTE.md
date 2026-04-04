# 参与开发

面向为本仓库提交补丁、扩展接口或修 bug 的同学与维护者。默认假设你已能本地跑通 `XeLaTeX`，并熟悉基本的 `git` 与 GitHub Pull Request 流程。

## 目录

- [行为约定](#行为约定)
- [分支与工作流](#分支与工作流)
- [本地环境](#本地环境)
- [提交前自检](#提交前自检)
- [CI 与 GitHub Actions](#ci-与-github-actions)
- [修改 `SUSTechHomework.cls`](#修改-sustechhomeworkcls)
- [测试套件](#测试套件)
- [Commit 与 PR 描述](#commit-与-pr-描述)
- [发版（维护者）](#发版维护者)

## 行为约定

- 尊重上游设计脉络（见 `README.md` 中的致谢与引用）；提交第三方素材时确认许可证与校方标识规范。
- 讨论技术分歧时就事论事；review 意见请指向具体文件与行为，避免人身攻击。
- 不将仅用于维护者内部的规划文档纳入版本库（本仓库通过 `.gitignore` 排除 `PLAN.md`）；若你本地有类似文件，请勿 `git add`。

## 分支与工作流

- **`main`**：默认稳定分支；合并前应在 PR 中通过 CI 门禁。
- **`dev`**：可选集成分支；推送到 `dev` 会触发与 `main` 相同的完整测试任务（见下文 CI）。
- **功能/fix 分支**：从 `main`（或维护者指定的基线）检出，命名建议 `fix/short-topic` 或 `feat/short-topic`。

推荐流程：fork 或新建分支 → 小步提交 → 推送到你的远程 → 对 `main` 开 PR → 根据 review 修改 → squash merge 或按维护者要求合并。

## 本地环境

- **引擎**：必须以 **XeLaTeX** 编译；类文件会拒绝其他引擎。
- **发行版**：建议使用 TeX Live（与 CI 接近），并安装 `biblatex`/`biber`、`minted`（若测 minted 路径）、CJK 相关字体包。
- **参考文献**：涉及 `biblatex` 的示例需安装 **biber**。
- **可选**：安装 `latexmk` 后可用 `make LATEXMK=1 example` 编译根目录示例。

## 提交前自检

在打开 PR 前，至少完成：

1. **主示例能编译**

   ```bash
   make example
   ```

2. **单元测试通过（与 PR CI 一致）**

   ```bash
   make test-unit
   ```

   等价命令：`bash tests/run_all.sh --unit-only`

3. **若改了版式、宏或可能影响集成的行为**：建议在本地再跑完整套件（跳过视觉回归，与推送到 `main`/`dev` 的 CI 一致）：

   ```bash
   make test-full
   ```

   等价命令：`bash tests/run_all.sh --skip-regression`

4. **若修改了用户可见行为**：同步更新 `README.md` 或 `TROUBLESHOOTING.md` 中的相关说明，避免文档与代码脱节。

## CI 与 GitHub Actions

工作流定义在 `.github/workflows/ci.yml`。

| 事件 | 运行的检查 |
|------|------------|
| 对 **`main`** 的 **Pull Request** | `bash tests/run_all.sh --unit-only`（单元测试，较快） |
| **Push** 到 **`main`** 或 **`dev`** | `bash tests/run_all.sh --skip-regression`（完整套件，跳过需 `diff-pdf` 的视觉回归） |

PR 失败时，可在 workflow artifact 中下载 `tests/_build` 下的 `.log` / `.pdf` 辅助排查。

发 tag `v*` 时的 **`release.yml`** 会构建发布产物；修改与 release 相关的类文件或示例后，维护者发版前应本地或 CI 上确认该流水线仍能通过。

## 修改 `SUSTechHomework.cls`

- **注释**：类内注释请使用 **英文**，并与现有 **L1–L15 分层**结构保持一致；新增大块逻辑时标明所属层与职责。
- **兼容性**：优先保留已有用户接口；若必须破坏性变更，应在 PR 中写明迁移方式，并尽量提供过渡期或兼容宏。
- **选项与条件加载**：沿用现有 `etoolbox`/`kvoptions` 等模式；避免无条件加载重型包（尤其 `minted` 相关）。
- **引擎**：不要移除或弱化 XeLaTeX 检测；新增依赖需说明是否在最小 TeX Live CI 镜像中可用。

## 测试套件

入口脚本：`tests/run_all.sh`。

常用标志：

- `--unit-only`：仅单元测试（PR 门禁）
- `--skip-regression`：跳过视觉回归（CI push 任务）
- `--skip-performance` / `--skip-stress` / `--skip-acceptance`：本地加快迭代时使用

也可使用 Makefile：`make test`、`make test-unit`、`make test-full`、`make perf`。

为修复 bug 或新功能添加 **可编译的最小 `.tex` 用例** 并接入现有 `tests/unit` 或相关 runner，能显著降低回归风险；具体目录结构以 `tests/` 下现有脚本为准。

## Commit 与 PR 描述

- **Commit message**：使用清晰英文或中文短句；建议包含 **动机** 与 **影响范围**（例如 `fix: avoid loading minted when code=listings`）。
- **PR 描述**建议包含：
  - 要解决什么问题（或链接 Issue）
  - 如何验证（贴出你跑过的命令，如 `make test-unit`）
  - 是否存在破坏性变更与用户迁移说明
- **避免** 超大单提交混用无关改动；能拆分的修复与文档更新尽量分 commit。

## 发版（维护者）

- 使用 **`v*`** 标签触发 `release.yml`。
- 本地打包可使用 `make dist`（可选 `VERSION=vX.Y.Z`）；`PLAN.md` 若存在于工作区会被加入 zip，但该文件默认不纳入 git，勿依赖其出现在公开仓库中。

---

本仓库以 [MIT License](LICENSE) 发布。贡献一经合并，除非另有声明，将遵循相同许可证；请保留必要的版权声明与第三方致谢。
