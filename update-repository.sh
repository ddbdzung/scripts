#!/bin/bash

clear
# Function to print progress bar
print_progress_bar() {
    local width=50
    local percent=$1
    local cols=$(tput cols)
    local bar_width=$(( (cols * width) / 100 ))
    local progress=$(( (percent * bar_width) / 100 ))

    # Move cursor to top of terminal
    tput cup 0 0

    # Print progress bar
    printf "["
    for ((i=0; i<bar_width; i++)); do
        if [[ $i -lt $progress ]]; then
            printf "#"
        else
            printf " "
        fi
    done
    printf "] %d%%\n" $percent
}

# # Example usage
# for i in {1..100}; do
#     print_progress_bar $i
#     sleep 0.1
# done

# ========================================================================================================================
# TODO: Add the directories you want to exclude from the update
exclude_directories=("proxy" "scripting" "home" "report")

echo "What branch do you want to update?"
read branch

echo "Do you want to stand on the updated branch after updating? (y/n)"
read stand_on_branch

if [ "$stand_on_branch" == "y" ]; then
    stand_on_branch=true
else
    stand_on_branch=false
fi

_total_step=0

# Use a for loop to iterate over directories directly
for directory in */; do
    directory=${directory%/} # Remove the trailing slash
    if [[ ! " ${exclude_directories[@]} " =~ " $directory " ]]; then
        if [ -d "$directory/.git" ]; then
            echo "Checking $directory"
            _total_step=$((_total_step + 1))
        fi
    fi
done

sleep 1
echo "Total repo to update " $_total_step
sleep 1
clear

_current_step=$((100 / $_total_step))

for directory in */; do
    print_progress_bar $_current_step
    
    directory=${directory%/} # Remove the trailing slash
    if [[ ! " ${exclude_directories[@]} " =~ " $directory " ]]; then
        if [ -d "$directory/.git" ]; then
            _current_step=$((_current_step + (100 / $_total_step)))
            echo "Updating $directory"
            cd "$directory" || exit
            git fetch
            git stash push -um"Temp stash to update repository"
            git checkout $branch
            git pull
            if [ "$stand_on_branch" = false ]; then
                git checkout -
            fi
            git stash pop
            cd ..
            clear
        fi
    fi
done

print_progress_bar 100
printf '\nFinished!\n'
