//
//  DWAxisPairView.h
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Mon Jun 02 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface DWAxisPairView : NSView
{
    float _x, _y;
    float _minx, _miny;
    float _maxx, _maxy;
    BOOL _pressed;
}
- (void)setPressed:(BOOL)pressed;
- (void)setX:(int)x;
- (void)setY:(int)y;
@end
