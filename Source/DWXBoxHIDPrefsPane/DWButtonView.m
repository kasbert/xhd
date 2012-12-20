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
//  DWButtonView.m
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Tue Jun 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "DWButtonView.h"

@implementation DWButtonView

-(void)setDrawsAnalogButtons:(BOOL)drawsAnalog;
{
    _drawsAnalogButtons = drawsAnalog;
    [ self setNeedsDisplay:YES ];
}

-(void)setValue:(UInt8)value forButton:(int)button
{
    switch(button) {
    case 0: _a = value; break;
    case 1: _b = value; break;
    case 2: _x = value; break;
    case 3: _y = value; break;
    case 4: _bl = value; break;
    case 5: _wh = value; break;
    case 6: _back = value; break;
    case 7: _start = value; break;
    default:
        break;
    }
    
    [ self setNeedsDisplay:YES ];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.

        _x = 0;
        _y = 0;
        _a = 0;
        _b = 0;
        _wh = 0;
        _bl = 0;
        _back = 0;
        _start = 0;
        _textPath = 0;
        _roundRectPath = 0;
        _buttonPath = 0;
    }
    return self;
}

- (void)dealloc
{
    if (_textPath)
        [ _textPath release ];
    
    if (_buttonPath)
        [ _buttonPath release ];
    
    if (_roundRectPath)
        [ _roundRectPath release ];
    [super dealloc];    //  v2.0.0 added [super dealloc]
}

- (void)drawButtonValue:(float)value maxValue:(float)maxValue 
    foreColor:(NSColor*)foreground backColor:(NSColor*)background
{
    NSGraphicsContext *context = [ NSGraphicsContext currentContext ];
    NSRect clip = [ _buttonPath bounds ];
    
    clip.size.height *= value/maxValue;
    
    [ background set ];
    [ _buttonPath fill ];
    
    [ foreground set ];
    [ context saveGraphicsState ];
        [ NSBezierPath clipRect:clip ];
        [ _buttonPath fill ];
    [ context restoreGraphicsState ];
}

- (void)drawStartBackButton:(int)value withLabel:(NSString*)label
{
    float radius = 50;
    float startingAngle = -0.42;
    NSPoint center = NSMakePoint(24, -37);
    NSRect  boundsRect = NSMakeRect(0, 3, 50, 0.618 * 50);
    
    NSBezierPath *ovalPath = [ NSBezierPath bezierPathWithOvalInRect:boundsRect ];
    
    if (value)
        [ [ NSColor blackColor ] set ];
    else
        [ [ NSColor grayColor ] set ];
        
    [ ovalPath fill ];

        
    NSTextStorage     *textStorage  = [ [ NSTextStorage alloc ] initWithString:label ];
    NSLayoutManager  *layoutManager = [ [ NSLayoutManager alloc ] init ];
    NSTextContainer *textContainer  = [ [ NSTextContainer alloc ] init ];
        
    if (value)
        [ textStorage addAttribute:NSForegroundColorAttributeName value:[ NSColor whiteColor ] 
            range:NSMakeRange(0, [ textStorage length ]) ];
            
    [ layoutManager setUsesScreenFonts:NO ]; 

    [ layoutManager addTextContainer:textContainer ];
    [ textContainer release ];
    [ textStorage addLayoutManager:layoutManager ];
    [ layoutManager release ];
    
    NSUInteger glyphIndex;  //  v2.0.0 changed int to NSUInteger
    NSRange glyphRange;
    NSRect usedRect;

    // Note that usedRectForTextContainer: does not force layout, so it must 
    // be called after glyphRangeForTextContainer:, which does force layout.
    glyphRange = [ layoutManager glyphRangeForTextContainer:textContainer ];
    usedRect = [ layoutManager usedRectForTextContainer:textContainer ];

    for (glyphIndex = glyphRange.location; glyphIndex < NSMaxRange(glyphRange); glyphIndex++) {
    
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
	    NSRect lineFragmentRect = [ layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL ];
	    NSPoint viewLocation, layoutLocation = [ layoutManager locationForGlyphAtIndex:glyphIndex ];
        float angle, distance;
        NSAffineTransform *transform = [ NSAffineTransform transform ];
    
        // Here layoutLocation is the location (in container coordinates) where the glyph was laid out. 
        layoutLocation.x += lineFragmentRect.origin.x;
        layoutLocation.y += lineFragmentRect.origin.y;

        // We then use the layoutLocation to calculate an appropriate position for the glyph 
        // around the circle (by angle and distance, or viewLocation in rectangular coordinates).
        distance = radius + usedRect.size.height - layoutLocation.y;
        angle = startingAngle + layoutLocation.x / distance;

        viewLocation.x = center.x + distance * sin(angle);
        viewLocation.y = center.y + distance * cos(angle);
        
        // We use a different affine transform for each glyph, to position and rotate it
        // based on its calculated position around the circle.  
        [ transform translateXBy:viewLocation.x yBy:viewLocation.y ];
        [ transform rotateByRadians:-angle ];

        // We save and restore the graphics state so that the transform applies only to this glyph.
        [ context saveGraphicsState ];
        [ transform concat ];
        // drawGlyphsForGlyphRange: draws the glyph at its laid-out location in container coordinates.
        // Since we are using the transform to place the glyph, we subtract the laid-out location here.
        [ layoutManager drawGlyphsForGlyphRange:NSMakeRange(glyphIndex, 1) atPoint:NSMakePoint(-layoutLocation.x, -layoutLocation.y) ];
        
        [ context restoreGraphicsState ];
    }
    
    if (value)
        [ [ NSColor whiteColor ] set ];
    else
        [ [ NSColor blackColor ] set ];
    [ ovalPath stroke ];
    
    [ textStorage autorelease ];
}

