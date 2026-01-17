#!/bin/bash

# 配置变量
APP_NAME="灵动刘海"
APP_PATH="/Users/ryan/Learn/BarHold/NotchIsland/build/Build/Products/Release/NotchIsland.app"
DMG_NAME="灵动刘海-1.0.0.dmg"
STAGING_DIR="dmg_staging"

echo "🚀 开始制作 DMG 安装包..."

# 1. 创建暂存目录
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# 2. 复制应用到暂存目录并重命名
cp -R "$APP_PATH" "$STAGING_DIR/${APP_NAME}.app"

# 2.5 重新进行临时签名（解决“应用已损坏”问题）
echo "🔐 正在进行 ad-hoc 签名..."
codesign --force --deep --sign - "$STAGING_DIR/${APP_NAME}.app"

# 3. 创建 Applications 软链接
ln -s /Applications "$STAGING_DIR/Applications"

# 4. 创建 DMG
rm -f "$DMG_NAME"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

# 5. 清理
rm -rf "$STAGING_DIR"

echo "✅ DMG 制作完成: $DMG_NAME"
mv "$DMG_NAME" ~/Desktop/
echo "📍 已将安装包移动到桌面"
