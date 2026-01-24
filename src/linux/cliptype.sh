#!/bin/bash

# ==============================================================================
#  ClipType - Professional Clipboard Injector (Linux)
#  Version: 1.0.0
#  License: MIT
#  Author: Ahmed Samy
# ==============================================================================

VERSION="3.2.0"
DELAY=50 # Default delay in milliseconds

# --- Helper: Print Usage ---
usage() {
    echo "ClipType v$VERSION"
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -d, --delay <ms>   Set typing delay in milliseconds (default: 50)"
    echo "  -h, --help         Show this help message"
    echo "  -v, --version      Show version info"
    echo ""
    echo "Examples:"
    echo "  $0                 # Type clipboard content with default delay"
    echo "  $0 -d 100          # Type slower (100ms delay)"
    exit 0
}

# --- Parse Arguments ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d|--delay) DELAY="$2"; shift ;;
        -h|--help) usage ;;
        -v|--version) echo "ClipType v$VERSION"; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# --- Logic: Detect Session Type ---
SESSION_TYPE=""
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    SESSION_TYPE="wayland"
else
    # Fallback to X11 if not explicitly Wayland
    SESSION_TYPE="x11"
fi

# --- Logic: Check Dependencies & Fetch Clipboard ---
CLIP_CONTENT=""

if [ "$SESSION_TYPE" == "wayland" ]; then
    # === Wayland Path ===
    if ! command -v wl-paste &> /dev/null || ! command -v wtype &> /dev/null; then
        echo "Error: Missing dependencies for Wayland."
        echo "Please install: wl-clipboard and wtype"
        echo "  Arch: sudo pacman -S wl-clipboard wtype"
        echo "  Debian/Ubuntu: sudo apt install wl-clipboard (wtype might need manual install)"
        exit 1
    fi
    CLIP_CONTENT=$(wl-paste --no-newline)

else
    # === X11 Path ===
    if ! command -v xclip &> /dev/null || ! command -v xdotool &> /dev/null; then
        echo "Error: Missing dependencies for X11."
        echo "Please install: xclip and xdotool"
        echo "  Arch: sudo pacman -S xclip xdotool"
        echo "  Debian/Ubuntu: sudo apt install xclip xdotool"
        exit 1
    fi
    CLIP_CONTENT=$(xclip -selection clipboard -o)
fi

# --- Sanity Check ---
if [ -z "$CLIP_CONTENT" ]; then
    echo "Clipboard is empty."
    exit 0
fi

# --- Logic: Type it out! ---
# Note: We use a small sleep to allow user to release keys if run via shortcut
sleep 0.2

if [ "$SESSION_TYPE" == "wayland" ]; then
    # wtype handles modification keys well
    wtype -d "$DELAY" "$CLIP_CONTENT"
else
    # xdotool needs --file - to handle special chars properly from stdin to avoid parsing issues
    echo -n "$CLIP_CONTENT" | xdotool type --clearmodifiers --delay "$DELAY" --file -
fi

exit 0