#!/bin/bash
# CC Hook 通过 stdin 接收 JSON，不是环境变量
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# === Part 1: commit 后自动创建审查请求 ===
if echo "$COMMAND" | grep -q "git commit"; then
  HASH=$(git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$HASH" ]; then
    PENDING=".claude/reviews/pending"
    if [ ! -f "$PENDING/$HASH.md" ]; then
      mkdir -p "$PENDING"
      cat > "$PENDING/$HASH.md" << EOF
commit: $HASH
time: $(date '+%Y-%m-%d %H:%M')
branch: $(git branch --show-current)
---
$(git log -1 --format='%s%n%n%b')
EOF
    fi
  fi
fi

# === Part 2: 检查是否有新的审查反馈 ===
# Hook 的 stdout 会注入到 CC 上下文，CC-Dev 看到反馈就能立即响应
DONE=".claude/reviews/done"
NOTIFIED=".claude/reviews/.notified"
[ -d "$DONE" ] || exit 0
touch "$NOTIFIED" 2>/dev/null

for f in "$DONE"/*.md; do
  [ -f "$f" ] || continue
  NAME=$(basename "$f")
  grep -qF "$NAME" "$NOTIFIED" 2>/dev/null && continue
  echo ""
  echo "=========================================="
  echo "📬 收到新的审查反馈: $NAME"
  echo "=========================================="
  cat "$f"
  echo ""
  echo "$NAME" >> "$NOTIFIED"
done
