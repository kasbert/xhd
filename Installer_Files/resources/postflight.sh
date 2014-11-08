#!/bin/sh
# finish up the installation
echo "Running postflight script"
umask 022

echo "User is \"$USER\""

PKGROOT="$1/Contents/Resources"
ROOT="$2"

#CA_DEBUG_TRANSACTIONS=1

# note: use cp -R instead of mv -f to move
# items from /tmp as the user doing the installation

# mv only works if /tmp is owned by the user
# doing the installation

# delete any existing installation first

PROCESS=XboxHIDDaemon
number=$(ps aux | grep -i $PROCESS | grep -v grep | wc -l)
if [ $number -gt 0 ]
then
sudo killall $PROCESS
fi

sudo kextunload /System/Library/Extensions/DWXBoxHIDDriver.kext

# remove login item NOTE: use -g to uninstall globally must be "sudo"
echo "removing login item"
sudo "$ROOT/XBoxHIDDriver/installLoginItem" -remove -g /Library/PreferencePanes/XboxHIDPrefsPane.prefPane/Contents/Resources/XboxHIDDaemonLauncher.app
#sudo -u $USER "$ROOT/XBoxHIDDriver/installLoginItem" -remove /Library/PreferencePanes/XboxHIDPrefsPane.prefPane/Contents/Resources/XboxHIDDaemonLauncher.app

rm -rf ~/Library/PreferencePanes/XboxHIDPrefsPane.prefPane
rm -rf /Library/PreferencePanes/XboxHIDPrefsPane.prefPane
rm -rf /System/Library/Extensions/DWXboxHIDDriver.kext

echo "Moving prefs pane to /Library/PreferencePanes"
cp -R $ROOT/XBoxHIDDriver/XboxHIDPrefsPane.prefPane /Library/PreferencePanes/

echo "Moving daemon to /Library/PreferencePanes/XboxHIDPrefsPane.prefPane/Contents/Resources"
cp -R $ROOT/XBoxHIDDriver/XboxHIDDaemonLauncher.app /Library/PreferencePanes/XboxHIDPrefsPane.prefPane/Contents/Resources/


# Install login item NOTE: use -g to install globally must be "sudo" // use -h to install hidden
echo "Installing login item"
sudo "$ROOT/XBoxHIDDriver/installLoginItem" -install -g -h /Library/PreferencePanes/XboxHIDPrefsPane.prefPane/Contents/Resources/XboxHIDDaemonLauncher.app
#sudo -u $USER "$ROOT/XBoxHIDDriver/installLoginItem" -install -h /Library/PreferencePanes/XboxHIDPrefsPane.prefPane/Contents/Resources/XboxHIDDaemonLauncher.app


echo "Installing kernel extension"
cp -R $ROOT/XBoxHIDDriver/DWXboxHIDDriver.kext /System/Library/Extensions


echo "Fix Permissions"
chown -R root:wheel /System/Library/Extensions/DWXboxHIDDriver.kext
find /System/Library/Extensions/DWXboxHIDDriver.kext -type d -exec chmod 755 "{}" ";"
find /System/Library/Extensions/DWXboxHIDDriver.kext -type f -exec chmod 644 "{}" ";"

echo "Load kernel extension"
sudo kextload /System/Library/Extensions/DWXboxHIDDriver.kext

echo "Start prefs daemon"
sudo -u $USER open -g /Library/PreferencePanes/XboxHIDPrefsPane.prefPane/Contents/Resources/XboxHIDDaemonLauncher.app

echo "Relaunch System Preferences"
PROCESS="System Preferences"
number=$(ps aux | grep -i "$PROCESS" | grep -v grep | wc -l)
if [ $number -gt 0 ]
    then
        killall "$PROCESS" && open -g "/Applications/System Preferences.app"
fi

