#!/bin/bash

#################################
# Author:       Matej Ciglenečki
# Description:  Script that sets up a new user on the system.

# Script should be run as root.
# Script should be idempotent. Running it multiple times should not have any side effects.
# Script should be run with the username of the new user as the first argument.

# Usage example:
# sudo ./create_user.sh newuser
#################################


# Check if script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root."
  exit
fi

if [ "$#" -ne 2 ]; then
    echo "Error: username of the new user is the first argument and ssh-key second last argument."
fi

# # Check if usernals



exit 1

NEWUSER=$1
COMPANY_GROUP_NAME="tensorpix"
COMPANY_GROUP_GID=$(getent group $COMPANY_GROUP_NAME | cut -d: -f3)



# Create company group if it doesn't exist
if ! getent group "$COMPANY_GROUP_NAME" >/dev/null; then
    echo "Creating group $COMPANY_GROUP_NAME (GID $COMPANY_GROUP_GID)"
    groupadd -g $COMPANY_GROUP_GID $COMPANY_GROUP_NAME
fi

# Create user group if it doesn't exist
if ! getent group "$NEWUSER" >/dev/null; then
    echo "Creating group $NEWUSER"
    groupadd $NEWUSER
fi


# Create user if it doesn't exist
if id "$NEWUSER" >/dev/null 2>&1; then
    echo "User $NEWUSER already exists"
else
    echo "Creating user $NEWUSER"
    adduser --disabled-password --gid $COMPANY_GROUP_GID --shell /bin/bash --gecos ""  $NEWUSER
fi


# Add user groups
usermod -aG $NEWUSER $NEWUSER
usermod -aG $COMPANY_GROUP_NAME $NEWUSER
usermod -aG docker $NEWUSER


# Setup ssh directory
HOME_DIR="/home/$NEWUSER"
mkdir -p $HOME_DIR/.ssh
touch $HOME_DIR/.ssh/authorized_keys
chown -R $NEWUSER:$NEWUSER $HOME_DIR
chmod 700 $HOME_DIR
chmod 700 $HOME_DIR/.ssh
chmod 600 $HOME_DIR/.ssh/authorized_keys
echo -e $2 >> $HOME_DIR/.ssh/authorized_keys

echo "Call to action: tell $NEWUSER to change their password with 'passwd' command"
