#!/bin/bash

# Detect the Linux distribution
if [ -f /etc/os-release ]; then
    source /etc/os-release
    DISTRO=$ID
elif [ -f /etc/lsb-release ]; then
    source /etc/lsb-release
    DISTRO=$DISTRIB_ID
else
    echo "Unsupported distribution. Please install SSH and configure it manually."
    exit 1
fi

# Function to check if the SSH server is installed
is_ssh_server_installed() {
    case $DISTRO in
        ubuntu|debian)
            dpkg -l | grep -q "openssh-server"
            ;;
        centos|rhel|fedora)
            rpm -q openssh-server
            ;;
        *)
            echo "Unsupported distribution. Please install SSH server manually."
            exit 1
            ;;
    esac
}

# Function to install SSH server
install_ssh_server() {
    case $DISTRO in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y openssh-server
            ;;
        centos|rhel|fedora)
            sudo yum -y install openssh-server
            ;;
        *)
            echo "Unsupported distribution. Please install SSH server manually."
            exit 1
            ;;
    esac
}

# Function to enable both password and public key authentication
enable_password_and_public_key_authentication() {
    sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sudo systemctl restart ssh
    echo "Both password and public key authentication are enabled."
}

# Function to import public keys from GitHub user profiles
import_github_public_keys() {
    # Prompt the user for GitHub usernames, with "harshsinghvi" as the default
    read -rp "Enter GitHub usernames (comma-separated, defaults to 'harshsinghvi'): " usernames
    usernames=${usernames:-harshsinghvi} # Set default if no input is provided

    # Split the comma-separated usernames into an array
    IFS=',' read -ra username_array <<< "$usernames"

    for username in "${username_array[@]}"; do
        username=$(echo "$username" | tr -d '[:space:]') # Remove whitespace
        GITHUB_USER_URL="https://github.com/$username.keys"
        
        # Fetch the keys and append them to the authorized_keys file with a comment
        KEYS=$(curl -s "$GITHUB_USER_URL")
        if [ -n "$KEYS" ]; then
            echo -e "# $username\n$KEYS" >> ~/.ssh/authorized_keys
            echo "Public keys from GitHub user $username added to authorized_keys."
        else
            echo "No public keys found for GitHub user $username."
        fi
    done
}

# Function to ask for confirmation
confirm_action() {
    read -rp "Do you want to import public keys from GitHub user profiles and configure SSH for both password and public key authentication? (y/N): " choice
    case "$choice" in
        [Yy]*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to download and install a script from a URL
download_and_install_script() {
    local url="$1"
    local script_name="$2"

    # Prompt the user for confirmation
    read -p "Do you want to download and install $script_name from $url? (y/n): " choice

    # Check the user's choice
    if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
        # Download the script and store it in the home directory
        curl -o "$HOME/$script_name" -L "$url"
        
        # Make the script executable
        chmod +x "$HOME/$script_name"
        
        echo "Script $script_name has been downloaded and installed in $HOME."
    else
        echo "Script installation canceled."
    fi
}

# Main script
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

# Check if SSH server is already installed
if ! is_ssh_server_installed; then
    # Install and configure SSH server
    install_ssh_server
fi

# Enable password and public key authentication
enable_password_and_public_key_authentication

# Ask for confirmation before importing keys
if confirm_action; then
    # Import public keys from GitHub user profiles
    import_github_public_keys

    echo "SSH access is now enabled and configured for both password and public key authentication."
else
    echo "No public keys were imported. SSH access remains configured for both password and public key authentication."
fi

download_and_install_script "https://raw.githubusercontent.com/harshsinghvi/manage_ssh.sh/master/manage_ssh_keys.sh" "manage_ssh_keys.sh"
