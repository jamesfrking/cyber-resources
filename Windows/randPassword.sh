#!/bin/bash
# Reset the password for specified user accounts with randomized passwords

# Create an array to store usernames
usernames=()

# Continue looking for usernames until the user enters 'finito'
while true; do
    read -p "Enter a username or 'finito' to finish: " input

    # if the user wants to finish
    if [ "$input" == "finito" ]; then
        break
    else
        # if the entered username is in the username.txt file
        if grep -q "$input" specifiedaccounts.txt; then
            # entered username to the array
            usernames+=("$input")
        else
            echo "Username $input is not in the specifiedaccounts.txt file. Please enter a valid username."
        fi
    fi
done

# if at least one username was entered
if [ ${#usernames[@]} -eq 0 ]; then
    echo "No valid usernames were entered. Exiting."
    exit 1
fi

# the password  requirements
PASSWORD_MIN_LENGTH=11
PASSWORD_MAX_LENGTH=16
password_chars="A-Za-z0-9!@#$%^&*"

# Loop through the usernames entered  and reset the passwords
for username in "${usernames[@]}"; do
    if id "$username" &>/dev/null; then
        # work the rando passoword magic
        passwordLength=$(shuf -i $PASSWORD_MIN_LENGTH-$PASSWORD_MAX_LENGTH -n 1)

        # Generate a rando password (more magic)
        new_pass=$(cat /dev/urandom | tr -dc "$password_chars" | fold -w $passwordLength | head -n 1)

        #  generated password length and the new password
        echo "Setting a new password for user: $username"
        echo "Generated Password Length: $passwordLength"
        echo "Generated Password: $new_pass"

        # the new password for the user
        echo "$username:$new_pass" | chpasswd

        # let the user know  that the password has been successfully reset
        echo "Password for user $username has been successfully reset."
    else
        # User does not exist, display a message (If something goes terribly wrong)
        echo "User $username does not exist. Password reset failed."
    fi
done