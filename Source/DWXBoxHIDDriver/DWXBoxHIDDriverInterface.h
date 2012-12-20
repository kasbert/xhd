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
//  DWXBoxHIDDriverInterface.h
//  DWXBoxHIDDriver
//
//  Created by Darrell Walisser on Thu May 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//
//  v2.0.0 Modified 12/18/2012 to support Standard 32/64-bit architecture. Compiled with Mac OS X 10.6 SDK.
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
// returns array of DWXBoxHIDDriverInterface objects
+ (NSArray*)interfaces;

+ (DWXBoxHIDDriverInterface*)interfaceWithDriver:(io_object_t)driver;
- initWithDriver:(io_object_t)driver;

- (io_object_t)driver;			// associated instance of the driver
- (NSString*)deviceType;
- (NSString*)productName;
- (NSString*)manufacturerName;
- (NSString*)identifier;

// true if the device type has options (currently only the pad has options)
- (BOOL)hasOptions;

// load a dictionary of options (say a saved configuration) into the ioregistry
- (BOOL)loadOptions:(NSDictionary*)options;

// fetch the current device options from the ioregistry
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
