#!/bin/bash

# ==============================================================================
#  ClipType Installer for Linux
# ==============================================================================

SCRIPT_NAME="cliptype"
INSTALL_DIR="/usr/local/bin"
SOURCE_FILE="./cliptype.sh"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)."
  exit 1
fi

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
  echo "Error: $SOURCE_FILE not found!"
  echo "Make sure you are in the correct directory."
  exit 1
fi

# Install
echo "Installing $SCRIPT_NAME to $INSTALL_DIR..."
cp "$SOURCE_FILE" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

echo "Success! You can now use '$SCRIPT_NAME' from anywhere."
echo "Make sure to set a keyboard shortcut pointing to: $SCRIPT_NAME"