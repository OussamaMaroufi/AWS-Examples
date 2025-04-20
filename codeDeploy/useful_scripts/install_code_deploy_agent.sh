#!/bin/bash

# -------------------------------------------------------------------
# AWS CodeDeploy Agent Installer
# Supported OS: Amazon Linux, Ubuntu, RHEL, CentOS
# -------------------------------------------------------------------

# Exit on error
set -e

# Install dependencies
echo "Installing dependencies..."
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    case "$ID" in
        amzn)
            # Amazon Linux
            sudo yum update -y
            sudo yum install -y ruby wget
            ;;
        ubuntu)
            # Ubuntu
            sudo apt-get update
            sudo apt-get install -y ruby wget
            ;;
        rhel|centos)
            # RHEL or CentOS
            sudo yum update -y
            sudo yum install -y ruby wget
            ;;
        *)
            echo "Unsupported OS: $ID"
            exit 1
            ;;
    esac
else
    echo "Cannot determine OS. Exiting."
    exit 1
fi

# Download and install CodeDeploy agent
echo "Downloading AWS CodeDeploy agent..."
cd /tmp
wget https://aws-codedeploy-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/latest/install
chmod +x ./install

# Install
echo "Running installer..."
sudo ./install auto

# Verify agent status
echo "Checking agent status..."
sudo service codedeploy-agent status || sudo systemctl status codedeploy-agent

# Enable auto-start (if systemd)
if command -v systemctl &> /dev/null; then
    echo "Enabling auto-start..."
    sudo systemctl enable codedeploy-agent
fi

echo "AWS CodeDeploy agent installation complete!"