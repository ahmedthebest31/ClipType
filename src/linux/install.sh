#!/bin/bash

# ==============================================================================
#  ClipType Installer for Linux
#  Description: Installs the script to /usr/local/bin with correct permissions.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

SCRIPT_NAME="cliptype"
INSTALL_DIR="/usr/local/bin"
SOURCE_FILE="./cliptype.sh"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Permission denied. Please run as root (use sudo)."
  exit 1
fi

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
  echo "Error: Source file '$SOURCE_FILE' not found in the current directory."
  exit 1
fi

echo "Installing $SCRIPT_NAME..."

# Create directory if it doesn't exist (Idempotent)
mkdir -p "$INSTALL_DIR"

# Install the file: copies it AND sets permissions (rwxr-xr-x) atomically
install -m 755 "$SOURCE_FILE" "$INSTALL_DIR/$SCRIPT_NAME"

echo "Success! '$SCRIPT_NAME' has been installed to $INSTALL_DIR"
echo "You can now run it simply by typing: $SCRIPT_NAME"