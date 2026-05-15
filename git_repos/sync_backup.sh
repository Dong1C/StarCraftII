#!/bin/bash
# git_repos 同步备份脚本
# 功能：定期同步 git_repos 下所有仓库的备份
# 使用：手动运行或配合 cron 任务

set -e

REPOS_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$REPOS_DIR/.." && pwd)"

# 不参与同步的目录（只存在于 git_repos/learn_afk 子目录中，不需要独立操作）
EXCLUDE_REPOS="principle_for_becoming_good_learner"

LOG_FILE="$REPOS_DIR/sync.log"
echo "[$(date)] ===== 开始同步 =====" >> "$LOG_FILE"

cd "$WORKSPACE_DIR"

# 遍历 git_repos 下的所有目录
for repo in "$REPOS_DIR"/*/; do
    [ -d "$repo" ] || continue
    repo_name=$(basename "$repo")
    
    # 跳过排除的目录
    if echo "$EXCLUDE_REPOS" | grep -q "\b$repo_name\b"; then
        echo "[$(date)] $repo_name: 排除目录，跳过" >> "$LOG_FILE"
        continue
    fi
    
    # 跳过非 git 仓库
    if [ ! -d "$repo/.git" ]; then
        echo "[$(date)] $repo_name: 非git仓库，跳过" >> "$LOG_FILE"
        continue
    fi
    
    cd "$repo"
    
    # 检查远程仓库
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    
    if echo "$remote_url" | grep -q "github.com"; then
        # GitHub 仓库 → 直接 push 到自己的远程
        echo "[$(date)] $repo_name: GitHub仓库，推送远程..." >> "$LOG_FILE"
        git push origin $(git rev-parse --abbrev-ref HEAD) 2>&1 >> "$LOG_FILE" || echo "[$(date)] $repo_name: push失败" >> "$LOG_FILE"
    else
        # 非 GitHub 仓库 → 备份到 workspace 仓库
        echo "[$(date)] $repo_name: 非GitHub仓库，备份到workspace..." >> "$LOG_FILE"
        cd "$WORKSPACE_DIR"
        
        # 将仓库内容添加到 workspace 的 git_repos_backup/ 下
        backup_dir="$WORKSPACE_DIR/git_repos_backup/$repo_name"
        mkdir -p "$(dirname "$backup_dir")"
        rsync -a --exclude='.git' "$repo" "$backup_dir" 2>&1 >> "$LOG_FILE" || \
            cp -r "$repo" "$backup_dir" 2>&1 >> "$LOG_FILE"
        
        # 提交备份
        if git diff --quiet git_repos_backup/ 2>/dev/null; then
            echo "[$(date)] $repo_name: 备份无变化" >> "$LOG_FILE"
        else
            git add git_repos_backup/
            git commit -m "[backup] $repo_name $(date +%Y-%m-%d)" 2>&1 >> "$LOG_FILE"
        fi
        
        cd "$repo"
    fi
    
    cd "$WORKSPACE_DIR"
done

# 同步 workspace 本身（不包括 memory 和 adhd-time）
echo "[$(date)] 同步 workspace 主仓库..." >> "$LOG_FILE"
git add .gitignore *.md git_repos/ skills/ adhd-time/ 2>/dev/null || true
if git diff --cached --quiet; then
    echo "[$(date)] workspace: 无新变化" >> "$LOG_FILE"
else
    git commit -m "[sync] workspace $(date +%Y-%m-%d\ %H:%M)" 2>&1 >> "$LOG_FILE"
fi

# push workspace（如果远程是 github.com/my-claw）
workspace_remote=$(git remote get-url origin 2>/dev/null || echo "")
if echo "$workspace_remote" | grep -q "github.com/Dong1C/my-claw"; then
    git push origin main 2>&1 >> "$LOG_FILE" || echo "[$(date)] workspace push失败" >> "$LOG_FILE"
fi

echo "[$(date)] ===== 同步完成 =====" >> "$LOG_FILE"
