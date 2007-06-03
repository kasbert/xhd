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
    along with the Xbox HID Driver; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
//
//  DWXBoxHIDPrefsPane.m
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Thu May 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "DWXBoxHIDPrefsPane.h"
#import "DWXBoxHIDDriverInterface.h"
#import "DWXBoxHIDPrefsLoader.h"
#import "DWHIDUtilities.h"
#import "DWTriggerView.h"
#import "DWAxisPairView.h"
#import "DWButtonView.h"
#import "DWDPadView.h"
//#import "Registrar.h"

#define kTriggerAxisIndex 0
#define kTriggerButtonIndex 1


@implementation DWXBoxHIDPrefsPane

#pragma mark -- Private Methods --------------------------

- (void)showLargeError:(NSString*)errorMessage
{
    [ _largeErrorMessage setStringValue:errorMessage ];
    [ _tabView selectTabViewItemAtIndex:1 ];
}

- (NSImage*)imageNamed:(NSString*)name
{
    NSString *imagePath;
    
    imagePath = [ [ self bundle ] resourcePath ];
    imagePath = [ imagePath stringByAppendingFormat:@"/%@.tiff", name, nil ];
    
    return [ [ [ NSImage alloc ] initWithContentsOfFile:imagePath ] autorelease ];
}


- (void)buildDevicesPopUpButton
{
    int i;
    int numControllers = 0;
    int numRemotes = 0;
    
    [ _devicePopUpButton setPullsDown:NO ];    
    [ _devicePopUpButton removeAllItems ];
    
    for (i = 0; i < [ _devices count ]; i++) {
    
        id obj;
        NSString *type;
        NSMenuItem *item;
        NSString *icon;
        NSString *name;
        int deviceNum;
        obj = [ _devices objectAtIndex:i ];
        type = [ obj deviceType ];
        
        if ([ type isEqualTo:NSSTR(kDeviceTypePadKey) ]) {
        
            numControllers++;
            deviceNum = numControllers;
            icon = @"controller64";
        }
        else if ([ type isEqualTo:NSSTR(kDeviceTypeIRKey) ]) {
        
            numRemotes++;
            deviceNum = numRemotes;
            icon = @"remote64";
        }
        else {
        
            deviceNum = 0;
            icon = @"";
        }
        
        name = [ NSString stringWithFormat:@"%@ %d", [ obj productName ], deviceNum ];
        [ _devicePopUpButton addItemWithTitle:name ];
        item = [ _devicePopUpButton itemAtIndex:i ];
        [ item setImage:[ self imageNamed:icon ] ];
    
        /* test
        [ _devicePopUpButton addItemWithTitle:@"Remote control" ];
        item = [ _devicePopUpButton itemAtIndex:i+1 ];
        [ item setImage:[ self imageNamed:@"remote64" ] ];
         */
    }
}

- (void)clearDevicesPopUpButton
{
    [ _devicePopUpButton removeAllItems ];
    [ _devicePopUpButton addItemWithTitle:@"No devices found" ];
}

- (void)buildConfigurationPopUpButton
{
    id intf = [ _devices objectAtIndex: [ _devicePopUpButton indexOfSelectedItem ] ];
    
    NSArray *configs = [ DWXBoxHIDPrefsLoader configNamesForDeviceType:[ intf deviceType ] ];
    configs = [ configs sortedArrayUsingSelector:@selector(compare:) ];
    
    [ _configPopUp removeAllItems ];
    NSEnumerator *configNames = [ configs objectEnumerator ];
    NSString *configName;
    while (configName = [ configNames nextObject ]) {
    
        [ _configPopUp addItemWithTitle:configName ];
    }

    NSString *currentConfigName = [ DWXBoxHIDPrefsLoader configNameForDevice:intf ];
    [ _configPopUp selectItemWithTitle:currentConfigName ];
}

- (void)disableSubviewsOfView:(NSView*)view
{
    NSArray *subviews = [ view subviews ];
    NSEnumerator *e;
    id subview;
    
    if (subviews == nil)
        return;
        
    e = [ subviews objectEnumerator ];
    
    while (subview = [ e nextObject ]) {
    
        if ( [ subview isKindOfClass:[ NSControl class ] ] )
            [ subview setEnabled:NO ];
        else
        if ( [ subview isKindOfClass:[ NSView class ] ] )
            [ self disableSubviewsOfView:subview ];
    }
}

