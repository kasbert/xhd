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
    along with the Xbox HID Driver; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
//
//  DWDPadView.m
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Tue Jun 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "DWDPadView.h"


@implementation DWDPadView

- (void)setValue:(int)value forDirection:(int)direction
{
    switch(direction) {
    case 0: _up = value; break;
    case 1: _down = value; break;
    case 2: _left = value; break;
    case 3: _right = value; break;
    default:
        ;
    }
    
    [ self setNeedsDisplay:YES ];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _up = 0;
        _down = 0;
        _left = 0;
        _right = 0;
    }
    return self;
}

- (void)drawRect:(NSRect)rect {

    rect = [ self bounds ];
    rect = NSInsetRect(rect, 2, 2);
    
    float h3 =  rect.size.height / 3.0;
    float w3 =  rect.size.width / 3.0;
    NSBezierPath *outline = [ NSBezierPath bezierPath ];
    
    [ outline moveToPoint:NSMakePoint(0, h3) ];
    [ outline lineToPoint:NSMakePoint(0, h3*2) ];
    [ outline lineToPoint:NSMakePoint(w3, h3*2) ];
    [ outline lineToPoint:NSMakePoint(w3, h3*3) ];
    [ outline lineToPoint:NSMakePoint(w3*2, h3*3) ];
    [ outline lineToPoint:NSMakePoint(w3*2, h3*2) ];
    [ outline lineToPoint:NSMakePoint(w3*3, h3*2) ];
    [ outline lineToPoint:NSMakePoint(w3*3, h3) ];
    [ outline lineToPoint:NSMakePoint(w3*2, h3) ];
    [ outline lineToPoint:NSMakePoint(w3*2, 0) ];
    [ outline lineToPoint:NSMakePoint(w3, 0) ];
    [ outline lineToPoint:NSMakePoint(w3, h3) ];
    [ outline closePath ];
    
    [ [ NSColor lightGrayColor ] set ];
    [ outline fill ];
    
    NSBezierPath *triPath = [ NSBezierPath bezierPath ];
    #define kCosine60 0.5
    #define kSine60 0.8660254037844386
    float triBase = rect.size.width / 5;
    float triHeight = kSine60*triBase;
    [ triPath moveToPoint:NSMakePoint(0, 0) ];
    [ triPath lineToPoint:NSMakePoint(triBase, 0) ];
    [ triPath lineToPoint:NSMakePoint(triBase*kCosine60, triBase*kSine60) ];
    [ triPath closePath ];
    
    NSGraphicsContext *context = [ NSGraphicsContext currentContext ];
    NSAffineTransform *transform = [ NSAffineTransform transform ];
    float largeOffset = (w3 - triHeight) / 2;
    float smallOffset = (w3 - triBase) / 2;
    
    [ transform translateXBy:w3 - largeOffset yBy:h3 + smallOffset ];
    [ transform rotateByDegrees:90  ];
  
    [ context saveGraphicsState ];
        [ transform concat ];
        if (_left)
            [ [ NSColor greenColor ] set ];
        else
            [ [ NSColor grayColor ] set ];
        
        [ triPath fill ];
        [ [ NSColor blackColor ] set ];
        [ triPath stroke ];
    [ context restoreGraphicsState ];

    transform = [ NSAffineTransform transform ];
    [ transform translateXBy:w3 + smallOffset yBy:h3*2 + largeOffset ];
    
    [ context saveGraphicsState ];
        [ transform concat ];
        
        if (_up)
            [ [ NSColor greenColor ] set ];
        else
            [ [ NSColor grayColor ] set ];
        
        [ triPath fill ];
        [ [ NSColor blackColor ] set ];
        [ triPath stroke ];
    [ context restoreGraphicsState ];
    
    transform = [ NSAffineTransform transform ];

    [ transform translateXBy:w3*2 + largeOffset yBy:h3 + smallOffset + triBase ];
    [ transform rotateByDegrees:-90 ];

    [ context saveGraphicsState ];
        [ transform concat ];
        
        if (_right)
            [ [ NSColor greenColor ] set ];
        else
            [ [ NSColor grayColor ] set ];
        
        [ triPath fill ];
        [ [ NSColor blackColor ] set ];
        [ triPath stroke ];
    [ context restoreGraphicsState ];
    
    transform = [ NSAffineTransform transform ];
    [ transform translateXBy:w3 + triBase + smallOffset yBy:triHeight + largeOffset ];
    [ transform rotateByDegrees:-180 ];
    
    [ context saveGraphicsState ];
        [ transform concat ];
        
        if (_down)
            [ [ NSColor greenColor ] set ];
        else
            [ [ NSColor grayColor ] set ];
        
        [ triPath fill ];
        [ [ NSColor blackColor ] set ];
        [ triPath stroke ];
    [ context restoreGraphicsState ];
    
    [ [ NSColor blackColor ] set ];
    [ outline stroke ];
}

@end
