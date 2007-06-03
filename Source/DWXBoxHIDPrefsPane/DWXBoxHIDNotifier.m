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
//  DWXBoxHIDNotifier.m
//  DWXBoxHIDDriver
//
//  Created by Darrell Walisser on Wed Jun 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "DWXBoxHIDNotifier.h"


@implementation DWXBoxHIDNotifier


- (void)fireMatchedSelector
{
    [ _matchedTarget performSelector:_matchedSelector ];
}

- (void)fireTerminatedSelector
{
    [ _terminatedTarget performSelector:_terminatedSelector ];
}

static void primeNotifications(void *refcon, io_iterator_t iterator)
{
    io_object_t object;
    
    while (object = IOIteratorNext(iterator))
        ;
}

static void driversMatched(void *refcon, io_iterator_t iterator)
{
    DWXBoxHIDNotifier *self = (DWXBoxHIDNotifier*)refcon;
    io_object_t object;
    
    while (object = IOIteratorNext(iterator))
        ;
    
    [ self fireMatchedSelector ];
}

static void driversTerminated(void *refcon, io_iterator_t iterator)
{
    DWXBoxHIDNotifier *self = (DWXBoxHIDNotifier*)refcon;
    io_object_t object;
    
    while (object = IOIteratorNext(iterator))
        ;
    
    [ self fireTerminatedSelector ];
}

- (BOOL)createRunLoopNotifications
{
 	IOReturn 				kr = kIOReturnSuccess;
	mach_port_t 			masterPort = NULL;
	
    CFMutableDictionaryRef 	matchDictionary = NULL;
	io_iterator_t           notificationIterator;
    
	kr = IOMasterPort (bootstrap_port, &masterPort);
	if (kIOReturnSuccess != kr) {
		NSLog(@"IOMasterPort error with bootstrap_port.\n");
		return NO;
	}   

    _notificationPort = IONotificationPortCreate (masterPort);
    if (NULL == _notificationPort) {
        NSLog(@"Couldn't create notification port.\n");
        return NO;
    }
    
    _runLoopSource = IONotificationPortGetRunLoopSource (_notificationPort);    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), _runLoopSource, kCFRunLoopDefaultMode);

    matchDictionary = IOServiceMatching ("DWXBoxHIDDriver");
    if (!matchDictionary) {
        NSLog(@"IOServiceMatching returned NULL.\n");
        return NO;
    }
    
    CFRetain(matchDictionary); // next call will consume one reference
    
    kr = IOServiceAddMatchingNotification (
            _notificationPort,
            kIOMatchedNotification,
            matchDictionary,
            driversMatched,
            self,
            &notificationIterator);
            
    if (kIOReturnSuccess != kr) {
    
        NSLog(@"IOServiceAddMatchingNotification with kIOMatchedNotification failed with 0x%x\n", kr);
        return NO;
    }
    
    if (notificationIterator)
        primeNotifications(NULL, notificationIterator);

    kr = IOServiceAddMatchingNotification (
                _notificationPort,
                kIOTerminatedNotification,
                matchDictionary,
                driversTerminated,
                self,
                &notificationIterator);
                
    if (kIOReturnSuccess != kr) {
    
        NSLog(@"IOServiceAddMatchingNotification with kIOTerminatedNotification failed with 0x%x\n", kr);
        return NO;
    }
    
    if (notificationIterator)
        primeNotifications(NULL, notificationIterator);
    
    return YES;
}

- (void)releaseRunLoopNotifications
{
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _runLoopSource, kCFRunLoopDefaultMode);
    IONotificationPortDestroy(_notificationPort);
}

+ (id)notifier
{
    DWXBoxHIDNotifier *notifier;
    
    notifier = [ [ DWXBoxHIDNotifier alloc ] init ];

    return [ notifier autorelease ];
}

- (id)init
{
    self = [ super init ];
    if (self) {
    
        if (! [ self createRunLoopNotifications ] ) {
            [ self release ];
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [ self releaseRunLoopNotifications ];
    [ super dealloc ];
}

- (void)setMatchedSelector:(SEL)selector target:(id)target
{
    _matchedSelector = selector;
    _matchedTarget = target;
}

- (void)setTerminatedSelector:(SEL)selector target:(id)target
{
    _terminatedSelector = selector;
    _terminatedTarget = target;
}
@end
