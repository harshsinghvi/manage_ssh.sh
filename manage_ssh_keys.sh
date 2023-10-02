#!/bin/bash

# Function to remove all keys of a GitHub user from the authorized_keys file
remove_all_github_user_keys() {
    local github_username="$1"
    
    echo "Removing all keys of GitHub user $github_username from authorized_keys."
    
    # Create a temporary file to store the keys to keep
    tmp_file=$(mktemp)
    
    # Read the authorized_keys file line by line
    while IFS= read -r line; do
        # Check if the line contains the start comment of the GitHub user keys
        if [[ "$line" == "# $github_username" ]]; then
            # Skip lines until the end comment of the GitHub user keys is found
            while IFS= read -r line; do
                if [[ "$line" == "# $github_username-end" ]]; then
                    break
                fi
            done
            continue
        fi
        
        # If the line does not match the start or end comment, keep it
        echo "$line" >> "$tmp_file"
    done < ~/.ssh/authorized_keys
    
    # Overwrite the authorized_keys file with the keys to keep
    mv "$tmp_file" ~/.ssh/authorized_keys
}

# Function to add keys of a GitHub user to the authorized_keys file
add_github_user_keys() {
    local github_username="$1"
    
    echo "Adding keys of GitHub user $github_username to authorized_keys."
    
    # Fetch the keys from GitHub
    GITHUB_USER_URL="https://github.com/$github_username.keys"
    KEYS=$(curl -s "$GITHUB_USER_URL")

    if [ -n "$KEYS" ]; then
        # Add a comment to mark the start of GitHub user keys
        echo "# $github_username" >> ~/.ssh/authorized_keys
        echo "$KEYS" >> ~/.ssh/authorized_keys
        # Add a comment to mark the end of GitHub user keys
        echo "# $github_username-end" >> ~/.ssh/authorized_keys
    else
        echo "No public keys found for GitHub user $github_username."
    fi
}

# Function to list usernames mentioned in the authorized_keys file
list_usernames() {
    echo "List of usernames mentioned in authorized_keys:"
    
    # Read the authorized_keys file line by line and extract usernames
    while IFS= read -r line; do
        if [[ "$line" == "# "* ]]; then
            # Extract the username from the comment line
            username="${line#*# }"
            echo "$username"
        fi
    done < ~/.ssh/authorized_keys
}

# Main script
if [ $# -lt 2 ]; then
    echo "Usage: $0 [add|remove|list] [github_username]"
    exit 1
fi

action="$1"
github_username="$2"

if [ "$action" == "add" ]; then
    add_github_user_keys "$github_username"
elif [ "$action" == "remove" ]; then
    remove_all_github_user_keys "$github_username"
elif [ "$action" == "list" ]; then
    list_usernames
else
    echo "Usage: $0 [add|remove|list] [github_username]"
    exit 1
fi
