#!/usr/bin/env bash

USER_HOME=$HOME

if [ ! -f "port-forward.tar.gz" ]; then
    echo "port-forward.tar.gz is not found. Make sure you run this in the same directory as your tarball."
    exit 1
fi

echo "Checking for $USER_HOME/.ssh/ folder..."
if [ ! -d "$USER_HOME/.ssh/" ]; then
  echo "$USER_HOME/.ssh/ does not exist. Creating..."
  mkdir $USER_HOME/.ssh/
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
if [ ! -f "$USER_HOME/.ssh/config" ]; then
    echo "config does not exist. Creating the config file."
    touch $USER_HOME/.ssh/config
    cat config >> $USER_HOME/.ssh/config
    # mv config $USER_HOME/.ssh/
else 
    echo "File exists."
    if grep -Fxq "Host mergejump" "$USER_HOME/.ssh/config"; then
        echo "Merge information was found. Ignoring..."
    else
        echo "Merge information was not found. Appending the config file to the existing config file..."
        echo -e "" >> $USER_HOME/.ssh/config
        cat config >> $USER_HOME/.ssh/config
    fi
fi 

echo "Checking if known_hosts exists..."
if [ ! -f "$USER_HOME/.ssh/known_hosts" ]; then
    echo "known_hosts does not exist. Creating the known_hosts file."
    touch $USER_HOME/.ssh/known_hosts
    chmod 600 $USER_HOME/.ssh/known_hosts
    chown -v $USER $USER_HOME/.ssh/known_hosts
else 
    echo "known_hosts exists. Ignoring..."
fi 

echo "Moving merge_key into $USER_HOME/.ssh..."
mv merge_key $USER_HOME/.ssh/
pushd $USER_HOME/.ssh > /dev/null
chmod 600 merge_key
chown $USER merge_key config
popd > /dev/null

# Clean up:
cd ..
rm -rf port-forwarding-data/

echo -e "\nTask completed. You may now delete this tarball."
echo "HINT: Before deleting the tarball, view the README.md file for instructions with how to access your XDC from terminal."
