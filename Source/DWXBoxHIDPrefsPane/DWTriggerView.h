//
//  DWTriggerView.h
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Tue Jun 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface DWTriggerView : NSView
{
    float _max;
    float _value;
}
- (void)setMax:(int)max;
- (void)setValue:(int)value;
@end