- (void)enableSubviewsOfView:(NSView*)view
{
    NSArray *subviews = [ view subviews ];
    NSEnumerator *e;
    id subview;
    
    if (subviews == nil)
        return;
    
    e = [ subviews objectEnumerator ];
    
    while (subview = [ e nextObject ]) {
    
        if ( [ subview isKindOfClass:[ NSControl class ] ] )
            [ subview setEnabled:YES ];
        else
        if ( [ subview isKindOfClass:[ NSView class ] ] )
            [ self enableSubviewsOfView:subview ];
    }
}

- (void)enableConfigPopUpButton
{
    [ self enableSubviewsOfView:_configBox ];
}

- (void)disableConfigPopUpButton
{
    [ self disableSubviewsOfView:_configBox ];
}

- (void)createNewConfigDidEnd:(NSWindow*)sheet returnCode:(int)returnCode 
    contextInfo:(void*)contextInfo
{
    [ _sheet close ];
    if (returnCode) {
    
        NSString *name = [ _askForNameTextField stringValue ];
 
        id device = [ _devices objectAtIndex:[ _devicePopUpButton indexOfSelectedItem ] ];
    
        [ DWXBoxHIDPrefsLoader createConfigForDevice:device withName:name ];
        
        // rebuild configs popup
        [ self buildConfigurationPopUpButton ];
    }
}

- (void)createNewConfig
{
    _sheet = _askForNameWindow;
    [ NSApp beginSheet:_askForNameWindow 
        modalForWindow:[ [ self mainView ] window ]
        modalDelegate:self 
        didEndSelector:@selector(createNewConfigDidEnd:returnCode:contextInfo:)
        contextInfo:nil ];
}

- (void)deleteConfigDidEnd:(NSWindow*)sheet returnCode:(int)returnCode 
    contextInfo:(void*)contextInfo
{
    [ _sheet close ];
    if (returnCode) {
    
        NSString *deleteName = [ _askForItemToDeletePopUp titleOfSelectedItem ];
        [ DWXBoxHIDPrefsLoader deleteConfigWithName:deleteName ];
        
        
        // rebuild the config popup
        [ self buildConfigurationPopUpButton ];
        
        // load the selected config
        NSString *configName = [ _configPopUp titleOfSelectedItem ];
        id device = [ _devices objectAtIndex:[ _devicePopUpButton indexOfSelectedItem ]  ];
    
        // now load the new config
        [ DWXBoxHIDPrefsLoader loadConfigForDevice:device withName:configName ];
    }
}

- (void)deleteConfig
{
    id intf = [ _devices objectAtIndex: [ _devicePopUpButton indexOfSelectedItem ] ];
    NSArray *configs = [ DWXBoxHIDPrefsLoader configNamesForDeviceType:[ intf deviceType ] ];
    configs = [ configs sortedArrayUsingSelector:@selector(compare:) ];

    [ _askForItemToDeletePopUp removeAllItems ];
    
    NSEnumerator *configNames = [ configs objectEnumerator ];
    NSString *configName;
    while (configName = [ configNames nextObject ]) {
    
        [ _askForItemToDeletePopUp addItemWithTitle:configName ];
    }

    _sheet = _askForItemToDeleteWindow;
    [ NSApp beginSheet:_askForItemToDeleteWindow 
        modalForWindow:[ [ self mainView ] window ]
        modalDelegate:self 
        didEndSelector:@selector(deleteConfigDidEnd:returnCode:contextInfo:)
        contextInfo:nil ];
}

