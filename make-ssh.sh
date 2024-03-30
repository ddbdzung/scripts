#!/bin/bash
# Author: David Dang (https://github.com/ddbdzung)

cd ~/.ssh
# Generate a new SSH key
echo "Generating a new SSH key, type your email address:"
read email
# Loop until the email address is not empty
while [ -z "$email" ]; do
    echo "The email address cannot be empty."
    read email
done

# Loop the email until it contains an "@" symbol
while [[ ! "$email" == *"@"* ]]; do
    echo "The email address is not valid. @ required"
    read email
done
# Loop the email until it does not contain a space
while [[ $email == *" "* ]]; do
    echo "The email address cannot contain spaces."
    read email
done
if [[ $email == *" "* ]]; then
    echo "The email address cannot contain spaces."
    exit 1
fi

echo "Type the file name for the new SSH key: (default: id_rsa)"
read file_name
# Validate the file name input: if it is empty, set the default value to "id_rsa"
if [ -z "$file_name" ]; then
    file_name="id_rsa"
fi
# Loop until the file name does not contain a space
while [[ $file_name == *" "* ]]; do
    echo "The file name cannot contain spaces."
    read file_name
done

echo "Add a passphrase to the new SSH key? (default is no)"
read add_passphrase
if [ "$add_passphrase" == "" ]; then
    ssh-keygen -t rsa -b 4096 -C "$email" -f "$file_name" -N ""
else
    ssh-keygen -t rsa -b 4096 -C "$email" -f "$file_name" -N "$add_passphrase"
fi

# Add the new SSH key to the ssh-agent
eval "$(ssh-agent -s)"

while true; do
    # Prompt the user for input
    read -p "Do you want to copy the SSH key you've created to the clipboard? (y/n): " copy_ssh_key

    # Check the user's input
    case $copy_ssh_key in
        [yY])
            echo "Copying SSH key to clipboard..."
            # Check if XClip is installed or not
            if ! [ -x "$(command -v xclip)" ]; then
              echo "XClip is required to copy the SSH key to the clipboard."
              read -p "Do you want to install XClip? (y/n): " install_xclip
              if [ "$install_xclip" == "y" ]; then
                sudo apt-get install xclip
              else
                echo "Exit the script."
                exit 1
              fi
            fi

            # Copy the SSH key to the clipboard
            xclip -sel clip < ~/.ssh/"$file_name".pub
            echo "The SSH key has been copied to the clipboard."
            break # Exit the loop
            ;;
        [nN])
            echo "Exiting the script."
            exit 1
            ;;
        *)
            echo "Invalid input. Please enter 'y' or 'n'."
            ;;
    esac
done
