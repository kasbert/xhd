//
//  DWXBoxHIDPrefsLoader.h
//  DWXBoxHIDDriver
//
//  Created by Darrell Walisser on Sun Jun 01 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWXBoxHIDDriverInterface.h"

#define kDWDistributedNotificationsObject @"org.walisser.DWXBoxHIDDriver"
#define kDWXBoxHIDDeviceConfigurationDidChangeNotification @"ConfigDidChange"

@interface DWXBoxHIDPrefsLoader : NSObject 
{
}

// create the default set of settings
+(BOOL)createDefaultsForDevice:(DWXBoxHIDDriverInterface*)device;

// list all the config names for a particular device type
+(NSArray*)configNamesForDeviceType:(NSString*)deviceType;

// get the config name of the specified device
+(NSString*)configNameForDevice:(DWXBoxHIDDriverInterface*)device;

// load the current config for the specified device
+(BOOL)loadSavedConfigForDevice:(DWXBoxHIDDriverInterface*)device;

// save the current config
+(BOOL)saveConfigForDevice:(DWXBoxHIDDriverInterface*)device;

// load named config for device
+(BOOL)loadConfigForDevice:(DWXBoxHIDDriverInterface*)device withName:(NSString*)configName;

// create a new config with specified settings, and make it the device's configuration
+(BOOL)createConfigForDevice:(DWXBoxHIDDriverInterface*)device withName:(NSString*)configName;

// delete the specified configuration
+(BOOL)deleteConfigWithName:(NSString*)configName;
@end
