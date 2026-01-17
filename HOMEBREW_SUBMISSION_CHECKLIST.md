# Homebrew Cask 提交检查清单

## 立即执行步骤

### 1. Fork 仓库
- [ ] 访问 https://github.com/Homebrew/homebrew-cask
- [ ] 点击 "Fork" 按钮到你的 `ryanch741` 账户

### 2. 克隆并准备
- [ ] 打开终端，执行：
  ```bash
  git clone https://github.com/ryanch741/homebrew-cask.git
  cd homebrew-cask
  git checkout -b add-dynamic-notch
  ```

### 3. 复制 Cask 文件
- [ ] 执行：
  ```bash
  cp /Users/ryan/Learn/BarHold/homebrew/dynamic-notch.rb Casks/
  ```

### 4. 本地测试（推荐）
- [ ] 执行：
  ```bash
  brew install --cask ./Casks/dynamic-notch.rb
  brew uninstall --cask dynamic-notch
  ```

### 5. 提交更改
- [ ] 执行：
  ```bash
  git add Casks/dynamic-notch.rb
  git commit -m "Add dynamic-notch v1.0.0"
  git push origin add-dynamic-notch
  ```

### 6. 创建 Pull Request
- [ ] 访问 https://github.com/ryanch741/homebrew-cask
- [ ] 点击 "Pull requests" → "New pull request"
- [ ] 选择 `add-dynamic-notch` 分支
- [ ] 填写 PR 描述（可使用 HOMEBREW_SUBMISSION_GUIDE.md 中的模板）

## 预期结果
- [ ] PR 被 Homebrew 团队审核
- [ ] 如果符合规范，会被合并到主仓库
- [ ] 用户可以使用 `brew install --cask dynamic-notch` 安装

## 备用方案
如果主仓库 PR 遇到问题：
- [ ] 创建自己的 Tap：`brew tap ryanch741/tap`

---

**完成以上步骤后，你的应用将可以通过 Homebrew 安装！**