- (void)initPadOptionsWithDevice:(id)device
{
    int deadzone;
    
    if ([ device mapsLeftTriggerToButton ]) {
        [ _leftTriggerUsage selectItemAtIndex:kTriggerButtonIndex ];
        [ _leftTriggerView setMax:1 ];
    }
    else {
        [ _leftTriggerUsage selectItemAtIndex:kTriggerAxisIndex ];
        [ _leftTriggerView setMax:255 ];
    }
    
    deadzone = [ device leftTriggerThreshold ] * 98.0/255.0 + 1;
    [ _leftTriggerDeadzone setIntValue:deadzone ];
    [ _leftTriggerDeadzoneField setIntValue:deadzone ];
    
    if ([ device mapsRightTriggerToButton ]) {
        [ _rightTriggerUsage selectItemAtIndex:kTriggerButtonIndex ];
        [ _rightTriggerView setMax:1 ];
    }
    else {
        [ _rightTriggerUsage selectItemAtIndex:kTriggerAxisIndex ];
        [ _rightTriggerView setMax:255 ];
    }
    
    deadzone = [ device rightTriggerThreshold ] * 98.0/255.0 + 1;
    [ _rightTriggerDeadzone setIntValue:deadzone ];
    [ _rightTriggerDeadzoneField setIntValue:deadzone ];
        
    [ _leftStickInvertX setState:[ device invertsXAxis ] ];
    [ _leftStickInvertY setState:[ device invertsYAxis ] ];
    
    [ _rightStickInvertX setState:[ device invertsRxAxis ] ];
    [ _rightStickInvertY setState:[ device invertsRyAxis ] ];
    
    [ _enableAnalogButtons setState:![ device clampsButtonValues ] ];
    [ _buttonView setDrawsAnalogButtons:![ device clampsButtonValues ] ];
}

- (void)padOptionChanged:(id)device control:(id)control
{
    if (control == _leftTriggerUsage) {
    
        int index = [ _leftTriggerUsage indexOfSelectedItem ];
        if (kTriggerButtonIndex == index) {
        
            [ device setMapsLeftTriggerToButton:YES ];
            [ device setClampsLeftTriggerValues:YES ];
            [ _leftTriggerView setMax:1 ];
        }
        else
        if (kTriggerAxisIndex == index) {
        
            [ device setMapsLeftTriggerToButton:NO ];
            [ device setClampsLeftTriggerValues:NO ];
            [ _leftTriggerView setMax:255 ];
        }
    }
    else
    if (control == _rightTriggerUsage) {
    
        int index = [ _rightTriggerUsage indexOfSelectedItem ];
        if (kTriggerButtonIndex == index) {
        
            [ device setMapsRightTriggerToButton:YES ];
            [ device setClampsRightTriggerValues:YES ];
            [ _rightTriggerView setMax:1 ];
        }
        else
        if (kTriggerAxisIndex == index) {
        
            [ device setMapsRightTriggerToButton:NO ];
            [ device setClampsRightTriggerValues:NO ];
            [ _rightTriggerView setMax:255 ];
        }
    }
    else
    if (control == _leftTriggerDeadzoneField) {
    
        UInt8 threshold = [ _leftTriggerDeadzoneField intValue ] * 255.0/99.0;
        [ device setLeftTriggerThreshold:threshold ];
    }
    else
    if (control == _rightTriggerDeadzoneField) {
    
        UInt8 threshold = [ _rightTriggerDeadzoneField intValue ] * 255.0/99.0;
        [ device setRightTriggerThreshold:threshold ];
    }
    else
    if (control == _leftStickInvertX) {
    
        [ device setInvertsXAxis:[ _leftStickInvertX state ] ];
    }
    else
    if (control == _leftStickInvertY) {
    
        [ device setInvertsYAxis:[ _leftStickInvertY state ] ];
    }
    else
    if (control == _rightStickInvertX) {
    
        [ device setInvertsRxAxis:[ _rightStickInvertX state ] ];
    }
    else
    if (control == _rightStickInvertY) {
    
        [ device setInvertsRyAxis:[ _rightStickInvertY state ] ];
    }
    else
    if (control == _enableAnalogButtons) {
    
        [ device setClampsButtonValues:![ _enableAnalogButtons state ] ];
        [ _buttonView setDrawsAnalogButtons:[ _enableAnalogButtons state ] ];
    }
}

- (void)initOptionsInterface
{
    int deviceIndex;
    id  device;
    BOOL error = YES;
    
    deviceIndex = [ _devicePopUpButton indexOfSelectedItem ];
    if (deviceIndex >= 0 && deviceIndex < [ _devices count ]) {
    
        device = [ _devices objectAtIndex:deviceIndex ];
        if (device && [ device hasOptions ]) {
        
            if ([ [ device deviceType ] isEqualTo:NSSTR(kDeviceTypePadKey) ]) {
            
                [ _tabView selectTabViewItemAtIndex:0 ];
                [ self initPadOptionsWithDevice:device ];
                error = NO;
            }
        }
    }
    
    if (error) {
    
        [ self showLargeError:@"Selected device has no configurable options." ];
        [ self disableSubviewsOfView:_configBox ];
    }
}


