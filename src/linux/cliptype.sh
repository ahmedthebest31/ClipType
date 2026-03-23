#!/bin/bash

# ==============================================================================
#  ClipType - Professional Clipboard Injector (Linux)
#  Version: 1.0.0
#  License: MIT
#  Author: Ahmed Samy
# ==============================================================================

VERSION="1.0.0"
DELAY=50 # Default delay in milliseconds

# --- Helper: Print Usage ---
usage() {
    printf "ClipType v%s\n" "$VERSION"
    printf "Usage: %s [options]\n\n" "$0"
    printf "Options:\n"
    printf "  -d, --delay <ms>    Set typing delay in milliseconds (default: 50)\n"
    printf "  -h, --help          Show this help message\n"
    printf "  -v, --version       Show version info\n\n"
    printf "Examples:\n"
    printf "  %s                  # Type clipboard content with default delay\n" "$0"
    printf "  %s -d 100           # Type slower (100ms delay)\n" "$0"
    exit 0
}

# --- Parse Arguments ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d|--delay) DELAY="$2"; shift ;;
        -h|--help) usage ;;
        -v|--version) printf "ClipType v%s\n" "$VERSION"; exit 0 ;;
        *) printf "Unknown parameter passed: %s\n" "$1"; exit 1 ;;
    esac
    shift
done

# --- Logic: Detect Session Type ---
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    SESSION_TYPE="wayland"
else
    SESSION_TYPE="x11"
fi

# --- Logic: Check Dependencies & Fetch Clipboard ---
if [ "$SESSION_TYPE" == "wayland" ]; then
    if ! command -v wl-paste &> /dev/null || ! command -v wtype &> /dev/null; then
        printf "Error: Missing dependencies for Wayland.\n"
        printf "Please install: wl-clipboard and wtype\n"
        exit 1
    fi
    # Use raw output to preserve exact content
    CLIP_CONTENT=$(wl-paste --no-newline)
else
    if ! command -v xclip &> /dev/null || ! command -v xdotool &> /dev/null; then
        printf "Error: Missing dependencies for X11.\n"
        printf "Please install: xclip and xdotool\n"
        exit 1
    fi
    # Use printf trick to prevent shell from stripping trailing newlines
    CLIP_CONTENT=$(xclip -selection clipboard -o; printf "x")
    CLIP_CONTENT=${CLIP_CONTENT%x}
fi

# --- Sanity Check ---
if [ -z "$CLIP_CONTENT" ]; then
    printf "Clipboard is empty.\n"
    exit 0
fi

# --- Logic: Type it out! ---
# Small safety delay to allow user to release keys
sleep 0.2

if [ "$SESSION_TYPE" == "wayland" ]; then
    wtype -d "$DELAY" "$CLIP_CONTENT"
else
    # Use printf to pipe raw data to avoid echo's backslash interpretation
    printf "%s" "$CLIP_CONTENT" | xdotool type --clearmodifiers --delay "$DELAY" --file -
fi

exit 0