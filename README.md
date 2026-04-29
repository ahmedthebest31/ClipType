# 📋 ClipType

> **The Ultimate Professional Clipboard Injector**
> *Simulates native keystrokes to paste text where `Ctrl+V` completely fails.*

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Version](https://img.shields.io/badge/version-2.0.0-green.svg) ![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)

---

## 📥 Download & Install

**Don't want to deal with code?**
Grab the ready-to-use version for your system from the Releases page:

[**👉 Download Latest Release**](https://github.com/ahmedthebest31/ClipType/releases/latest)

### 📦 Install via Winget (Windows)

You can verify and install the official package directly from the command line:

```powershell
winget install AhmedSamy.ClipType
```

---

## 🚀 Why ClipType? & Key Features

Sometimes, `Ctrl+V` just doesn't work—whether you are dealing with a **remote desktop (RDP)**, a **VNC console**, a restricted **password field**, or a legacy terminal.

**ClipType solves this by "typing" your clipboard content character-by-character, exactly as if you were physically typing it on your keyboard.**

### ✨ Core Features

* **🤖 Anti-Bot Evasion (All Platforms):** Bypass strict monitoring systems, government portals, or security systems that block automated inputs.
  * **Randomized Typing:** Introduces natural, randomized delays between keystrokes to mimic human typing perfectly.
  * **Smart Punctuation Delay:** Automatically adds realistic human-like pauses when typing punctuation marks (`.`, `,`, `?`, `!`, `:`).
* **🛡️ Secure Clipboard Wipe:** Protect your sensitive data! Enable this to automatically clear your clipboard from system memory the exact moment the injection finishes.
* **🎨 Formatting Preservation:** Flawlessly maintains complex formatting, such as Python code indentation and spacing. It automatically fixes broken CRLF/LF line endings and optionally trims unnecessary leading or trailing whitespace.
* **🛑 Smart Interruption (Windows):** Full control at your fingertips. Press the **"Panic Key" (`Esc`)** to halt typing immediately. Furthermore, typing **automatically stops** if your target window loses focus, preventing you from accidentally typing sensitive data into the wrong chat or window!
* **🌐 Bilingual Support (Windows):** The intuitive graphical interface fully supports both **English** and **Arabic (العربية)** out of the box.
* **🔊 Accessibility & Feedback (Windows):** Features a screen-reader friendly interface with helpful audio feedback (beeps) during injection start, progress, and completion.
* **⚙️ Advanced Configuration (Windows):** Take full control by running ClipType as an **Administrator** (allowing it to inject text into elevated apps) and seamlessly setting it to **Start with Windows**.

---

## 🧠 Under the Hood (For Geeks)

ClipType isn't magic; it's pure, efficient engineering. Here is how it operates natively across different operating systems without relying on bloated libraries:

* **🪟 Windows:** Built natively with **AutoHotkey v2**. It creates a hidden buffer and sends robust `SendEvent {Raw}` events, guaranteeing absolute compatibility with virtual machines and stubborn remote sessions. It also auto-elevates to Admin to ensure your global hotkeys always work.
* **🐧 Linux:** A brilliantly smart Bash script that automatically detects your active display server. It seamlessly uses `wtype` for modern **Wayland** sessions and `xdotool` for classic **X11**, making it entirely distro-agnostic.
* **🍎 macOS:** Utilizes a highly optimized native **Swift** engine to simulate low-level keystrokes directly into the active application via `CGEvent`. No third-party dependencies required.

---

## 🛠️ Quick Usage

### 🪟 Windows

1. Run `ClipType.exe` (or the `.ahk` script).
2. Press your configured hotkey (default: **`Ctrl + Shift + V`**) to type your clipboard contents.
3. **Settings GUI:** Right-click the system tray icon and select **Settings** to access the comprehensive GUI. Configure your hotkey, typing delays, Anti-Bot options, Language, and more!

### 🐧 Linux

1. Ensure the required dependencies are installed (`wtype` and `wl-clipboard` for Wayland, OR `xdotool` and `xclip` for X11).
2. Execute the script via your terminal:

```bash
./cliptype.sh [options]

Options:
  -d, --delay <ms>      Base typing delay (default: 50)
  -r, --random <max>    Enable randomized typing with max delay
  -s, --smart           Enable smart punctuation pauses
  -w, --wipe            Securely clear clipboard after typing
  -h, --help            Show this help message
  -v, --version         Show version info
```

*(Tip: Bind the script to a custom global keyboard shortcut in your Desktop Environment for instant access!)*

### 🍎 macOS

1. Compile the Swift script (`swiftc cliptype.swift`) or run it directly.
2. Execute the binary via your terminal:

```bash
./cliptype [options]

Options:
  --delay <ms>      Base typing delay (default: 50)
  --random <max>    Enable randomized typing with max delay
  --smart           Enable smart punctuation pauses
  --wipe            Securely clear clipboard after typing
```

---

## 🤝 Contributing

Contributions to this project are highly welcome! If you find a bug, have an amazing idea for an improvement, or want to contribute in any other way, please feel free to open an issue or submit a pull request.

> **Note:** Please ensure you use **LF** line endings for Linux/macOS files and **UTF-8 with BOM** for the Windows `.ahk` script.

## 📄 License

This project is licensed under the [**MIT License**](/LICENSE).
