//
//  DWTriggerView.m
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Tue Jun 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "DWTriggerView.h"
static inline int NSEqualRect(NSRect r1, NSRect r2) {

    return r1.origin.x == r2.origin.x && 
           r1.origin.y == r2.origin.y &&
           r1.size.width == r2.size.width &&
           r1.size.height == r2.size.height;
}

@implementation DWTriggerView

- (void)setMax:(int)max
{
    _max = max;
    [ self setNeedsDisplay:YES ];
}

- (void)setValue:(int)value
{
    _value = value;
    [ self setNeedsDisplay:YES ];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    
    rect = [ self bounds ];
    NSGraphicsContext *context = [ NSGraphicsContext currentContext ];
    NSBezierPath *path = [ NSBezierPath bezierPath ];
    NSPoint p0, p1, p2, p3;
    NSPoint c1, c2;
    NSRect clip = rect;
    
    float k = 3.0/8.0; // offset of narrow part from rectangle edges (fraction of width)
    
    clip.size.height = _value * clip.size.height/_max;
    
    p0 = NSMakePoint(rect.origin.x + k*rect.size.width, 0);
    p1 = NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height);
    p2 = NSMakePoint(rect.origin.x+rect.size.width, rect.origin.y + rect.size.height);
    p3 = NSMakePoint(rect.origin.x + rect.size.width - k*rect.size.width, 0);

    c1 = NSMakePoint(rect.origin.x + k*rect.size.width, rect.origin.y + rect.size.height);
    c2 = NSMakePoint(rect.origin.x + rect.size.width - k*rect.size.width, rect.origin.y + rect.size.height);
    
    [ path moveToPoint:p0 ];
    [ path curveToPoint:p1
        controlPoint1:p0
        controlPoint2:c1 ];
    [ path lineToPoint:p2 ];
    [ path curveToPoint:p3
        controlPoint1:c2
        controlPoint2:p3 ];
    [ path lineToPoint:p0 ];

    [ [ NSColor lightGrayColor ] set ];
    [ path fill ];
    
    [ context saveGraphicsState ];
        NSRectClip(clip);
        [ [ NSColor greenColor ] set ];
        [ path fill ];
    [ context restoreGraphicsState ];
    
    [ [ NSColor blackColor ] set ];
    [ path stroke ];
}

@end
