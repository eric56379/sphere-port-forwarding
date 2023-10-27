#!/usr/bin/env bash

user=$SUDO_USER
home=/home/$user

if [ "$EUID" -ne 0 ]
    then echo "Script is being ran without sudo. Exiting..."
    exit 1
fi

if [ ! -f "port-forward.tar.gz" ]; then
    echo "port-forward.tar.gz is not found. Make sure you run this in the same directory as your tarball."
    exit 1
fi

echo "Checking for $home/.ssh/ folder..."
if [ ! -d "$home/.ssh/" ]; then
  echo "$home/.ssh/ does not exist. Creating..."
  mkdir $home/.ssh/
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
if [ ! -f "$home/.ssh/config" ]; then
    echo "config does not exist. Creating the config file."
    touch $home/.ssh/config
    cat config >> $home/.ssh/config
    # mv config $home/.ssh/
else 
    echo "File exists."
    if grep -Fxq "Host mergejump" "$home/.ssh/config"; then
        echo "Merge information was found. Ignoring..."
    else
        echo "Merge information was not found. Appending the config file to the existing config file..."
        echo -e "" >> $home/.ssh/config
        cat config >> $home/.ssh/config
    fi
fi 

echo "Checking if known_hosts exists..."
if [ ! -f "$home/.ssh/known_hosts" ]; then
    echo "known_hosts does not exist. Creating the known_hosts file."
    touch $home/.ssh/known_hosts
    chmod 600 $home/.ssh/known_hosts
    chown -v $user $home/.ssh/known_hosts
else 
    echo "known_hosts exists. Ignoring..."
fi 

echo "Moving merge_key into $home/.ssh..."
mv merge_key $home/.ssh/
pushd $home/.ssh > /dev/null
chmod 600 merge_key
chown $user merge_key config
popd > /dev/null

# Clean up:
cd ..
rm -rf port-forwarding-data/

echo -e "\nTask completed. You may now delete this tarball."
echo "HINT: Before deleting the tarball, view the README.md file for instructions with how to access your XDC from terminal."
