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
#import "Registrar.h"

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

#pragma mark -- Registration Methods ----------------------

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

#define kRegKey @"org.walisser.DWXboxHIDDriver.RegKey"
#define kHashKey @"org.walisser.DWXBoxHIDDriver.Hash"
#define kPublicKey @"pubkey"
#define kBuyPage @"http://homepage.mac.com/walisser/xboxhiddriver/buy.html"
#define kRegistrationID @"org.walisser.XboxHIDDriver.Registration"

- (void)thanksDialogDidEnd:(NSWindow*)sheet returnCode:(int)returnCode 
    contextInfo:(void*)contextInfo
{
    [ _sheet close ];
}

- (void)doThanksDialog
{
    _sheet = _thanksWindow;
    [ NSApp beginSheet:_sheet 
        modalForWindow:[ NSApp mainWindow ]
        modalDelegate:self 
        didEndSelector:@selector(thanksDialogDidEnd:returnCode:contextInfo:)
        contextInfo:nil ];
}

- (void)invalidCodeDialogDidEnd:(NSWindow*)sheet returnCode:(int)returnCode 
    contextInfo:(void*)contextInfo
{
    [ _sheet close ];
    
    if (returnCode == 1) // try again
        [ self performSelector:@selector(doEnterRegistrationDialog) ];
    else
    if (returnCode == 0) // give up
        [ self performSelector:@selector(doDemoMessageDialog) ];
}

- (void)doInvalidCodeDialog
{
    _sheet = _invalidCodeWindow;
    [ NSApp beginSheet:_sheet 
        modalForWindow:[ NSApp mainWindow ]
        modalDelegate:self 
        didEndSelector:@selector(invalidCodeDialogDidEnd:returnCode:contextInfo:)
        contextInfo:nil ];
}

- (void)codeExpiredDialogDidEnd:(NSWindow*)sheet returnCode:(int)returnCode 
    contextInfo:(void*)contextInfo
{
    [ _sheet close ];
    if (returnCode == 1)
        [ self sendEmailTo:@"walisser@mac.com" withSubject:@"XBox HID Driver New Code Request"
            withMessageBody:@"Please supply the following information so your new code can be sent out as soon as possible:\n\nYour Name: \n\nExpired Code: \n\nQuestions/Comments?:" ];
    
    [ self performSelector:@selector(doDemoMessageDialog) ];
}

- (void)doCodeExpiredDialog
{
    _sheet = _codeExpiredWindow;
    [ NSApp beginSheet:_sheet 
        modalForWindow:[ NSApp mainWindow ]
        modalDelegate:self 
        didEndSelector:@selector(codeExpiredDialogDidEnd:returnCode:contextInfo:)
        contextInfo:nil ];
}

- (void)enterRegistrationDialogDidEnd:(NSWindow*)sheet returnCode:(int)returnCode 
    contextInfo:(void*)contextInfo
{
    [ _sheet close ];
    
    NSString *regString = [ _registrationCodeTextField stringValue ];
    NSString *outRegHash = nil;
    
    NSString *publicKeyFile = [ [ [ self bundle ] resourcePath ] 
        stringByAppendingFormat:@"/%@", kPublicKey, nil ];
    
    if (publicKeyFile && regString) {
    
        RegistrationError err;
        
        err = [ Registrar checkRegistration:regString 
            withPublicKeyFile:publicKeyFile inOutRegistrationHash:&outRegHash ];
        
        switch(err) {
        case kRegistrationNoError:
        {
            NSUserDefaults *userDefaults = [ NSUserDefaults standardUserDefaults ]; 
            NSMutableDictionary *defaults = [ NSMutableDictionary dictionary ];
            [ defaults setObject:regString forKey:kRegKey ];
            [ defaults setObject:outRegHash forKey:kHashKey ];
            [ userDefaults setPersistentDomain:defaults forName:kRegistrationID ];
            [ userDefaults synchronize ];
            // unlock UI
            _enable = YES;
            [ self willSelect ];
            [ self doThanksDialog ];
            break;
        }
        case kRegistrationErrorNoPublicKey:
        case kRegistrationCodeBadFormat:
        case kRegistrationInvalidCode:
            [ self doInvalidCodeDialog ];
            break;
        case kRegistrationCodeExpired:
            [ self doCodeExpiredDialog ];
            break;
        }
    }
}

