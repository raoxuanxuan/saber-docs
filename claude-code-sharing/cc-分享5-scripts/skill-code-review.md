---
name: code-review
description: Review Go code for idiomatic patterns, concurrency safety, error handling, and performance. Use when reviewing Go source files or PRs.
---

## 审查步骤

1. 检查错误处理：是否每个 error 都被处理，不要 `_ = err`
2. 检查并发安全：goroutine 中访问共享变量是否有锁/channel 保护
3. 检查资源释放：defer close、context cancel
4. 检查命名规范：exported 函数有注释，变量名符合 Go 惯例
5. 检查测试覆盖：关键路径是否有测试

## 输出格式

按严重程度分类：
- 🔴 CRITICAL：必须修复
- 🟡 WARNING：建议修复
- 🟢 SUGGESTION：可以改进