- (NSBezierPath*)roundRect:(NSRect)rect withRadius:(float)radius
{
    NSBezierPath *roundRect = [ NSBezierPath bezierPath ];
    NSPoint p0, p1;
    
    p0 = NSMakePoint(rect.origin.x, rect.origin.y + radius);
    p1 = NSMakePoint(rect.origin.x + radius, rect.origin.y + radius);
    [ roundRect moveToPoint:p0  ];
    [ roundRect appendBezierPathWithArcWithCenter:p1 radius:radius startAngle:180 endAngle:270 clockwise:NO ];
    
    p0 = NSMakePoint(rect.origin.x + rect.size.width - radius, rect.origin.y);
    p1 = p0; p1.y += radius;
    [ roundRect appendBezierPathWithPoints:&p0 count:1 ];
    [ roundRect appendBezierPathWithArcWithCenter:p1 radius:radius startAngle:270 endAngle:360 clockwise:NO ];

    p0 = NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - radius);
    p1 = p0; p1.x -= radius;
    [ roundRect appendBezierPathWithPoints:&p0 count:1 ];
    [ roundRect appendBezierPathWithArcWithCenter:p1 radius:radius startAngle:0 endAngle:90 clockwise:NO ];
    
    p0 = NSMakePoint(rect.origin.x + radius, rect.origin.y + rect.size.height);
    p1 = p0; p1.y -= radius;
    [ roundRect appendBezierPathWithPoints:&p0 count:1 ];
    [ roundRect appendBezierPathWithArcWithCenter:p1 radius:radius startAngle:90 endAngle:180 clockwise:NO ];
    
    [ roundRect closePath ];

    return roundRect;
}