- (void)configureInterface
{
    if (_devices)
        [ _devices release ];
        
    _devices = [ DWXBoxHIDDriverInterface interfaces ];
    if (_devices) {
    
        [ _devices retain ];
        [ self buildDevicesPopUpButton ];
        [ self enableConfigPopUpButton ];
        [ self buildConfigurationPopUpButton ];
        [ self initOptionsInterface ];
    }
    else {
    
        [ self showLargeError:@"No Xbox devices found." ];
        [ self disableConfigPopUpButton ];
        [ self clearDevicesPopUpButton ];
    }
}


- (void)hidDeviceInputPoller:(id)object
{
    DWHID_JoystickUpdate(self);
}

- (void)hidUpdateElement:(int)deviceIndex cookie:(int)cookie value:(SInt32)value
{
    //NSLog(@"Update element: %d %d %d", deviceIndex, cookie, value);
    
    if (deviceIndex == [ _devicePopUpButton indexOfSelectedItem ] &&
        [ [ [ _devices objectAtIndex:deviceIndex ] deviceType ] 
            isEqualTo:NSSTR(kDeviceTypePadKey) ]) {
    
        switch (cookie) {
        case 6:
            [ _dPadView setValue:value forDirection:0 ]; break;
        case 7:
            [ _dPadView setValue:value forDirection:1 ]; break;
        case 8:
            [ _dPadView setValue:value forDirection:2 ]; break;
        case 9:
            [ _dPadView setValue:value forDirection:3 ]; break;
        case 10:
            [ _buttonView setValue:value forButton:7 ]; break;
        case 11:
            [ _buttonView setValue:value forButton:6 ]; break;
        case 12:
            [ _leftStickView setPressed:value ]; break;
        case 13:
            [ _rightStickView setPressed:value ]; break;
        case 14:
            [ _buttonView setValue:value forButton:0 ]; break;
        case 15:
            [ _buttonView setValue:value forButton:1 ]; break;
        case 16:
            [ _buttonView setValue:value forButton:2 ]; break;
        case 17:
            [ _buttonView setValue:value forButton:3 ]; break;
        case 18:
            [ _buttonView setValue:value forButton:4 ]; break;
        case 19:
            [ _buttonView setValue:value forButton:5 ]; break;
        case 20:
            [ _leftTriggerView setValue:value ]; break;
        case 21:            
            [ _rightTriggerView setValue:value ]; break;
        case 22:
            [ _leftStickView setX:value ]; break;
        case 23:
            [ _leftStickView setY:value ]; break;
        case 24:
            [ _rightStickView setX:value ]; break;
        case 25:
            [ _rightStickView setY:value ]; break;
        default:
            ;
        }
    }
}

- (void)startHIDDeviceInput
{
    DWHID_JoystickInit();
    _timer = [ NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(hidDeviceInputPoller:) userInfo:nil repeats:YES ];
}

- (void)stopHIDDeviceInput
{
    [ _timer invalidate ];
    DWHID_JoystickQuit();
}

- (void)devicesPluggedOrUnplugged
{
    //NSLog(@"device plugged or unplugged");
    
    // should save anything we need to before reconfiguring,
    // but by now it's too late!
    
    [ self configureInterface ];
    [ self stopHIDDeviceInput ];
    [ self startHIDDeviceInput ];
}

- (void)deviceConfigDidChange:(id)anObject
{
    // NSLog(@"device config changed");
    
    [ self buildConfigurationPopUpButton ];
    [ self configureInterface ];
}

- (void)registerForNotifications
{
    _notifier = [ DWXBoxHIDNotifier notifier ];
    if (_notifier) {
    
        [ _notifier retain ];
        [ _notifier setMatchedSelector:@selector(devicesPluggedOrUnplugged) target:self ];
        [ _notifier setTerminatedSelector:@selector(devicesPluggedOrUnplugged) target:self ];
    }
    
    // get notified when config changes out from under us (or when we change it ourselves)
    [ [ NSDistributedNotificationCenter defaultCenter ]
        addObserver:self
        selector:@selector(deviceConfigDidChange:)
        name:kDWXBoxHIDDeviceConfigurationDidChangeNotification
        object:kDWDistributedNotificationsObject ];
}

