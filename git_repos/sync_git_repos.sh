#!/bin/bash
# git_repos 同步脚本
# 读取 repos.list 中的仓库列表，批量 pull 最新代码
# 用法: cd git_repos && ./sync_git_repos.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPOS_LIST="$SCRIPT_DIR/repos.list"
LOG_FILE="$SCRIPT_DIR/sync.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

fail() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a "$LOG_FILE"
}

# 检查 repos.list 是否存在
if [ ! -f "$REPOS_LIST" ]; then
    fail "repos.list 不存在: $REPOS_LIST"
    exit 1
fi

log "========================================="
log "  git_repos 批量同步脚本"
log "========================================="

# 初始化 git repos 目录
if [ ! -d "$SCRIPT_DIR" ]; then
    mkdir -p "$SCRIPT_DIR"
fi

# 统计
TOTAL=0
SUCCESS_COUNT=0
FAIL_COUNT=0

# 逐行读取 repos.list
while IFS= read -r line || [ -n "$line" ]; do
    # 跳过注释行和空行
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue
    
    # 解析: name|git_url|description
    IFS='|' read -r name git_url desc <<< "$line"
    
    # 去掉首尾空格
    name=$(echo "$name" | xargs)
    git_url=$(echo "$git_url" | xargs)
    desc=$(echo "$desc" | xargs)
    
    if [ -z "$name" ] || [ -z "$git_url" ]; then
        warn "跳过无效行: $line"
        continue
    fi
    
    TOTAL=$((TOTAL + 1))
    log ""
    log "[$TOTAL] 仓库: $name"
    log "    URL: $git_url"
    log "    描述: $desc"
    
    REPO_DIR="$SCRIPT_DIR/$name"
    
    if [ ! -d "$REPO_DIR" ]; then
        log "    → 仓库不存在，正在 clone..."
        if git clone "$git_url" "$REPO_DIR" >> "$LOG_FILE" 2>&1; then
            success "    → clone 完成"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            fail "    → clone 失败"
            FAIL_COUNT=$((FAIL_COUNT + 1))
            continue
        fi
    else
        log "    → 仓库已存在，执行 git pull..."
        cd "$REPO_DIR"
        
        # 确保远程仓库正确
        if git remote get-url origin &>/dev/null; then
            # 更新远程 URL（以防地址变化）
            git remote set-url origin "$git_url" 2>/dev/null || true
        else
            git remote add origin "$git_url"
        fi
        
        # 尝试 pull
        if git pull origin main >> "$LOG_FILE" 2>&1 || git pull origin master >> "$LOG_FILE" 2>&1; then
            success "    → pull 完成"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            # 可能是分离状态或没有远程分支，尝试 fetch
            if git fetch origin >> "$LOG_FILE" 2>&1; then
                warn "    → pull 失败但 fetch 成功，可能在分离 HEAD 状态"
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                fail "    → pull/fetch 失败"
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
        fi
    fi
    
done < "$REPOS_LIST"

log ""
log "========================================="
log "  同步完成！"
log "  总计: $TOTAL | 成功: $SUCCESS_COUNT | 失败: $FAIL_COUNT"
log "========================================="