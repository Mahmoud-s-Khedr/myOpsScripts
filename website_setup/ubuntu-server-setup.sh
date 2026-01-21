#!/bin/bash

# -----------------------------------------------------------------------------
# Ubuntu Server Initial Setup Script
# Installs: Nginx, Docker (Official Repo), Git, Certbot (Let's Encrypt)
# -----------------------------------------------------------------------------

# 1. Check for Root Privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[31mError: Please run as root (use sudo).\033[0m"
    exit 1
fi

echo -e "\033[34mStarting Initial Server Setup...\033[0m"

# 2. Update and Upgrade System
echo "--- Updating system packages ---"
apt-get update && apt-get upgrade -y
apt-get install -y ca-certificates curl gnupg lsb-release

# 3. Install Git
echo "--- Installing Git ---"
apt-get install -y git

# 4. Install Nginx
echo "--- Installing Nginx ---"
apt-get install -y nginx

# Adjust Firewall (UFW) if it is active
if ufw status | grep -q "Status: active"; then
    echo "UFW is active. Allowing 'Nginx Full'..."
    ufw allow 'Nginx Full'
fi

# 5. Install Docker (Official Docker Repository)
echo "--- Installing Docker ---"

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Install Certbot (Let's Encrypt)
echo "--- Installing Certbot and Nginx Plugin ---"
apt-get install -y certbot python3-certbot-nginx

# 7. Post-Installation Configuration
echo "--- Configuring Permissions ---"

# Add current user (if sudo was used) to docker group to avoid typing sudo for docker commands
# We look for the user who called sudo (SUDO_USER), otherwise we skip.
if [ -n "$SUDO_USER" ]; then
    echo "Adding user $SUDO_USER to the 'docker' group..."
    usermod -aG docker $SUDO_USER
fi

# 8. Verification
echo -e "\n\033[32mInstallation Complete!\033[0m"
echo "------------------------------------------------"
echo "Git Version:     $(git --version)"
echo "Nginx Version:   $(nginx -v 2>&1 | cut -d '/' -f 2)"
echo "Docker Version:  $(docker --version)"
echo "Certbot Version: $(certbot --version 2>&1)"
echo "------------------------------------------------"
echo -e "\033[33mNOTE: If you were added to the docker group, please log out and log back in for changes to take effect.\033[0m"
