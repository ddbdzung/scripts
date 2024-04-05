#!/bin/bash
# Author: Dzung Dang (https://github.com/ddbdzung)

function get_host_config() {
    local host=$1
    local host_config=$(awk -v host="$host" '$1 == "Host" && $2 == host { found=1 } found && /^$/ { exit } found { print }' ~/.ssh/config)
    echo "$host_config" # Return the host configuration
}
function get_host_config_value() {
    local host_config=$1
    local key=$2
    local value=$(echo "$host_config" | grep "$key" | awk '{print $2}')
    echo "$value" # Return the value of the key
}

function main() {
    local host_in_config=$1
    local remote_host=$(get_host_config_value "$(get_host_config $host_in_config)" "HostName")
    if [ -z "$remote_host" ]; then
        echo "The remote host is empty. Please check the SSH config file"
        exit 1
    fi

    local repo_name=$2 # The name of the repository is the name of the folder
    cd "$repo_name" || exit 1 # Change to the repository folder or exit if it doesn't exist
    local parent_dir_name=$(basename $(dirname $PWD))
    if [ -d ".git" ]; then # Check if the folder is a git repository
        local remote_url=$(git remote get-url origin) # Get the remote URL of the repository
        local new_remote_url="git@$remote_host:$parent_dir_name/$repo_name.git"
        if [ "$remote_url" != "$new_remote_url" ]; then # Check if the repository name is different from the folder name
            echo -e "\e[32mChanging\e[0m $remote_url => $new_remote_url"
            git remote set-url origin $new_remote_url # Rename the remote repository
        else
            echo "The remote repository name is the same as remote in local: $repo_name"
        fi
    else
        echo "The folder is not a git repository or doesn't exist: $repo_name"
    fi
    cd .. # Go back to the parent directory
}

echo "Enter the host in the SSH config file:"
read -r host_in_config_file
echo ""
if [ -z "$host_in_config_file" ]; then
    echo "The host is empty"
    exit 1
fi

# Loop through all the folders in the current directory, except the hidden folders and a list of folders to ignore
excluded_folders=()

for folder in */; do
    folder=${folder%/} # Remove the trailing slash
    if [[ ! " ${excluded_folders[@]} " =~ " ${folder} " ]]; then
        echo -e "\e[32mProcessing\e[0m $folder"
        main "$host_in_config_file" "$folder"
        echo -e "\e[32mFinished processing\e[0m $folder"
        echo ""
    fi
done
