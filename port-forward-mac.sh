#! /bin/bash

user=$SUDO_USER

if [ "$EUID" -ne 0 ]
    then echo "Script is being ran without sudo. Exiting..."
    exit 1
fi

if [ ! -f port-forward.tar.gz ]; then
    echo "port-forward.tar.gz is not found. Make sure you run this in the same directory as your tarball."
    exit 1
fi

echo "Checking for ~/.ssh/ folder..."
if [ ! -d ~/.ssh/ ]; then
  echo "~/.ssh/ does not exist. Creating..."
  mkdir ~/.ssh/
fi

echo "Extracting the tarball."
tar -xf port-forward.tar.gz
if [[ $? -ne 0 ]]; then 
    echo "Error extracting the tarball."
    exit 1
fi

cd port-forwarding-data/

if [ ! -f config ]; then
    echo "config was not found in the tarball. Please re-run the setup from your XDC and try again."
    exit 1
fi

if [ ! -f merge_key ]; then
    echo "merge_key was not found in the tarball. Please re-run the setup from your XDC and try again."
    exit 1
fi

echo "Checking for config file..."
if [ ! -e ~/.ssh/config ]; then
    echo "config does not exist. Moving current config file from tarball."
    touch ~/.ssh/config
    cat config >> $HOME/.ssh/config
    # mv config ~/.ssh/
else 
    echo "File exists."
    if grep -q "Host mergejump" "$HOME/.ssh/config"; then
        echo "Merge information was found. Ignoring..."
        rm -f config
    else
        echo "Merge information was not found. Appending the config file to the existing config file..."
        echo -e "" >> $HOME/.ssh/config
        cat config >> $HOME/.ssh/config
        rm -f config
    fi
fi 

echo "Moving merge_key into ~/.ssh..."
mv merge_key ~/.ssh/
cd ~/.ssh
chmod 600 merge_key
chown $user merge_key config

echo -e "\nTask completed. You may now delete this tarball."
echo "HINT: Before deleting the tarball, view the README.md file for instructions with how to access your XDC from terminal."
