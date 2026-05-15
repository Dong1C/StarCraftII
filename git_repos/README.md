# git_repos 管理说明

本目录用于存放 retr0 授权 claw-master 管理的 Git 仓库。

---

## 目录结构

```
git_repos/
├── learn_afk/            # CS 学习路线图项目
├── StarCraftII/          # 星际争霸 II 相关资料
└── init_git_repos.sh    # 仓库初始化脚本
```

---

## 仓库列表

### learn_afk

| 项目 | 说明 |
|------|------|
| **路径** | `git_repos/learn_afk` |
| **地址** | https://github.com/retr0git/learn_afk |
| **用途** | CS 学习路线图项目 |
| **状态** | ✅ 已初始化 |

### StarCraftII

| 项目 | 说明 |
|------|------|
| **路径** | `git_repos/StarCraftII` |
| **地址** | https://github.com/Dong1C/StarCraftII |
| **用途** | 星际争霸 II 相关资料 |
| **状态** | ✅ 已初始化 |

---

## 维护脚本

### init_git_repos.sh

初始化 git_repos 下的所有仓库。

```bash
cd git_repos
chmod +x init_git_repos.sh
./init_git_repos.sh
```

脚本支持以下仓库的自动初始化：

| 仓库名 | 命令 |
|--------|------|
| learn_afk | `git clone https://github.com/retr0git/learn_afk.git` |
| StarCraftII | `git clone git@github.com:Dong1C/StarCraftII.git` |

---

## 仓库操作规范

### 添加新仓库

1. 在 GitHub 创建新仓库
2. 将仓库 clone 到 `git_repos/` 目录下
3. 更新本 README.md 的「仓库列表」部分，添加新仓库信息
4. 更新 `init_git_repos.sh`，添加新仓库的初始化逻辑
5. 提交变更并 push

**示例：** 添加新仓库 `my-new-repo`

```bash
# 1. clone 到 git_repos
cd git_repos
git clone git@github.com:Dong1C/my-new-repo.git

# 2. 更新 init_git_repos.sh，添加：
# if [ ! -d "$REPOS_DIR/my-new-repo" ]; then
#     git clone git@github.com:Dong1C/my-new-repo.git
# fi

# 3. 更新 README.md 仓库列表

# 4. 提交
git add -A && git commit -m "[feat]: 添加 my-new-repo 仓库" && git push
```

### 删除仓库

1. 从本地删除仓库目录
2. 更新本 README.md，标记仓库状态为「已删除」
3. 更新 `init_git_repos.sh`，移除对应初始化逻辑
4. 提交变更并 push

**⚠️ 注意：** 删除前请确认无重要未同步内容。

```bash
# 示例：删除 my-old-repo
rm -rf git_repos/my-old-repo
git add -A && git commit -m "[fix]: 移除 my-old-repo 仓库" && git push
```

### 更新仓库

1. 进入仓库目录
2. 执行 `git pull` 拉取最新代码
3. 如有配置变更，更新本 README.md

```bash
# 示例：更新 learn_afk
cd git_repos/learn_afk
git pull origin main
```

---

## git_repos 管理提交规范

| 操作 | commit 格式 |
|------|-------------|
| 添加仓库 | `[feat]: 添加 <仓库名> 仓库` |
| 删除仓库 | `[fix]: 移除 <仓库名> 仓库` |
| 更新仓库 | `[update]: 更新 <仓库名> 内容` |
| 更新脚本 | `[refactor]: 更新 git_repos 维护脚本` |

---

## 同步备份脚本

`sync_backup.sh` — 定期同步 git_repos 下所有仓库的备份脚本

### 功能说明

| 仓库类型 | 处理方式 |
|----------|----------|
| **GitHub 仓库** | 直接 `git push` 到各自的远程仓库 |
| **非 GitHub 仓库** | 备份到 `git_repos_backup/` 目录并 commit |

### 执行方式

```bash
# 手动执行
cd git_repos && ./sync_backup.sh

# 查看同步日志
tail -f git_repos/sync.log
```

### cron 任务

已配置每 2.5 小时自动执行一次同步备份任务。

---

## 注意事项

- 所有仓库操作必须通过 retr0 授权
- commit 前请确认内容不包含敏感信息
- 涉及外部网络操作时需谨慎
- 删除仓库前务必确认无未同步的重要数据

---

*最后更新：2026-03-27*
