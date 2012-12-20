#!/bin/sh
# finish up the installation
echo "Running preflight script"
umask 022

echo "User is \"$USER\""

# delete any existing installation first

rm -rf $ROOT/XBoxHIDDriver