#!/bin/bash

# Get OS and architecture information first
OS=$(uname -s)
ARCH=$(uname -m)

# Map architecture names for consistency
if [ "$ARCH" = "aarch64" ]; then 
    ARCH=arm64
elif [ "$ARCH" = "x86_64" ]; then
    ARCH=x86_64
fi

ARCHITECTURE="${OS}_${ARCH}"

# Print OS information in a user-friendly way - FIRST OUTPUT
if [ "$OS" = "Linux" ]; then
    DISTRO=$(cat /etc/os-release 2>/dev/null | grep -E "^NAME=" | cut -d= -f2 | tr -d '"')
    VERSION=$(cat /etc/os-release 2>/dev/null | grep -E "^VERSION=" | cut -d= -f2 | tr -d '"')
    echo "System detected: Linux ($DISTRO $VERSION) with $ARCH architecture"
elif [ "$OS" = "Darwin" ]; then
    MACOS_VERSION=$(sw_vers -productVersion 2>/dev/null)
    if [ "$ARCH" = "arm64" ]; then
        echo "System detected: MacOS $MACOS_VERSION on Apple Silicon (M-series) hardware"
    else
        echo "System detected: MacOS $MACOS_VERSION on Intel hardware"
    fi
else
    echo "System detected: $OS with $ARCH architecture"
fi
 
# Check if TMFS is already installed
if command -v tmfs &> /dev/null
then
    CURRENT_VERSION=$(tmfs --version 2>&1 | head -n 1 | awk '{print $NF}')
    echo "Vision One File Security SDK CLI version $CURRENT_VERSION is already installed."
    read -p "Do you want to update to the latest version? (y/n): " ANSWER
    if [[ "$ANSWER" != "y" && "$ANSWER" != "Y" ]]; then
        echo "Update cancelled. Exiting."
        exit 0
    fi
    echo "Proceeding with update..."
fi

# Check if JQ is installed.
if ! command -v jq &> /dev/null
then
    echo "JQ could not be found. Please install JQ before continuing."
    exit 1
fi
 
# Check if curl is installed.
if ! command -v curl &> /dev/null
then
    echo "curl could not be found. Please install curl before continuing."
    exit 1
fi
 
# Check if sudo is installed.
if ! command -v sudo &> /dev/null
then
    echo "sudo could not be found. Please install sudo before continuing."
    exit 1
fi
 
BASE_URL="https://tmfs-cli.fs-sdk-ue1.xdr.trendmicro.com/tmfs-cli/"
METADATA_URL="${BASE_URL}metadata.json"

# Get the latest version from metadata.json (if available)
if curl -s -f "$METADATA_URL" > /dev/null; then
    VERSION_STRING=$(curl -s "$METADATA_URL" | jq -r '.latestVersion')
    VERSION="${VERSION_STRING:1}"
    echo "Latest version is: $VERSION"
else
    echo "Could not find version information. Proceeding with latest available binary."
fi

echo "Downloading latest version of Vision One File Security SDK CLI for $OS in architecture $ARCHITECTURE"

# Handle different OS types
if [ "$OS" = "Linux" ]; then
    echo "Installing for Linux system"
    if [ "$ARCH" = "arm64" ]; then
        URL="${BASE_URL}latest/tmfs-cli_Linux_arm64.tar.gz"
    elif [ "$ARCH" = "x86_64" ]; then
        URL="${BASE_URL}latest/tmfs-cli_Linux_x86_64.tar.gz"
    elif [ "$ARCH" = "i386" ] || [ "$ARCH" = "i686" ]; then
        URL="${BASE_URL}latest/tmfs-cli_Linux_i386.tar.gz"
    else
        echo "Unsupported Linux architecture: $ARCH"
        exit 1
    fi
    
    echo "Downloading from: $URL"
    curl -s "$URL" | tar -xz tmfs
elif [ "$OS" = "Darwin" ]; then
    echo "Installing for MacOS system (${ARCH})"
    if [ "$ARCH" = "arm64" ]; then
        echo "Using Apple Silicon binary"
        URL="${BASE_URL}latest/tmfs-cli_Darwin_arm64.zip"
    elif [ "$ARCH" = "x86_64" ]; then
        echo "Using Intel binary"
        URL="${BASE_URL}latest/tmfs-cli_Darwin_x86_64.zip"
    else
        echo "Unsupported MacOS architecture: $ARCH"
        exit 1
    fi
    
    echo "Downloading from: $URL"
    curl -s -L "$URL" -o tmfs.zip
    unzip -p tmfs.zip tmfs > extracted_tmfs
    mv extracted_tmfs tmfs
    chmod +x tmfs
    rm -rf tmfs.zip
else
    echo "Unsupported operating system: $OS"
    exit 1
fi
 
echo "Moving the binary to \"/usr/local/bin/\". It might request root access."
sudo mv tmfs /usr/local/bin/
 
# Verify installation
if command -v tmfs &> /dev/null
then
    NEW_VERSION=$(tmfs --version 2>&1 | head -n 1 | awk '{print $NF}')
    if [[ -n "$CURRENT_VERSION" ]]; then
        echo "Vision One File Security SDK CLI has been successfully updated from version $CURRENT_VERSION to $NEW_VERSION!"
    else
        echo "Vision One File Security SDK CLI has been successfully installed! Version: $NEW_VERSION"
    fi
    echo "You can run 'tmfs --version' to verify the installation."
    
    # Add recommendation for setting up API key
    echo ""
    echo "===== NEXT STEPS ====="
    echo "To start using Vision One File Security SDK CLI, set up your Vision One API key with:"
    echo ""
    echo "export TMFS_API_KEY=<your_vision_one_api_key>"
    echo ""
    echo "You can add this to your shell profile (~/.bashrc, ~/.zshrc, etc.) to make it permanent."
else
    echo "Installation failed. Please check the error messages above."
    exit 1
fi
