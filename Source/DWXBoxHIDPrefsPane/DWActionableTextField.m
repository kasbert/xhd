//
//  DWActionableTextField.m
//  DWXBoxHIDPrefsPane
//
//  Created by Darrell Walisser on Sat Jun 07 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "DWActionableTextField.h"

@implementation DWActionableTextField
- (void)setIntValue:(int)value
{
    int prevValue = [ super intValue ];
    
    [ super setIntValue:value ];

    if ([ self action ] && [ self target ] &&
        prevValue != value)
        [ [ self target ] performSelector:[ self action ] withObject:self ];
}
@end
