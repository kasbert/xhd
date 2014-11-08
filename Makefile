
CONFIGURATION=Debug
SDK=macosx10.6

TARGET_DRIVER=Source/DWXBoxHIDDriver/build/$(CONFIGURATION)/DWXBoxHIDDriver.kext
TARGET_DAEMON=Source/DWXBoxHIDDaemon/build/Default/XboxHIDDaemon
TARGET_PREFSPANE=Source/DWXBoxHIDPrefsPane/build/$(CONFIGURATION)/XBoxHIDPrefsPane.prefPane

pkg: $(TARGET_DRIVER) $(TARGET_DAEMON) $(TARGET_PREFSPANE)
	cp -R $(TARGET_DRIVER) Installer_Files/files
	cp -R $(TARGET_DAEMON) Installer_Files/files
	cp -R $(TARGET_PREFSPANE) Installer_Files/files
	/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker --doc Installer_Files/XBoxHIDDriver.pmdoc --out xhd.pkg

$(TARGET_DRIVER):
	cd Source/DWXBoxHIDDriver; xcodebuild -configuration $(CONFIGURATION)

$(TARGET_DAEMON):
	cd DWXBoxHIDDaemon; xcodebuild -configuration $(CONFIGURATION)

$(TARGET_PREFSPANE):
	cd DWXBoxHIDPrefsPane; xcodebuild -configuration $(CONFIGURATION)

target_debug:
	cd Source/Registrar; xcodebuild
	cd Source/ForceFeedBackTest; xcodebuild
	cd Source/UserLandTest; xcodebuild

all: $(TARGET_DRIVER) $(TARGET_DAEMON) $(TARGET_PREFSPANE) target_debug

clean:
	rm -fr Source/*/build
	rm -f xhd.pkg