- (void)deregisterForNotifications
{
    if (_notifier) {
        [ _notifier release ];
        _notifier = nil;
    }
    
    [ [ NSDistributedNotificationCenter defaultCenter ]
        removeObserver:self
        name:kDWXBoxHIDDeviceConfigurationDidChangeNotification
        object:kDWDistributedNotificationsObject ];    
}

/*
- (void)betaExpiredDidEnd:(NSWindow*)sheet returnCode:(int)returnCode 
    contextInfo:(void*)contextInfo
{
    if (returnCode) {
    
        [ [ NSWorkspace sharedWorkspace ] 
            openURL:[ NSURL URLWithString:@"http://homepage.mac.com/walisser/xboxhiddriver" ] ];
    }
}

- (BOOL)checkBetaExpired
{
    BOOL expired = YES;
    
    
    #if 0
        NSDate *date = [ NSDate date ];
        NSTimeInterval interval;
    
        interval = [ date timeIntervalSince1970 ];
        interval += 60*60*24*30; // add 30 days;
    
        NSLog(@"%f", interval);
    #endif
    
    NSTimeInterval expireInterval = 1058402634.426905;
    NSDate *now = [ NSDate date ];
    NSDate *then = [ NSDate dateWithTimeIntervalSince1970:expireInterval ];
    
    if ([ then compare:now ] < 0)
        expired = YES;
    else 
        expired = NO;
    
        
    if (expired) {
    
        _sheet = _betaExpiredWindow;
        [ NSApp beginSheet:_betaExpiredWindow 
            modalForWindow:[ NSApp mainWindow ]
            modalDelegate:self 
            didEndSelector:@selector(betaExpiredDidEnd:returnCode:contextInfo:)
            contextInfo:nil ];
    }
    
    return expired;
}
*/


- (void)patchIntroDialogDidEnd:(NSWindow*)sheet returnCode:(int)returnCode 
    contextInfo:(void*)contextInfo
{
	[ _sheet close ];
	if (returnCode)
	{
		if (0 < [ self scanForDevices ])
		{
			_sheet = _patcherUIWindow;
			[ NSApp beginSheet:_sheet 
				modalForWindow:[ NSApp mainWindow ]
				modalDelegate:self 
				didEndSelector:@selector(patchUIDialogDidEnd:returnCode:contextInfo:)
				contextInfo:nil ];
		}
		else
		{
			_sheet = _patcherNoDevicesWindow;
			[ NSApp beginSheet:_sheet 
				modalForWindow:[ NSApp mainWindow ]
				modalDelegate:self 
				didEndSelector:@selector(patchUIDialogDidEnd:returnCode:contextInfo:)
				contextInfo:nil ];
		}
	
	}
}

- (void)patchUIDialogDidEnd:(NSWindow*)sheet returnCode:(int)returnCode 
    contextInfo:(void*)contextInfo
{
	[ _sheet close ];

}

- (int)scanForDevices
{
	int numDevices = 0;


	return numDevices;
}

- (void)getVersion
{
	NSBundle* b = [ NSBundle bundleWithIdentifier:@"org.walisser.XBoxHIDDriver" ];
	
	NSString* version = [ [ b infoDictionary ] objectForKey:@"CFBundleShortVersionString" ];
	
	[ _versionText setStringValue:version ];
}

#pragma mark -- Registration Methods ----------------------

// registration stuff has been removed, I kept some interesting bits
//

// a hacked-up URI-escape routine
- (NSString*)URIEscape:(NSString*)src
{
    NSMutableString *str = [ src mutableCopy ];
    
    #define numEscapies 5
    const char* escapies[numEscapies] = {" ", "\n", "\t", ":", "\""}; // there are more, but I don't need them yet (RFC 2396)
    
    int i;
    for (i = 0; i < numEscapies; i++) {
    
        while (1) {
        
            NSRange range = [ str rangeOfString:[ NSString stringWithCString:escapies[i]] ];
            if (range.length != 0) {
            
                [ str replaceCharactersInRange:range withString: 
                    [ NSString stringWithFormat:@"%%%.2X", escapies[i][0], nil ] ];
            }
            else {
            
                break;
            }
        }
    }
    
    #undef numEscapies
    
    return str;
}

