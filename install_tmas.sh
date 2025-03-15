#!/bin/bash

# Trend Micro Artifact Scan install script for Linux and MacOS.
# For more details, check the official documentation: https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-integrating-tmas-ci-cd-pipeline

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
 
# Check if TMAS is already installed
if command -v tmas &> /dev/null
then
    CURRENT_VERSION=$(tmas --version 2>&1 | head -n 1 | awk '{print $NF}')
    echo "TMAS CLI version $CURRENT_VERSION is already installed."
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
 
BASE_URL=https://cli.artifactscan.cloudone.trendmicro.com/tmas-cli/
METADATA_URL="${BASE_URL}metadata.json"
VERSION_STRING=$(curl -s $METADATA_URL | jq -r '.latestVersion')
VERSION="${VERSION_STRING:1}"
echo "Latest version is: $VERSION"
 
OS=$(uname -s)
ARCH=$(uname -m)

# Map architecture names for consistency
if [ "$ARCH" = "aarch64" ]; then 
    ARCH=arm64
elif [ "$ARCH" = "x86_64" ]; then
    ARCH=x86_64
fi

ARCHITECTURE="${OS}_${ARCH}"

# Print OS information in a user-friendly way
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

echo "Downloading version $VERSION of tmas CLI for $OS in architecture $ARCHITECTURE"

# Handle different OS types
if [ "$OS" = "Linux" ]; then
    echo "Installing for Linux system"
    URL="${BASE_URL}latest/tmas-cli_$ARCHITECTURE.tar.gz"
    curl -s "$URL" | tar -xz tmas
elif [ "$OS" = "Darwin" ]; then
    echo "Installing for MacOS system (${ARCH})"
    if [ "$ARCH" = "arm64" ]; then
        echo "Using Apple Silicon binary"
        URL="${BASE_URL}latest/tmas-cli_Darwin_arm64.zip"
    elif [ "$ARCH" = "x86_64" ]; then
        echo "Using Intel binary"
        URL="${BASE_URL}latest/tmas-cli_Darwin_x86_64.zip"
    else
        echo "Unsupported MacOS architecture: $ARCH"
        exit 1
    fi
    
    echo "Downloading from: $URL"
    curl -s -L "$URL" -o tmas.zip
    unzip -p tmas.zip tmas > extracted_tmas
    mv extracted_tmas tmas
    chmod +x tmas
    rm -rf tmas.zip
else
    echo "Unsupported operating system: $OS"
    exit 1
fi
 
echo "Moving the binary to \"/usr/local/bin/\". It might request root access."
sudo mv tmas /usr/local/bin/
 
# If v1cs is already installed, create a symbolic link to tmas to maintain compatibility.
if command -v c1cs &> /dev/null
then
    echo "Creating symbolic link from c1cs to tmas to maintain compatibility. Note: this might be removed in the future."
    sudo ln -sf /usr/local/bin/tmas /usr/local/bin/c1cs
fi

# Verify installation
if command -v tmas &> /dev/null
then
    NEW_VERSION=$(tmas --version 2>&1 | head -n 1 | awk '{print $NF}')
    if [[ -n "$CURRENT_VERSION" ]]; then
        echo "TMAS CLI has been successfully updated from version $CURRENT_VERSION to $NEW_VERSION!"
    else
        echo "TMAS CLI has been successfully installed! Version: $NEW_VERSION"
    fi
    echo "You can run 'tmas --version' to verify the installation."
else
    echo "Installation failed. Please check the error messages above."
    exit 1
fi
