#!/bin/bash

# # Function to check if sudo is installed
# check_sudo() {
#     if command -v sudo &> /dev/null; then
#         return 0
#     else
#         return 1
#     fi
# }

# # Function to execute a command with sudo or directly
# execute_with_sudo_or_directly() {
#     local command_to_run="$*"

#     if check_sudo; then
#         sudo $command_to_run
#     else
#         $command_to_run
#     fi
# }

download_and_install_script() {
    local url="$1"
    local script_name="$2"
    curl -o "$HOME/$script_name" -L "$url"
    # Make the script executable
    chmod +x "$HOME/$script_name"
    echo "Script $script_name has been downloaded and installed in $HOME."
}

# Main script

if check_sudo; then
    echo "sudo is installed on this system."
else
    echo "sudo is not installed on this system."
fi

cd $HOME

download_and_install_script "https://raw.githubusercontent.com/harshsinghvi/manage_ssh.sh/master/manage_ssh.sh" "manage_ssh.sh"

echo Run sudo ./manage_ssh.sh to execute the script
# Example: Run a command with sudo or directly
# execute_with_sudo_or_directly bash manage_ssh.sh 
