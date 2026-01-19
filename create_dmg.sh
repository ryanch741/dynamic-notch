#!/bin/bash

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/NotchIsland"
APP_NAME="灵动刘海"
DERIVED_DATA_PATH="$PROJECT_DIR/build"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Release/NotchIsland.app"
DMG_NAME="dynamic-notch-1.0.3.dmg"
STAGING_DIR="dmg_staging"

echo "🚀 开始构建并制作 DMG 安装包..."

# 0. 构建 Release 版本应用
xcodebuild -project "$PROJECT_DIR/NotchIsland.xcodeproj" -scheme NotchIsland -configuration Release -derivedDataPath "$DERIVED_DATA_PATH"

if [ ! -d "$APP_PATH" ]; then
  echo "❌ 未找到构建好的应用: $APP_PATH"
  echo "请先确认 Xcode 构建成功（Release 配置）。"
  exit 1
fi

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
