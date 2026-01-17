# Homebrew Cask 提交指南 - Dynamic Notch

## 准备工作

### 1. 环境要求
- 已安装 Homebrew
- 已有 GitHub 账户（你已有 ryanch741 账户）

### 2. Fork 官方仓库
访问并 Fork：https://github.com/Homebrew/homebrew-cask

## 提交步骤

### 1. 克隆你的 Fork
```bash
git clone https://github.com/ryanch741/homebrew-cask.git
cd homebrew-cask
```

### 2. 创建新分支
```bash
git checkout -b add-dynamic-notch
```

### 3. 复制 Cask 文件
```bash
cp /Users/ryan/Learn/BarHold/homebrew/dynamic-notch.rb Casks/
```

### 4. 验证 Cask 文件（可选但推荐）
```bash
# 安装并测试
brew install --cask ./Casks/dynamic-notch.rb

# 或仅验证语法
brew audit --cask ./Casks/dynamic-notch.rb
```

### 5. 提交更改
```bash
git add Casks/dynamic-notch.rb
git commit -m "Add dynamic-notch v1.0.0

Dynamic Notch is a macOS utility designed for Dynamic Island-style interaction on notch-equipped MacBook Pros.
It provides time/date display, shortcuts, Pomodoro timer, music control, and to-do list features."
```

### 6. 推送到你的 GitHub
```bash
git push origin add-dynamic-notch
```

### 7. 创建 Pull Request
1. 访问：https://github.com/ryanch741/homebrew-cask
2. 点击 "Pull requests" 标签
3. 点击 "New pull request"
4. 选择 `add-dynamic-notch` 分支对比 `master` 分支
5. 填写 PR 描述，参考以下内容：

```
## What this PR does / why we need it

Add Dynamic Notch (灵动刘海) v1.0.0 to homebrew-cask

Dynamic Notch is a macOS utility designed for Dynamic Island-style interaction on notch-equipped MacBook Pros. When your mouse approaches the notch area, it intelligently expands to show a series of useful feature modules.

Features:
- Smart expansion when mouse approaches
- Time & Date display
- Shortcuts (apps, websites, folders)
- Pomodoro Timer
- Music Control (Apple Music, Spotify, NetEase Cloud Music, QQ Music)
- To-do List
- Multi-display support
- Internationalization (Chinese/English)

## Related issue

None

## Special notes for your reviewer

- App name: Dynamic Notch (灵动刘海)
- App license: MIT
- Maintainer: ryanch741
- App is distributed as a DMG with proper code signatures
- App requires accessibility permissions for mouse tracking

## Additional documentation e.g., KEPs, usage docs, etc.

Project homepage: https://github.com/ryanch741/dynamic-notch
```

## 注意事项

### 1. 验证清单
- [ ] Cask 文件语法正确
- [ ] URL 可访问
- [ ] SHA256 校验和正确
- [ ] 应用名称没有与其他软件冲突
- [ ] 描述准确简洁

### 2. 常见问题
- 如果 PR 被拒绝，通常是由于命名冲突或不符合规范
- 确保应用名称具有独特性
- 遵循 Homebrew 的命名约定

### 3. 后续维护
一旦合并，当有新版本发布时：
```bash
# 更新版本和 SHA256
brew bump-cask-pr --version NEW_VERSION dynamic-notch
```

## 验证命令

测试安装：
```bash
# 在本地测试
brew install --cask ./Casks/dynamic-notch.rb

# 测试卸载
brew uninstall --cask dynamic-notch
```

## 替代方案

如果主仓库提交遇到困难，还可以考虑：
1. 创建自己的 Tap：`brew tap ryanch741/tap`
2. 使用私有 Cask：`brew install --cask /path/to/dynamic-notch.rb`