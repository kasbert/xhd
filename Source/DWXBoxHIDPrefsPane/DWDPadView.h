//
//  DWDPadView.h
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Tue Jun 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface DWDPadView : NSView
{
    int _up, _down, _left, _right;
}
- (void)setValue:(int)value forDirection:(int)direction;
@end