- (void)doEnterRegistrationDialog
{
    _sheet = _enterCodeWindow;
    [ NSApp beginSheet:_sheet 
        modalForWindow:[ NSApp mainWindow ]
        modalDelegate:self 
        didEndSelector:@selector(enterRegistrationDialogDidEnd:returnCode:contextInfo:)
        contextInfo:nil ];
}

- (void)demoMessageDialogDidEnd:(NSWindow*)sheet returnCode:(int)returnCode 
    contextInfo:(void*)contextInfo
{
    [ _sheet close ];
    
    if (returnCode == 0) { // open URL
    
        NSURL *theURL = [ NSURL URLWithString:kBuyPage ];
        [ [ NSWorkspace sharedWorkspace ] openURL:theURL ];
    }
    else
    if (returnCode == 1) { // keep on truckin'
    
        return;
    }
    else
    if (returnCode == 2) { // enter code
    
        [ self doEnterRegistrationDialog ];
    }
    else { // die, die, die!
    
        exit(-1);
    }
}

- (void)doDemoMessageDialog
{    
    _sheet = _demoMessageWindow;
     [ NSApp beginSheet:_sheet 
        modalForWindow:[ NSApp mainWindow ]
        modalDelegate:self 
        didEndSelector:@selector(demoMessageDialogDidEnd:returnCode:contextInfo:)
        contextInfo:nil ];
}


// check demo/registration, return if they're not allowed to use the app
- (BOOL)checkDemoAndRegistration
{
    BOOL regError = YES;
    
    NSString *publicKeyFile = [ [ [ self bundle ] resourcePath ] 
        stringByAppendingFormat:@"/%@", kPublicKey, nil ];
    
    NSUserDefaults *userDefaults = [ NSUserDefaults standardUserDefaults ];
    [ userDefaults synchronize ];
    NSDictionary *defaults = [ userDefaults persistentDomainForName:kRegistrationID ];
    NSString *regString = [ defaults objectForKey:kRegKey ];
    NSString *regHash   = [ defaults objectForKey:kHashKey ];
    
    if (publicKeyFile && regString && regHash) {
    
        RegistrationError err;
        
        err = [ Registrar checkRegistration:regString 
            withPublicKeyFile:publicKeyFile inOutRegistrationHash:&regHash ];
        
        switch(err) {
        case kRegistrationNoError: 
            regError = NO; 
            break;
        default:    
            break;
        }
    }
    
    if (regError) {
    
        NSTimeInterval demoStamp = [ Registrar readSecretTimestamp:@"com.apple.Finder" ];
    
        NSTimeInterval now = [ [ NSDate date ] timeIntervalSince1970 ];
        
        if ((now - demoStamp) < (60*60*24*30))
            regError = NO;
        
        int daysLeft = 30 - ((now - demoStamp)/60/60/24);
        if (daysLeft < 0)
            daysLeft = 0;
    
        NSString *message;
        
            if (daysLeft > 0)
                message = [ NSString stringWithFormat:
                    @"You have %d more %@ to try this software. %@",
                    daysLeft,
                    daysLeft > 1 ? @"days" : @"day",
                    @"After that, you won't be able to change the controller settings.",
                    nil ];
            else
                message = @"Unfortunately, the 30-day demo has expired. The driver will continue to work but you won't be able to customize settings." ;
                
        NSMutableString *str = [ [ _demoMessageText stringValue ] mutableCopy ];
        NSRange range = [ str rangeOfString:@"$TIME_MESSAGE$" ];
        if (range.length > 0)
            [ str replaceCharactersInRange:range withString:message ];
        
        [ _demoMessageText setStringValue:str ];
        
        [ self doDemoMessageDialog ];
    }
    
    return regError;
}

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