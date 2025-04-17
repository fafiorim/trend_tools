#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name: setup-k8s-tools.sh
#
# Description:
#   This script installs and verifies the availability of the following tools:
#     - AWS CLI
#     - eksctl (for managing EKS clusters)
#     - kubectl (Kubernetes CLI)
#     - Helm (Kubernetes package manager)
#   It also checks if the AWS CLI is properly configured.
#
# Usage:
#   Run this script on a Linux system to prepare a Kubernetes/EKS working environment.
#
# Author: Franz
# -----------------------------------------------------------------------------

set -e  # Exit the script immediately if any command returns a non-zero exit status

# -----------------------------------------------------------------------------
# Install AWS CLI if not already installed
# -----------------------------------------------------------------------------
if ! command -v aws &>/dev/null; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/
    echo "AWS CLI installed successfully."
else
    echo "AWS CLI is already installed."
fi

# Print AWS CLI version
aws --version

# -----------------------------------------------------------------------------
# Install eksctl if not already installed
# -----------------------------------------------------------------------------
if ! command -v eksctl &>/dev/null; then
    echo "Installing eksctl..."
    
    ARCH=amd64  # Architecture type; modify if running on ARM (e.g., aarch64)
    PLATFORM=$(uname -s)_$ARCH  # Combines OS name and architecture

    # Download the latest eksctl release
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
    
    # Optional: Verify download integrity using checksum
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
    
    # Extract and move binary to system path
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
    sudo mv /tmp/eksctl /usr/local/bin
    echo "eksctl installed successfully."
else
    echo "eksctl is already installed."
fi

# Print eksctl version
eksctl version

# -----------------------------------------------------------------------------
# Install kubectl if not already installed
# -----------------------------------------------------------------------------
if ! command -v kubectl &>/dev/null; then
    echo "Installing kubectl..."

    # Download the latest stable release
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    
    # Move the binary to a directory in PATH
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    chmod +x kubectl
    mkdir -p ~/.local/bin
    mv ./kubectl ~/.local/bin/kubectl

    echo "kubectl installed successfully."
else
    echo "kubectl is already installed."
fi

# Print kubectl version
kubectl version --client

# -----------------------------------------------------------------------------
# Install Helm if not already installed
# -----------------------------------------------------------------------------
if ! command -v helm &>/dev/null; then
    echo "Installing Helm..."
    
    # Download and run Helm installation script
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh

    echo "Helm installed successfully."
else
    echo "Helm is already installed."
fi

# Print Helm version
helm version

# -----------------------------------------------------------------------------
# Validate AWS CLI Configuration
# -----------------------------------------------------------------------------
if ! aws sts get-caller-identity &>/dev/null; then
    echo "AWS CLI is not properly configured. Please run 'aws configure' first."
    exit 1
fi

echo "AWS CLI is properly configured."
