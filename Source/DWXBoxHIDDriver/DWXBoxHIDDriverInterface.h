//
//  DWXBoxHIDDriverInterface.h
//  DWXBoxHIDDriver
//
//  Created by Darrell Walisser on Thu May 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <IOKit/IOKitLib.h>
#import <libkern/OSTypes.h>
#import <Cocoa/Cocoa.h>
#import "DWXBoxHIDDriverKeys.h"


// misc utility crap

// ObjC and C foundation objects are interchangeable...
#define NSSTR(x) ((NSString*)CFSTR(x))


static inline id BOOLtoID(BOOL value)
{
    if (value)
        return (id)kCFBooleanTrue;
    else
        return (id)kCFBooleanFalse;
}


extern BOOL idToBOOL(id obj);
extern id NSNUM(SInt32 num);


@interface DWXBoxHIDDriverInterface : NSObject 
{
    io_object_t   _driver;
    NSDictionary *_ioRegistryProperties;
    NSString     *_deviceType;
    NSDictionary *_deviceOptions;
}

// utility method: get all connected xbox devices
// returns array of DWXBoxHIDDriverControl objects
+ (NSArray*)interfaces;

+ (DWXBoxHIDDriverInterface*)interfaceWithDriver:(io_object_t)driver;
- initWithDriver:(io_object_t)driver;

- (io_object_t)driver;
- (NSString*)deviceType;
- (NSString*)productName;
- (NSString*)manufacturerName;
- (NSString*)identifier;

- (BOOL)hasOptions;
- (BOOL)loadOptions:(NSDictionary*)options;
- (NSDictionary*)deviceOptions;

// pad options
- (BOOL)invertsYAxis;
- (void)setInvertsYAxis:(BOOL)inverts;

- (BOOL)invertsXAxis;
- (void)setInvertsXAxis:(BOOL)inverts;

- (BOOL)invertsRyAxis;
- (void)setInvertsRyAxis:(BOOL)inverts;

- (BOOL)invertsRxAxis;
- (void)setInvertsRxAxis:(BOOL)inverts;

- (BOOL)clampsButtonValues;
- (void)setClampsButtonValues:(BOOL)clamps;

/*
- (BOOL)clampsTriggerValues;
- (void)setClampsTriggerValues:(BOOL)clamps;

- (BOOL)mapsTriggersToButtons;
- (void)setMapsTriggersToButtons:(BOOL)maps;

- (UInt8)triggerButtonThreshold;
- (void)setTriggerButtonThreshold:(UInt8)threshold;
*/

- (BOOL)clampsLeftTriggerValues;
- (void)setClampsLeftTriggerValues:(BOOL)clamps;

- (BOOL)mapsLeftTriggerToButton;
- (void)setMapsLeftTriggerToButton:(BOOL)maps;

- (UInt8)leftTriggerThreshold;
- (void)setLeftTriggerThreshold:(UInt8)threshold;

- (BOOL)clampsRightTriggerValues;
- (void)setClampsRightTriggerValues:(BOOL)clamps;

- (BOOL)mapsRightTriggerToButton;
- (void)setMapsRightTriggerToButton:(BOOL)maps;

- (UInt8)rightTriggerThreshold;
- (void)setRightTriggerThreshold:(UInt8)threshold;

// remote options

@end
