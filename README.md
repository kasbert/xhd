xhd
===

**This driver is obsolete, use 360Controller instead**

Xbox HID Driver for Mac OS X

This code is from http://xhd.sourceforge.net/

Tiny modification added for 32-bit Snow Leopard.

Compile and install as root:
```
cd Installer_Files
mkdir files
ln -s files XBoxHIDDriver
cd ..
make pkg
./Installer_Files/resources/postflight.sh . Installer_Files
```
