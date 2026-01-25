# 📋 ClipType

> **The Ultimate Clipboard Injector**
> *Simulates native keystrokes to paste text where `Ctrl+V` fails.*

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Version](https://img.shields.io/badge/version-1.0.0-green.svg) ![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)

## 📥 Download & Install

**Don't want to deal with code?**
Grab the ready-to-use version for your system from the Releases page:

[**👉 Download Latest Release**](https://github.com/ahmedthebest31/ClipType/releases)

### 📦 Install via Winget

You can verify and install the official package directly from the command line:

```powershell
winget install AhmedSamy.ClipType

---

## 🚀 Why ClipType?

Sometimes, `Ctrl+V` just doesn't work. whether it's a **remote desktop (RDP)**, a **VNC console**, a restricted **password field**, or a **legacy terminal**.

**ClipType solves this by "typing" your clipboard content character-by-character, just as if you were typing it physically.**

### Key Features:
* ✅ **Bypass Paste Restrictions:** Works everywhere keystrokes work.
* ✅ **Accessibility First:** Screen-reader friendly interface with audio feedback.
* ✅ **Smart Formatting:** Fixes broken line endings (CRLF/LF) and trims accidentally copied whitespace.
* ✅ **Safe:** Includes a "Panic Key" (Esc) to stop typing immediately.

---

## 🧠 Under the Hood (For Geeks)

ClipType isn't magic; it's pure engineering. Here is how it handles each OS natively:

* **Windows:** Built with **AutoHotkey v2**. It creates a hidden buffer and sends `SendEvent {Raw}` events, ensuring compatibility with virtual machines and remote sessions. It also auto-elevates to Admin to ensure global hotkey priority.
* **Linux:** A smart Bash script that detects your display server. It uses `wtype` for **Wayland** sessions and `xdotool` for **X11**, making it distro-agnostic.
* **macOS:** Utilizes native AppleScript and `System Events` to simulate keystrokes directly into the active application, requiring no third-party dependencies.

---

## 🛠️ Quick Usage

### 🪟 Windows
1.  Run `ClipType.exe` (or the `.ahk` script).
2.  Press **`Ctrl + Shift + V`** to type your clipboard.
3.  Right-click the **Tray Icon** to change settings (Speed, Language, Hotkeys).

### 🐧 Linux
1.  Run `src/linux/cliptype.sh` via terminal.
2.  Or bind the script to a custom keyboard shortcut in your Desktop Environment.

### 🍎 macOS
1.  Run `src/mac/cliptype.applescript` via terminal (`osascript`).
2.  Or use **Automator** to create a global Quick Action service.

---

## 🤝 Contributing
 Contributions to this project are welcome! If you find a bug, have an idea for an improvement, or want to contribute in any other way, please feel free to open an issue or submit a pull request.


Please ensure you use **LF** line endings for Linux/macOS files and **UTF-8 with BOM** for the Windows script.

## 📄 License

This project is licensed under the **MIT License**.

