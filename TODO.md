# 灵动刘海 (Notch Island) 发布 TODO 清单

本项目当前进入发布准备阶段。以下是按优先级排列的待办事项：

## 🚀 第一阶段：正式版本制作与独立分发
- [x] **版本规范化** (prep_build_v100)
    - [x] 更新 `Info.plist` 中的 `CFBundleShortVersionString` 为 `1.0.0`
    - [x] 更新 `CFBundleVersion` 为 `1`
    - [x] 执行 `xcodebuild clean` 清理旧缓存
- [x] **制作 DMG 安装包** (create_dmg_flow)
    - [x] 准备 DMG 背景图资源 (使用基础样式)
    - [x] 编写并执行 `hdiutil` 自动化脚本
    - [x] 确保输出文件名为 `灵动刘海-1.0.0.dmg`
    - [x] 本地安装测试，验证图标、权限描述是否正常

## 🌍 进阶规划：国际化与英文版本 (Localization)
- [x] **多语言基础架构**
    - [x] 创建 `Localizable.strings` 资源文件
    - [x] 提取代码中硬编码的中文文本（如“灵动刘海”、“专注中”等）
- [x] **英文文本翻译**
    - [x] 确定应用英文名称：Dynamic Notch
    - [x] 翻译所有功能模块文本
- [x] **系统适配**
    - [x] 支持根据系统语言自动切换
    - [x] 优化英文长文本在刘海条中的显示布局

## 📦 第二阶段：社区分发 (GitHub + Homebrew)
- [x] **GitHub Release** (github_release_dmg)
    - [x] 创建 GitHub 仓库标签 `v1.0.0`
    - [x] 整理发布日志 (Release Notes)
    - [x] 上传生成的 DMG 安装包
- [x] **Homebrew Cask 接入** (homebrew_cask_setup)
    - [x] 编写 `dynamic-notch.rb` Cask 脚本
    - [ ] 提交 PR 到 Homebrew 官方仓库或创建私有 Tap

## 💰 第三阶段：商业化配置
- [x] **支付平台集成** (monetization_setup_links)
    - [x] 注册 LemonSqueezy 或 Gumroad 账号
    - [x] 创建“灵动刘海”产品项，设置定价
    - [x] 获取购买链接并集成到应用的“关于”页面

## 📣 第四阶段：全球推广
- [x] **宣传物料准备** (promotion_materials_ph)
    - [x] 录制刘海动画演示视频/GIF
    - [x] 设计 Product Hunt 展示图 (1270x760)
    - [x] 编写 PH 发布文案（Tagline, Description）
- [ ] **Product Hunt 发布**
    - [ ] 预约发布时间，争取首日曝光

---
> 本清单根据用户 2026-01-16 的发布决策生成。
