#!/bin/bash

# ==============================================================================
#  ClipType - Professional Clipboard Injector (Linux Edition)
#  Architecture: Multi-Backend (Wayland/X11)
#  Version: 1.0.0
#  Author: Ahmed Samy
# ==============================================================================

VERSION="1.0.0"
DELAY=50
MAX_DELAY=150
USE_RANDOM=0
SECURE_WIPE=0
SMART_PUNCT=0

# --- Trap signals for clean exit ---
trap 'exit_handler' SIGINT SIGTERM

exit_handler() {
    printf "\n[!] Operation interrupted by user. Exiting...\n"
    exit 130
}

usage() {
    printf "ClipType v%s\n" "$VERSION"
    printf "Usage: %s [options]\n\n" "$0"
    printf "Options:\n"
    printf "  -d, --delay <ms>      Base typing delay (default: 50)\n"
    printf "  -r, --random <max>    Enable randomized typing with max delay\n"
    printf "  -s, --smart           Enable smart punctuation pauses\n"
    printf "  -w, --wipe            Securely clear clipboard after typing\n"
    printf "  -h, --help            Show this help message\n"
    printf "  -v, --version         Show version info\n\n"
    exit 0
}

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d|--delay) DELAY="$2"; shift ;;
        -r|--random) MAX_DELAY="$2"; USE_RANDOM=1; shift ;;
        -s|--smart) SMART_PUNCT=1 ;;
        -w|--wipe) SECURE_WIPE=1 ;;
        -h|--help) usage ;;
        -v|--version) printf "ClipType v%s\n" "$VERSION"; exit 0 ;;
        *) printf "Unknown parameter: %s\n" "$1"; exit 1 ;;
    esac
    shift
done

# --- Environment Detection ---
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    BACKEND="wayland"
    if ! command -v wl-paste &> /dev/null || ! command -v wtype &> /dev/null; then
        printf "Error: Missing wayland dependencies (wl-clipboard, wtype).\n" >&2
        exit 1
    fi
    CLIP_CONTENT=$(wl-paste --no-newline)
else
    BACKEND="x11"
    if ! command -v xclip &> /dev/null || ! command -v xdotool &> /dev/null; then
        printf "Error: Missing x11 dependencies (xclip, xdotool).\n" >&2
        exit 1
    fi
    # Preserve trailing newlines using dummy suffix character
    CLIP_CONTENT=$(xclip -selection clipboard -o; printf "x")
    CLIP_CONTENT=${CLIP_CONTENT%x}
fi

if [ -z "$CLIP_CONTENT" ]; then
    printf "Clipboard is empty.\n"
    exit 0
fi

# Pre-injection buffer
sleep 0.2

# --- Injection Engine ---
# Iterate through each character to support precise delays and smart logic
while IFS= read -rn1 char; do
    # Handle the character (read -n1 skips newlines, so we handle them separately if needed)
    # But for simplicity and reliability across backends:
    if [ "$BACKEND" == "wayland" ]; then
        wtype "$char"
    else
        printf "%s" "$char" | xdotool type --clearmodifiers --delay 0 --file -
    fi

    # Logic: Smart Punctuation
    if [[ "$SMART_PUNCT" -eq 1 && "$char" =~ [.,?!:] ]]; then
        sleep 0.4
    elif [ "$USE_RANDOM" -eq 1 ]; then
        # Calculate random delay between DELAY and MAX_DELAY
        RAND_SLEEP=$(awk -v min="$DELAY" -v max="$MAX_DELAY" 'BEGIN{srand(); print (min+rand()*(max-min))/1000}')
        sleep "$RAND_SLEEP"
    else
        sleep "$(bc -l <<< "$DELAY/1000")"
    fi
done <<< "$CLIP_CONTENT"

# --- Post-Execution ---
if [ "$SECURE_WIPE" -eq 1 ]; then
    if [ "$BACKEND" == "wayland" ]; then
        wl-copy --clear
    else
        xclip -selection clipboard /dev/null
    fi
    printf "\n[+] Clipboard securely wiped.\n"
fi

exit 0