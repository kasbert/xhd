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
//  DWAxisPairView.m
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Mon Jun 02 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "DWAxisPairView.h"


@implementation DWAxisPairView

- (void)setPressed:(BOOL)pressed
{
    _pressed = pressed;
    [ self setNeedsDisplay:YES ];
}

- (void)setX:(int)x
{
    _x = x;
    [ self setNeedsDisplay:YES ];
}

- (void)setY:(int)y
{
    _y = y;
    [ self setNeedsDisplay:YES ];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        _x = 0;
        _y = 0;
        _minx = -32768;
        _maxx = 32767;
        _miny = -32768;
        _maxy = 32767;
        _pressed = 0;
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
    rect = [ self bounds ];
    NSGraphicsContext *context = [ NSGraphicsContext currentContext ];
    NSRect insideRect = NSInsetRect(rect, 2, 2);
    NSBezierPath *circle = [ NSBezierPath bezierPathWithOvalInRect:insideRect ];
    NSAffineTransform *transform;
    
    [ [ NSColor lightGrayColor ] set ];
    [  circle fill ];
    
    [ context saveGraphicsState ];
        transform = [ NSAffineTransform transform ];
 
        [ transform 
            scaleXBy:
                (rect.size.width - rect.origin.x) / (_maxx - _minx) 
            yBy:
                 -(rect.size.height - rect.origin.y) / (_maxy - _miny) ];
 
        [ transform
            translateXBy:
                (_maxx - _minx) / 2.0
            yBy:
                (_maxy - _miny) / 2.0 - (_maxy - _miny) ];       
        
        [ transform
            scaleXBy:0.70
            yBy:0.70 ];
            
        [ transform concat ];

        
        {
            NSRect referenceRect = NSMakeRect(_minx, _miny, _maxx-_minx, _maxy-_miny);
            NSBezierPath *referenceCircle = [ NSBezierPath bezierPathWithOvalInRect:referenceRect ];
            [ [ NSColor grayColor ] set ];
            [ referenceCircle fill ];
        }
                
        {
            int size = _pressed * 5000 + 5000;
            NSRect crossHairsRect = NSMakeRect(_x-size, _y-size, size*2, size*2);
            NSBezierPath *circle = [ NSBezierPath bezierPathWithOvalInRect:crossHairsRect ];
            [ [ NSColor greenColor ] set ];
            [ circle fill ];
            
        }

    [ context restoreGraphicsState ];
    
    [ [ NSColor blackColor ] set ];
    [ circle stroke ];    
}

- (BOOL)isOpaque
{
    return NO;
}

@end