- (void)sendEmailTo:(NSString*)recipient withSubject:(NSString*)subject
    withMessageBody:(NSString*)messageBody
{
    NSString *urlstr;
    NSURL *url;
        
   urlstr =  [ NSString stringWithFormat:
                @"mailto:%@?subject=%@&body=%@",
                recipient,
                [ self URIEscape:subject ], 
                [ self URIEscape:messageBody ], nil ];
    
    url = [ NSURL URLWithString:urlstr ];
     
    [ [ NSWorkspace sharedWorkspace ] openURL:url ];
}

/* registration stuff removed */

#pragma mark -- NSPreferencesPane Methods ----------------

/*
- (id)initWithBundle:(NSBundle *)bundle
{
    if ( ( self = [super initWithBundle:bundle] ) != nil )
    {
        // add subclass-specific initialization here
    }
    return self;
}
*/
- (void)mainViewDidLoad
{
 /* disable registration stuff
 
	   if ([ self checkDemoAndRegistration ]) {
        
        [ self showLargeError:@"Demo has expired." ];
        [ self disableConfigPopUpButton ];
        [ self clearDevicesPopUpButton ];
    
        _enable = NO;
    }
    else
    {
        _enable = YES;
    }
*/
	_enable = YES;

}

- (void)dealloc
{
    [ _devices autorelease ];
}

- (void)willSelect
{
    if (_enable) {
        [ self configureInterface ];
        [ self registerForNotifications ];
        [ self startHIDDeviceInput ];
		[ self getVersion ];
    }
}

- (void)willUnselect
{
    if (_devices) {
        [ _devices release ];
        _devices = nil;
    }
    
    [ self deregisterForNotifications ];
    [ self stopHIDDeviceInput ];
}

#pragma mark -- Actions ----------------------------------

- (IBAction)selectDevice:(id)sender
{
    [ self enableConfigPopUpButton ];
    [ self buildConfigurationPopUpButton ];
    [ self initOptionsInterface ];
}

- (IBAction)loadConfiguration:(id)sender
{
    NSString *configName = [ _configPopUp titleOfSelectedItem ];
    id device = [ _devices objectAtIndex:[ _devicePopUpButton indexOfSelectedItem ]  ];
    
    // first save the current config
    [ DWXBoxHIDPrefsLoader saveConfigForDevice:device ];
    
    // now load the new config
    [ DWXBoxHIDPrefsLoader loadConfigForDevice:device withName:configName ];
    
    // update the gui
    // note: handled in deviceConfigDidChange:
}

- (IBAction)newConfiguration:(id)sender
{
    [ self createNewConfig ];
}

- (IBAction)deleteConfiguration:(id)sender
{
    [ self deleteConfig ];
}

- (IBAction)changePadOption:(id)sender
{
    // if (sender == _leftTriggerUsage) ...
    int deviceIndex = [ _devicePopUpButton indexOfSelectedItem ];
    id device = [ _devices objectAtIndex:deviceIndex ];
    if ([ [ device deviceType ] isEqualTo:NSSTR(kDeviceTypePadKey) ]) {
    
        //NSLog(@"change pad option: %@", sender);
        [ self padOptionChanged:device control:sender ];
    }
    
    // save the current config
    [ DWXBoxHIDPrefsLoader saveConfigForDevice:device ];
}

- (IBAction)locateDevices:(id)sender
{
	_sheet = _patcherIntroWindow;
	[ NSApp beginSheet:_sheet 
        modalForWindow:[ NSApp mainWindow ]
        modalDelegate:self 
        didEndSelector:@selector(patchIntroDialogDidEnd:returnCode:contextInfo:)
        contextInfo:nil ];
}


- (IBAction)endModalSessionOK:(id)sender
{
    [ NSApp endSheet:_sheet returnCode:1 ];
}

- (IBAction)endModalSessionCancel:(id)sender
{
    [ NSApp endSheet:_sheet returnCode:0 ];
}

- (IBAction)endModalSessionAlt:(id)sender
{
    [ NSApp endSheet:_sheet returnCode:2 ];
}

@end