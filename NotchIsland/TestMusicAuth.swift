#!/usr/bin/env swift

import Foundation
import AppKit

print("开始测试 Apple Music 授权...")

let script = """
tell application "Music"
    get name
end tell
"""

var error: NSDictionary?
guard let scriptObject = NSAppleScript(source: script) else {
    print("❌ 无法创建 AppleScript")
    exit(1)
}

let output = scriptObject.executeAndReturnError(&error)

if let error = error {
    print("❌ 执行失败: \(error)")
    exit(1)
}

if let result = output.stringValue {
    print("✅ 授权成功！Music 应用名称: \(result)")
} else {
    print("⚠️ 无结果返回")
}

print("\n现在测试获取播放信息...")

let musicScript = """
tell application "Music"
    if player state is not stopped then
        set trackName to name of current track
        set trackArtist to artist of current track
        return trackName & " - " & trackArtist
    else
        return "stopped"
    end if
end tell
"""

guard let musicScriptObject = NSAppleScript(source: musicScript) else {
    print("❌ 无法创建 Music Script")
    exit(1)
}

let musicOutput = musicScriptObject.executeAndReturnError(&error)

if let error = error {
    print("❌ 执行失败: \(error)")
    exit(1)
}

if let result = musicOutput.stringValue {
    print("✅ 获取成功: \(result)")
} else {
    print("⚠️ 无结果返回")
}
