---
name: chroma-release
description: Chroma 的发布一体化流程（SemVer 决策、生成 changelog、同步 CLI 版本、打 git tag、发布 GitHub Release）。当被要求进行新版本发布、更新 CHANGELOG.md、升级 `ca` CLI 版本号、创建 tag 或发布 GitHub Release 时使用。
---

# Chroma 发布流程

## 概览

通过对比 HEAD 与最新 tag，确定下一版 SemVer，生成符合仓库格式的 changelog 段落，同步 `ca` CLI 版本号，并通过 `gh` 发布 git tag 与 GitHub Release。

## 工作流（从 HEAD 发布）

### 0) 前置条件

- 确保功能/修复改动已提交。release 脚本要求工作区干净。
- Tag 格式为纯 `X.Y.Z`（不带 `v`）。
- Release notes 从 notes 文件读取，文件内不包含版本标题。

### 1) 收集变更用于 AI 分析

运行变更收集脚本：

```bash
./.codex/skills/chroma-release/scripts/collect_changes.py
```

如果需要指定基准 tag：

```bash
./.codex/skills/chroma-release/scripts/collect_changes.py --since-tag 0.1.1
```

利用输出检查：
- 上次 tag 到 HEAD 的提交摘要
- 变更文件与 diff 统计

### 2) 决定下一版本（SemVer）

基于 diff 与提交上下文决定下一版本号。

判定参考：
- **Breaking change**：删除/重命名 public API，修改函数签名，改变默认行为，或不兼容的 CLI flag 变更。
- **Feature**：向后兼容的新增功能。
- **Fix**：仅包含向后兼容的 bug 修复。

SemVer 对应：
- `MAJOR`：破坏性变更（若已到 1.0.0+）
- `MINOR`：新增功能
- `PATCH`：修复

1.0 前版本处理（当前状态）：
- `0.y.z` 下的破坏性变更按 **minor** 处理（`y+1`）。
- 功能新增按风险决定 `y+1` 或 `z+1`；默认用户可见新增走 **minor**，低风险修复走 **patch**。

若破坏性判断不明确，优先检查 `Sources/Chroma` 与 public 声明 diff 再决策。

### 3) 生成 changelog notes（AI）

生成与 `CHANGELOG.md` 现有格式一致的 notes 文件。notes **不得**包含版本标题。示例：

```markdown
### Added
- ...

### Changed
- ...

### Fixed
- ...
```

根据上次 tag 与 HEAD 的 diff 填充段落，只保留有内容的分组。

### 4) 应用版本 + changelog，提交、打 tag、发布（脚本化）

用选定版本和 notes 文件执行发布脚本：

```bash
./.codex/skills/chroma-release/scripts/release.py \
  --version 0.1.1 \
  --notes-file /path/to/release-notes.md \
  --date 2026-01-04
```

行为：
- 更新 `Sources/Ca/CaCommand.swift` 里的版本常量
- 在 `## [Unreleased]` 之后插入 `## [X.Y.Z] - YYYY-MM-DD` 段落
- 提交信息为 `Release X.Y.Z`
- 创建 git tag `X.Y.Z`
- 使用同一 notes 文件通过 `gh release create` 发布 GitHub Release

可选参数：
- `--skip-commit` / `--skip-tag` / `--skip-release`
- `--allow-dirty`（不建议）

### 5) 校验

```bash
./.codex/skills/chroma-release/scripts/release_check.py --version 0.1.1 --require-clean --require-tag
```

## 资源

### scripts/
- `collect_changes.py`：收集上次 tag 到 HEAD 的提交与 diff 摘要。
- `release.py`：应用 changelog 与 CLI 版本，提交、打 tag、发布。
- `release_check.py`：强校验版本一致性与 tag 是否存在。
