//
//  DWXBoxHIDNotifier.h
//  DWXBoxHIDDriver
//
//  Created by Darrell Walisser on Wed Jun 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>

@interface DWXBoxHIDNotifier : NSObject
{
    SEL _matchedSelector;
    id _matchedTarget;
    
    SEL _terminatedSelector;
    id  _terminatedTarget;
    
    IONotificationPortRef   _notificationPort;
    CFRunLoopSourceRef      _runLoopSource;
}
+ (id)notifier;
- (id)init;
- (void)setMatchedSelector:(SEL)selector target:(id)target;
- (void)setTerminatedSelector:(SEL)selector target:(id)target;
@end
