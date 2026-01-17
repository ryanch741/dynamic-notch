# Dynamic Notch 🎉

<div align="right">
  English Version | <a href="./README.md">中文版</a>
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

### 🌍 Internationalization Support
- Automatic switching between Chinese and English based on system language
- Full bilingual support

## 📦 Installation

### Method 1: Download DMG Package (Recommended)

[⬇️ Download Dynamic Notch v1.0.0](https://github.com/ryanch741/dynamic-notch/releases/download/v1.0.0/灵动刘海-1.0.0.dmg)

### Method 2: Homebrew (Coming Soon)

```bash
brew install dynamic-notch  # Coming Soon
```

### Method 3: Build from Source

```bash
git clone https://github.com/ryanch741/dynamic-notch.git
cd dynamic-notch
open NotchIsland.xcodeproj
# Build and run in Xcode
```

## 🖼️ Feature Preview

| Feature Module | Preview |
|---------------|---------|
| **Time & Date** | Detailed time display on hover |
| **Shortcuts** | Quick launch for apps/websites |
| **Pomodoro Timer** | Focus timer with system notifications |
| **Music Control** | Real-time playback info with controls |
| **To-do List** | Manage tasks anytime, anywhere |

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

### "Application is damaged" Error

If you encounter a "application may be damaged or incomplete" error when opening the app, run this command in Terminal:

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