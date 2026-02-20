#!/bin/bash
# 上传 .md 文件到 saber-docs
# 用法: ./upload.sh <file.md> [目录名]
# 示例: ./upload.sh ~/saber/output.md debug-notes

set -e

DOCS_DIR="/Users/saberrao/saber-docs"
SIDEBAR="$DOCS_DIR/_sidebar.md"

if [ -z "$1" ]; then
  echo "用法: $0 <markdown文件> [目录名]"
  echo "示例: $0 ~/output.md debug-notes"
  exit 1
fi

SRC="$1"
FILENAME=$(basename "$SRC")

# 如果指定了目录，放到子目录中
if [ -n "$2" ]; then
  TARGET_DIR="$DOCS_DIR/$2"
  mkdir -p "$TARGET_DIR"
  cp "$SRC" "$TARGET_DIR/$FILENAME"
  REL_PATH="$2/$FILENAME"
else
  cp "$SRC" "$DOCS_DIR/$FILENAME"
  REL_PATH="$FILENAME"
fi

# 提取标题（第一个 # 标题或文件名）
TITLE=$(grep -m1 '^# ' "$SRC" | sed 's/^# //' || echo "${FILENAME%.md}")

# 更新侧边栏（避免重复）
if ! grep -q "$REL_PATH" "$SIDEBAR"; then
  echo "- [$TITLE](/$REL_PATH)" >> "$SIDEBAR"
fi

# 提交并推送
cd "$DOCS_DIR"
git add .
git commit -m "docs: add $FILENAME"
git push

echo ""
echo "✅ 上传成功！"
echo "📄 访问地址: https://raoxuanxuan.github.io/saber-docs/#/$REL_PATH"
