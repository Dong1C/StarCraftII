#!/bin/bash
# git_repos 初始化脚本
# 用法: cd git_repos && ./init_git_repos.sh

set -e

REPOS_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================="
echo "  git_repos 仓库初始化脚本"
echo "========================================="

# learn_afk
echo ""
echo "[1/2] 初始化 learn_afk..."

if [ ! -d "$REPOS_DIR/learn_afk" ]; then
    echo "learn_afk 目录不存在，正在 clone..."
    cd "$REPOS_DIR"
    git clone https://github.com/retr0git/learn_afk.git
    echo "learn_afk clone 完成"
else
    cd "$REPOS_DIR/learn_afk"
    
    # 检查是否有远程仓库
    if ! git remote get-url origin &>/dev/null; then
        echo "learn_afk: 添加远程仓库..."
        git remote add origin https://github.com/retr0git/learn_afk.git
    else
        echo "learn_afk: 远程仓库已存在"
    fi
    
    # 尝试拉取更新
    echo "learn_afk: 尝试拉取远程更新..."
    git fetch origin main 2>/dev/null || echo "  (无远程更新或仓库为空)"
    
    echo "learn_afk 初始化完成"
fi

# StarCraftII
echo ""
echo "[2/2] 初始化 StarCraftII..."

if [ ! -d "$REPOS_DIR/StarCraftII" ]; then
    echo "StarCraftII 目录不存在，正在 clone..."
    cd "$REPOS_DIR"
    git clone git@github.com:Dong1C/StarCraftII.git
    echo "StarCraftII clone 完成"
else
    cd "$REPOS_DIR/StarCraftII"
    
    # 检查是否有远程仓库
    if ! git remote get-url origin &>/dev/null; then
        echo "StarCraftII: 添加远程仓库..."
        git remote add origin git@github.com:Dong1C/StarCraftII.git
    else
        echo "StarCraftII: 远程仓库已存在"
    fi
    
    # 尝试拉取更新
    echo "StarCraftII: 尝试拉取远程更新..."
    git fetch origin main 2>/dev/null || echo "  (无远程更新或仓库为空)"
    
    echo "StarCraftII 初始化完成"
fi

echo ""
echo "========================================="
echo "  所有仓库初始化完成！"
echo "========================================="
