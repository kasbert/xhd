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

@end
