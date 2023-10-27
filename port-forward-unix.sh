#!/usr/bin/env bash

user=$SUDO_USER

if [ "$EUID" -ne 0 ]
    then echo "Script is being ran without sudo. Exiting..."
    exit 1
fi

if [ ! -f "port-forward.tar.gz" ]; then
    echo "port-forward.tar.gz is not found. Make sure you run this in the same directory as your tarball."
    exit 1
fi

echo "Checking for $HOME/.ssh/ folder..."
if [ ! -d "$HOME/.ssh/" ]; then
  echo "$HOME/.ssh/ does not exist. Creating..."
  mkdir $HOME/.ssh/
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
if [ ! -f "$HOME/.ssh/config" ]; then
    echo "config does not exist. Creating the config file."
    touch $HOME/.ssh/config
    cat config >> $HOME/.ssh/config
    # mv config $HOME/.ssh/
else 
    echo "File exists."
    if grep -Fxq "Host mergejump" "$HOME/.ssh/config"; then
        echo "Merge information was found. Ignoring..."
    else
        echo "Merge information was not found. Appending the config file to the existing config file..."
        echo -e "" >> $HOME/.ssh/config
        cat config >> $HOME/.ssh/config
    fi
fi 

echo "Checking if known_hosts exists..."
if [ ! -f "$HOME/.ssh/known_hosts" ]; then
    echo "known_hosts does not exist. Creating the known_hosts file."
    touch $HOME/.ssh/known_hosts
    chmod 600 $HOME/.ssh/known_hosts
    chown -v $user $HOME/.ssh/known_hosts
else 
    echo "known_hosts exists. Ignoring..."
fi 

echo "Moving merge_key into $HOME/.ssh..."
mv merge_key $HOME/.ssh/
pushd $HOME/.ssh > /dev/null
chmod 600 merge_key
chown $user merge_key config
popd > /dev/null

# Clean up:
cd ..
rm -rf port-forwarding-data/

echo -e "\nTask completed. You may now delete this tarball."
echo "HINT: Before deleting the tarball, view the README.md file for instructions with how to access your XDC from terminal."