- (void)drawRect:(NSRect)rect {
        
    NSGraphicsContext *context = [ NSGraphicsContext currentContext ];
    rect = [ self bounds ];
    rect = NSInsetRect(rect, 2, 2);    
    
    #define kFontName @"Lucida Grande"
    #define kLucidaGrandeGlyphA 36
    #define kLucidaGrandeGlyphB 37
    #define kLucidaGrandeGlyphX 59
    #define kLucidaGrandeGlyphY 60
    
    float radius = rect.size.width * 0.2;
    float buttonInset = radius / 2;
    float buttonSpacing = radius * 0.3; // spacing when inset is radius / 2
    float buttonOffsetRatio = 0.360198; // y-offset ratio from button lower left rectangle (font-dependent)

    
    if (!_roundRectPath)
        _roundRectPath = [ [ self roundRect:rect withRadius:radius ] retain ];

        
    NSRect buttonBounds = NSMakeRect(0, 0, 0, (rect.size.height - 2*buttonInset - buttonSpacing)/2);
    buttonBounds.size.width = buttonBounds.size.height * 0.618; // golden ratio
    
    //NSLog(@"button width=%f height=%f", buttonBounds.size.width, buttonBounds.size.height);
    
    if (!_buttonPath) {
        NSBezierPath *buttonPath = [ NSBezierPath bezierPathWithOvalInRect:buttonBounds ];
        NSAffineTransform *transform = [ NSAffineTransform transform ];
        [ transform rotateByDegrees:10 ];
        _buttonPath = [ transform transformBezierPath:buttonPath ];
        [ _buttonPath retain ];
    }
    
    // fill background
    [ [ NSColor lightGrayColor ] set ];
    [ _roundRectPath fill ];
    
    [ [ NSColor blackColor ] set ];
    
    [ context saveGraphicsState ];
                
        float xPos = 0;
        UInt8 maxButtonValue = 1;
        if (_drawsAnalogButtons)
            maxButtonValue = 255;
            
        float blendFraction = 0.7;
        NSFont *buttonFont = [ NSFont fontWithName:kFontName size:buttonBounds.size.width ];
        NSAssert(buttonFont != nil, @"Can't get font");
        BOOL createTextPath = NO;
        if (!_textPath) {
            _textPath = [ [ NSBezierPath bezierPath ] retain ];
            createTextPath = YES;
        }
        
        // a
        NSAffineTransform *transform = [ NSAffineTransform transform ];
        NSAffineTransformStruct tstruct = [ transform transformStruct ];
        tstruct.tX = buttonInset;
        tstruct.tY = buttonInset;
        xPos += tstruct.tX;
        [ transform setTransformStruct:tstruct ];
        [ transform concat ];
        
        [ self drawButtonValue:_a maxValue:maxButtonValue
            foreColor:[ NSColor greenColor ] 
            backColor:[ [ NSColor greenColor ] 
                blendedColorWithFraction:blendFraction ofColor:[ NSColor whiteColor ] ] ];
        
        [ [ NSColor blackColor ] set ];            
        [ _buttonPath stroke ];
    
        if (createTextPath) {
            [ _textPath moveToPoint:NSMakePoint(xPos+1, buttonInset+buttonOffsetRatio*buttonBounds.size.height) ];
            [ _textPath appendBezierPathWithGlyph:kLucidaGrandeGlyphA inFont:buttonFont ];
        }
        
        // x
        tstruct.tX = buttonSpacing + buttonBounds.size.width;
        tstruct.tY = 0;
        xPos += tstruct.tX;
        [ transform setTransformStruct:tstruct ];
        [ transform concat ];
        
        [ self drawButtonValue:_x maxValue:maxButtonValue
            foreColor:[ NSColor blueColor ] 
            backColor:[ [ NSColor blueColor ] 
                blendedColorWithFraction:blendFraction ofColor:[ NSColor whiteColor ] ] ];
        
        [ [ NSColor blackColor ] set ];
        [ _buttonPath stroke ];
            
        if (createTextPath) {
            [ _textPath moveToPoint:NSMakePoint(xPos+1, buttonInset+buttonOffsetRatio*buttonBounds.size.height) ];
            [ _textPath appendBezierPathWithGlyph:kLucidaGrandeGlyphX inFont:buttonFont ];
        }
        
        // white
        tstruct.tX = buttonSpacing + buttonBounds.size.width;
        tstruct.tY = 0;
        xPos += tstruct.tX;
        [ transform setTransformStruct:tstruct ];
        [ transform concat ];
        
        [ self drawButtonValue:_wh maxValue:maxButtonValue
            foreColor:[ NSColor whiteColor ] 
            backColor:[ [ NSColor grayColor ] 
                blendedColorWithFraction:blendFraction ofColor:[ NSColor whiteColor ] ] ];
        
        [ [ NSColor blackColor ] set ];
        [ _buttonPath stroke ];
        
        // back
        tstruct.tX = buttonSpacing + buttonBounds.size.width;
        tstruct.tY = 0;
        xPos += tstruct.tX;
        [ transform setTransformStruct:tstruct ];
        [ transform concat ];
        
        [ self drawStartBackButton:_back withLabel:@"b a c k" ];
        
        // b
        tstruct.tX = -xPos + buttonInset;
        tstruct.tY = buttonSpacing + buttonBounds.size.height;
        xPos = buttonInset;
        [ transform setTransformStruct:tstruct ];
        [ transform concat ];
        
        [ self drawButtonValue:_b maxValue:maxButtonValue
            foreColor:[ NSColor redColor ] 
            backColor:[ [ NSColor redColor ] 
            blendedColorWithFraction:blendFraction ofColor:[ NSColor whiteColor ] ] ];

        [ [ NSColor blackColor ] set ];
        [ _buttonPath stroke ];
            
        if (createTextPath) {
            [ _textPath moveToPoint:NSMakePoint(xPos+1, 
                buttonInset+buttonSpacing+buttonBounds.size.height+buttonOffsetRatio*buttonBounds.size.height) ];
            [ _textPath appendBezierPathWithGlyph:kLucidaGrandeGlyphB inFont:buttonFont ];
        }
        
        // y
        tstruct.tX = buttonSpacing + buttonBounds.size.width;
        tstruct.tY = 0;
        xPos += tstruct.tX;
        [ transform setTransformStruct:tstruct ];
        [ transform concat ];
        
         [ self drawButtonValue:_y maxValue:maxButtonValue
            foreColor:[ [ NSColor yellowColor ] 
                blendedColorWithFraction:0.1 ofColor:[ NSColor blackColor ] ]  
            backColor:[ [ NSColor yellowColor ] 
                blendedColorWithFraction:blendFraction ofColor:[ NSColor whiteColor ] ] ];
        
        [ [ NSColor blackColor ] set ];
        [ _buttonPath stroke ];
        
        if (createTextPath) {
            [ _textPath moveToPoint:NSMakePoint(xPos, 
                buttonInset+buttonSpacing+buttonBounds.size.height+buttonOffsetRatio*buttonBounds.size.height) ];
            [ _textPath appendBezierPathWithGlyph:kLucidaGrandeGlyphY inFont:buttonFont ];
        }
        
        // black
        tstruct.tX = buttonSpacing + buttonBounds.size.width;
        tstruct.tY = 0;
        [ transform setTransformStruct:tstruct ];
        [ transform concat ];
        
         [ self drawButtonValue:_bl maxValue:maxButtonValue
            foreColor:[ NSColor blackColor ] 
            backColor:[ NSColor darkGrayColor ] ];
            
        [ [ NSColor blackColor ] set ];
        [ _buttonPath stroke ];
        
        // start
        tstruct.tX = buttonSpacing + buttonBounds.size.width;
        tstruct.tY = 0;
        [ transform setTransformStruct:tstruct ];
        [ transform concat ];
        
        [ self drawStartBackButton:_start withLabel:@"s t a r t" ];

        
    [ context restoreGraphicsState ];
    
    [ [ NSColor blackColor ] set ];
    [ _textPath fill ];
    
    [ [ NSColor blackColor ] set ];
    [ _roundRectPath stroke ];
}

@end
