# Wallper Free — Local Live Wallpapers for macOS

**Wallper Free** is a completely free, hastily-made (from Wallper, with Claude!) macOS application that brings your desktop to life with dynamic live wallpapers from your own video collection. No subscriptions, no licensing, no remote servers — just beautiful wallpapers from your local videos.

---

## ✨ Features

- 🎥 **Local Video Wallpapers** — Apply any video from your computer as a live wallpaper
- 📁 **Folder-Based** — Point to any folder containing your videos (MP4, MOV, M4V, AVI, MKV)
- 🔍 **Smart Filtering** — Search and filter your videos by name and other attributes
- 🔄 **Restore on Launch** — Automatically reapply your wallpapers when the app starts
- 🚀 **Launch at Login** — Optionally start Wallper when you log into macOS
- 🎨 **Clean Interface** — Simple, focused design with just Wallpapers and Settings
- 🔒 **Privacy-First** — Works completely offline, no data collection or remote tracking
- 💝 **100% Free** — No payments, subscriptions, or restrictions

---

## 🛠 Built With

- `SwiftUI` — for declarative, responsive macOS UI
- `AVKit` — for smooth video rendering and playback
- `AppKit` — for folder selection and system integration
- `ServiceManagement` — for launch at login functionality

---

## 🚀 Getting Started

### Prerequisites

- macOS 13.0+
- Xcode 14+
- Swift 5.7+

### Installation

```bash
git clone https://github.com/nickbarrantes/wallper-free.git
cd wallper-free
open Wallper.xcodeproj
```

### Quick Setup

1. **Build and run** the app in Xcode
2. **Select a video folder** using the "Select Video Folder" button in the sidebar
3. **Browse your videos** in the Wallpapers tab
4. **Click any video** to set it as your wallpaper
5. **Configure settings** like "Restore on Launch" and "Launch at Login"

---

## 📁 Project Structure

```
Wallper/
├── App/              # App entry point & environment handling
├── Core/             # Video playback and wallpaper management
├── Shared/           # View modifiers and reusable UI components
├── Store/            # App state: video library and filters
├── UI/               # SwiftUI views (Wallpapers & Settings)
```

---

## 🎯 Supported Video Formats

- **MP4** — Most common, recommended
- **MOV** — Apple's native format
- **M4V** — iTunes-compatible videos
- **AVI** — Classic format
- **MKV** — High-quality container

---

## ⚙️ Settings

- **Restore wallpapers on launch** — Automatically reapply wallpapers when Wallper starts
- **Launch at login** — Start Wallper automatically when you log into macOS  
- **Change video folder** — Switch to a different folder containing your videos

---

## 🔒 License

This project is **open source** and free for everyone to use, modify, and distribute.

---

## 💡 About This Version

This is a completely transformed version of the original Wallper app, converted from a paid service to a free, local-only application. All license management, remote servers, and paid features have been removed in favor of a simple, privacy-focused experience.

**Key Changes:**
- ✅ Removed all licensing and payment systems
- ✅ Replaced remote video libraries with local folder selection
- ✅ Eliminated network dependencies and data collection
- ✅ Simplified UI to focus on core wallpaper functionality
- ✅ Made everything work offline with your own videos

---

## 📬 Want to Contribute?

Feature suggestions, bug reports, and pull requests are welcome!  
Just open an [issue](https://github.com/nickbarrantes/wallper-free/issues) or submit a pull request.

---

## 🙏 Acknowledgments

- Original Wallper concept by [@alxndlk](https://github.com/alxndlk)
- Free version transformation powered by [Claude Code](https://claude.ai/code)

**Enjoy your beautiful, privacy-respecting wallpapers! 🎨**