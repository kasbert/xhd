//
//  DWButtonView.h
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Tue Jun 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface DWButtonView : NSView
{
    UInt8 _x, _y, _a, _b, _wh, _bl, _back, _start;
    NSBezierPath *_textPath;
    NSBezierPath *_roundRectPath;
    NSBezierPath *_buttonPath;
    BOOL _drawsAnalogButtons;
}
-(void)setDrawsAnalogButtons:(BOOL)drawsAnalog;
-(void)setValue:(UInt8)value forButton:(int)button;
@end
