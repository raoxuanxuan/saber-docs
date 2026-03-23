# ~/.zshrc
alias wta='git worktree add'
alias wtl='git worktree list'
alias wtr='git worktree remove'

# 快速创建 worktree 并进入
wt() {
  local name=$1
  local branch=${2:-$1}
  git worktree add "../$(basename $(pwd))-${name}" "$branch" && \
  cd "../$(basename $(pwd))-${name}"
}

# 用法：wt auth feature/auth
# 效果：创建 ../my-project-auth 并 cd 进去
