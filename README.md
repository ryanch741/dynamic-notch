# Dynamic Notch 🎉

<div align="right">
  <a href="./README_ZH.md">中文版</a> | English Version
</div>

<div align="center">

[![GitHub release](https://img.shields.io/github/v/release/ryanch741/dynamic-notch)](https://github.com/ryanch741/dynamic-notch/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/ryanch741/dynamic-notch/total)](https://github.com/ryanch741/dynamic-notch/releases)
[![License](https://img.shields.io/github/license/ryanch741/dynamic-notch)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14.0+-black?logo=apple)](https://www.apple.com/macos/)

**✨ A macOS utility designed for Dynamic Island-style interaction on notch-equipped MacBook Pros**

🖱️ Auto-expand on hover | ⏰ Time & Date | 🚀 Shortcuts | 🍅 Pomodoro Timer | 🎵 Music Control | ✅ To-do List

</div>

## 🌟 Core Features

### 🖱️ Dynamic Notch Interaction
- **Smart Expansion**: Automatically expands when mouse approaches with smooth scaling animations
- **Intelligent Hiding**: Doesn't interfere with daily usage, keeping the interface clean

### 📦 Integrated Efficiency Modules

**⏰ Time & Date**
- Real-time display of accurate time and day of week
- Multi-language date format support

**🚀 Shortcuts**
- One-click access to common apps, websites, and folders
- Customizable shortcut icons
- Automatic Favicon fetching for websites

**🍅 Pomodoro Timer**
- Focus management with 25-minute work + 5-minute break cycles
- System-level notification reminders
- Customizable duration and loop counts

**🎵 Music Control**
- Real-time playback info from Apple Music / Spotify / NetEase Cloud Music / QQ Music
- Skip tracks, play/pause controls
- Beautiful album art display

**✅ To-do List**
- Convenient task management
- Integrated in menu bar for easy access
- Local data persistence

### 🖥️ Multi-display Support
- Optional simulated notch bar on secondary displays
- Perfect multi-monitor workflow support

### ⚡ Auto-startup
- Automatically runs when the system starts
- Toggle in-app via Settings

### 🌍 Internationalization Support
- Automatic switching between Chinese and English based on system language
- Full bilingual support

## 📦 Installation

### Method 1: Download DMG Package (Recommended)

[⬇️ Download Dynamic Notch v1.0.8](https://github.com/ryanch741/dynamic-notch/releases/download/v1.0.8/dynamic-notch-1.0.8.dmg)

> **⚠️ Security Note**: Since this app is not notarized by Apple, you might see a warning: *"Apple cannot verify that this app is free from malware"*. 
> 
> **To open the app for the first time:**
> 1. **Right-click** (or Control-click) `灵动刘海.app` in your Applications folder.
> 2. Select **Open** from the menu.
> 3. Click **Open** in the dialog box.

### Method 2: Homebrew (Coming Soon)

```bash
```bash
# Install via Homebrew Tap
brew install --cask ryanch741/tap/dynamic-notch
```

Or tap first, then install:

```bash
brew tap ryanch741/tap
brew install --cask dynamic-notch
```
```

### Method 3: Build from Source

```bash
git clone https://github.com/ryanch741/dynamic-notch.git
cd dynamic-notch
open NotchIsland.xcodeproj
# Build and run in Xcode
```

## 🖼️ Feature Preview

### Dynamic Notch Interaction

<div align="center">

![Interaction Demo](screenshots/demo-interraction.gif)

| Collapsed State | Expanded State |
|:---------------:|:--------------:|
| ![Notch Collapsed](screenshots/notch-collapsed.png) | ![Notch Expanded](screenshots/notch-expanded.png) |
| *Notch in default collapsed state* | *Notch expanded showing module options* |

</div>

### Feature Modules

<div align="center">

![Modules Demo](screenshots/demo-modules.gif)

| Time & Date | Shortcuts | Pomodoro Timer |
|:-----------:|:---------:|:--------------:|
| ![Time Module](screenshots/feature-time.png) | ![Shortcuts Module](screenshots/feature-shortcuts.png) | ![Pomodoro Module](screenshots/feature-pomodoro.png) |
| *Real-time clock and date display* | *Quick launch apps and websites* | *Focus timer with notifications* |

| Music Control | To-do List | Settings |
|:-------------:|:----------:|:--------:|
| ![Music Module](screenshots/feature-music.png) | ![Todo Module](screenshots/feature-todo.png) | ![Settings](screenshots/settings.png) |
| *Playback info and controls* | *Task management* | *Customize your experience* |

</div>

## 💻 System Requirements

- **Operating System**: macOS 14.0 (Sonoma) or higher
- **Recommended Device**: MacBook Pro with notch
- **Required Permissions**:
  - Accessibility permission (for mouse position monitoring)
  - Notification permission (for Pomodoro timer alerts)

## ⚙️ Configuration & Usage

1. On first launch, allow "Accessibility" permission in "System Settings → Privacy & Security"
2. The app displays a settings entry in the menu bar
3. Enable/disable various modules in settings

## 🛠️ Troubleshooting

### "Application is damaged" or "Cannot be verified" Error

If you encounter an error saying the application is damaged, incomplete, or cannot be verified by Apple, this is due to macOS Gatekeeper. You can fix it using one of these methods:

#### Option A: The Simple Way (Recommended)
1. In Finder, **Right-click** the app and select **Open**.
2. Click **Open Anyway** in the popup.

#### Option B: Privacy Settings
1. Open **System Settings** → **Privacy #### Option A: The Simple Way (Recommended) Security**.
2. Scroll down and look for a message about "Dynamic Notch" in the bottom section.
3. Click **Allow Anyway** or **Open Anyway**.

#### Option C: Using Terminal
1. In Finder, **Right-click** the app and select **Open**.
2. Click **Open Anyway** in the popup.

#### Option B: Using Terminal
Run this command to remove the quarantine flag:

```bash
sudo xattr -rd com.apple.quarantine /Applications/灵动刘海.app
```

Then restart the application.

### Mouse Position Monitoring Not Working

Ensure "Dynamic Notch" is checked in "System Settings → Privacy & Security → Accessibility".

### Pomodoro Notifications Not Showing

Ensure "Dynamic Notch" is allowed to send notifications in "System Settings → Notifications".

## 🤝 Contributing

Feel free to submit Issues and Pull Requests to improve this project!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Issue Reporting**: [Issues](https://github.com/ryanch741/dynamic-notch/issues)
- **Project Homepage**: [Gitee](https://gitee.com/hianzuo/dynamic-notch)

---

<div align="center">

**Thanks for supporting indie development!** 🚀  
If you find this useful, please give us a ⭐️ Star!

</div>