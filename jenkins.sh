#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e
# Function to install on Debian/Ubuntu
install_debian() {
    echo "------------------------------------------------"
    echo "Detected Debian/Ubuntu based system."
    echo "------------------------------------------------"
    
    echo "Updating package index..."
    sudo apt-get update -y
    
    echo "Installing Java 21 (OpenJDK) and dependencies..."
    sudo apt-get install fontconfig openjdk-21-jre -y
    
    echo "Verifying Java version..."
    java -version
    
    echo "Setting up Jenkins repository..."
    # Ensure keyrings directory exists
    sudo mkdir -p /etc/apt/keyrings
    
    # Download the key
    sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
      
    # Add the repository
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
      https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
      /etc/apt/sources.list.d/jenkins.list > /dev/null
      
    echo "Updating package index with Jenkins repo..."
    sudo apt-get update -y
    
    echo "Installing Jenkins..."
    sudo apt-get install jenkins -y
    
    echo "Enabling and Starting Jenkins..."
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    
    echo "------------------------------------------------"
    echo "Jenkins installation complete."
    echo "------------------------------------------------"
}
# Function to install on RHEL/CentOS/Fedora
install_redhat() {
    echo "------------------------------------------------"
    echo "Detected RHEL/CentOS/Fedora based system."
    echo "------------------------------------------------"
    
    echo "Adding Jenkins repository..."
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
        https://pkg.jenkins.io/redhat-stable/jenkins.repo
        
    echo "Upgrading system packages..."
    sudo yum upgrade -y
    
    echo "Installing Java 21 (OpenJDK) and dependencies..."
    sudo yum install fontconfig java-21-openjdk -y
    
    echo "Installing Jenkins..."
    sudo yum install jenkins -y
    
    echo "Enabling and Starting Jenkins..."
    sudo systemctl daemon-reload
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    
    echo "------------------------------------------------"
    echo "Jenkins installation complete."
    echo "------------------------------------------------"
}
# ------------------------------------------------
# Main Detection Logic
# ------------------------------------------------
if [ -f /etc/os-release ]; then
    # Import variables from os-release (ID, ID_LIKE, etc.)
    . /etc/os-release
    
    echo "Detected OS ID: $ID"
    
    # Check for Debian/Ubuntu family
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
        install_debian
        
    # Check for RHEL/CentOS/Fedora family
    elif [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "fedora" || "$ID" == "amzn" || "$ID_LIKE" == *"rhel"* || "$ID_LIKE" == *"fedora"* ]]; then
        install_redhat
        
    else
        echo "OS distribution '$ID' not explicitly supported by this script's detection logic."
        echo "Checking for package managers..."
        if command -v apt-get &> /dev/null; then
             install_debian
        elif command -v yum &> /dev/null; then
             install_redhat
        else
             echo "Error: Neither apt-get nor yum found. Cannot proceed."
             exit 1
        fi
    fi
else
    echo "/etc/os-release not found. Attempting fallback detection..."
    if command -v apt-get &> /dev/null; then
        install_debian
    elif command -v yum &> /dev/null; then
        install_redhat
    else
        echo "Error: Could not detect OS or package manager."
        exit 1
    fi
fi
# Final status check
echo ""
echo "Checking Jenkins Status..."
sudo systemctl status jenkins --no-pager