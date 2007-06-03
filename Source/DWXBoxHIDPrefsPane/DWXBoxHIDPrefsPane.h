/*
    This file is part of the Xbox HID Driver, Copyright (c) 2007 Darrell Walisser
    walisser@mac.com http://sourceforge.net/projects/xhd

    The Xbox HID Driver is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    The Xbox HID Driver is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Xbox HID Driver; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
//
//  DWXBoxHIDPrefsPane.h
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Thu May 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>
#import "DWXBoxHIDNotifier.h"

@interface DWXBoxHIDPrefsPane : NSPreferencePane
{
    IBOutlet id _devicePopUpButton;
    IBOutlet id _tabView;
    
    // error tab
    IBOutlet id _largeErrorMessage;
    
    // pad tab
    IBOutlet id _leftTriggerView;
    IBOutlet id _leftTriggerUsage;
    IBOutlet id _leftTriggerDeadzone;
    IBOutlet id _leftTriggerDeadzoneField;
    
    IBOutlet id _rightTriggerView;
    IBOutlet id _rightTriggerUsage;
    IBOutlet id _rightTriggerDeadzone;
    IBOutlet id _rightTriggerDeadzoneField;
    
    IBOutlet id _leftStickView;
    IBOutlet id _leftStickInvertX;
    IBOutlet id _leftStickInvertY;
    
    IBOutlet id _rightStickView;
    IBOutlet id _rightStickInvertX;
    IBOutlet id _rightStickInvertY;
    
    IBOutlet id _buttonView;
    IBOutlet id _enableAnalogButtons;

    IBOutlet id _dPadView;

    IBOutlet id _configPopUp;
    IBOutlet id _configBox;
        
    // dialogs
    IBOutlet id _askForNameWindow;
    IBOutlet id _askForNameTextField;
    
    IBOutlet id _askForItemToDeleteWindow;
    IBOutlet id _askForItemToDeletePopUp;
    
    // beta expire
    IBOutlet id _betaExpiredWindow;
    
    // registration
    IBOutlet id _demoMessageWindow;
    IBOutlet id _enterCodeWindow;
    IBOutlet id _codeExpiredWindow;
    IBOutlet id _invalidCodeWindow;
    IBOutlet id _thanksWindow;
    IBOutlet id _registrationCodeTextField;
    IBOutlet id _demoMessageText;
    
	// device helper
	IBOutlet id _patcherIntroWindow;
	IBOutlet id _patcherUIWindow;
	IBOutlet id _patcherNoDevicesWindow;
	IBOutlet id _deviceTableView;
	IBOutlet id _deviceTypeComboBox;
	IBOutlet id _deviceVendorText;
	IBOutlet id _deviceProductText;
	
	// version string
	IBOutlet id _versionText;
	
    NSArray *_devices;
    DWXBoxHIDNotifier *_notifier;
    NSTimer *_timer;
    NSWindow *_sheet;
    BOOL _enable;
}

- (IBAction)selectDevice:(id)sender;

- (IBAction)loadConfiguration:(id)sender;
- (IBAction)newConfiguration:(id)sender;
- (IBAction)deleteConfiguration:(id)sender;


- (IBAction)changePadOption:(id)sender;

- (IBAction)endModalSessionOK:(id)sender;
- (IBAction)endModalSessionCancel:(id)sender;
- (IBAction)endModalSessionAlt:(id)sender;

- (IBAction)locateDevices:(id)sender;
- (IBAction)pickDevice:(id)sender;

@end
