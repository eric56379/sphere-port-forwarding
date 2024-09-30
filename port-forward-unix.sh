#!/usr/bin/env bash

USER_HOME=$HOME
CONFIG="../config"
KEY="../merge_key"

echo "Checking for $USER_HOME/.ssh/ folder..."
if [ ! -d "$USER_HOME/.ssh/" ]; then
  echo "$USER_HOME/.ssh/ does not exist. Creating..."
  mkdir $USER_HOME/.ssh/
fi

if [[ $? -ne 0 ]]; then 
    echo "An error occurred while unzipping."
    exit 1
fi

if [ ! -f $CONFIG ]; then
    echo "config was not found in the zip file. Please re-run the setup from your XDC and try again."
    exit 1
fi

if [ ! -f ../merge_key ]; then
    echo "merge_key was not found in the zip file. Please re-run the setup from your XDC and try again."
    exit 1
fi

echo "Checking for config file..."
if [ ! -f "$USER_HOME/.ssh/config" ]; then
    echo "config does not exist. Creating the config file."
    touch $USER_HOME/.ssh/config
    cat $CONFIG >> $USER_HOME/.ssh/config
else 
    echo "File exists."
    if grep -Fxq "Host mergejump" "$USER_HOME/.ssh/config"; then
        echo "Merge information was found. Ignoring..."
    else
        echo "Merge information was not found. Appending the config file to the existing config file..."
        echo -e "" >> $USER_HOME/.ssh/config
        cat $CONFIG >> $USER_HOME/.ssh/config
    fi
fi 

echo "Checking if known_hosts exists..."
if [ ! -f "$USER_HOME/.ssh/known_hosts" ]; then
    echo "known_hosts does not exist. Creating the known_hosts file."
    touch $USER_HOME/.ssh/known_hosts
    chmod 600 $USER_HOME/.ssh/known_hosts
    chown -v $USER $USER_HOME/.ssh/known_hosts > /dev/null
else 
    echo "known_hosts exists. Ignoring..."
fi 

echo "Moving merge_key into $USER_HOME/.ssh..."
mv $KEY $USER_HOME/.ssh/
pushd $USER_HOME/.ssh > /dev/null
chmod 600 merge_key
chown $USER merge_key config
popd > /dev/null

echo -e "\nTask completed. You may now delete this zip file."
echo "HINT: Before deleting the zip file, view the README.md file for instructions with how to access your XDC from terminal."
