//
//  DWXBoxHIDDaemonLauncher.m
//  DWXBoxHIDDaemon
//
//  Created by Darrell Walisser on Sun Jun 15 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "DWXBoxHIDDaemonLauncher.h"
#import <Cocoa/Cocoa.h>

@implementation DWXBoxHIDDaemonLauncher

- (void)applicationDidFinishLaunching:(NSNotification*)note
{
    NSString *daemon = @"XboxHIDDaemon";
    NSString *resourcePath = [ [ NSBundle mainBundle ] resourcePath ];
 
    NSString *command = [ NSString stringWithFormat:@"\"%@/%@\" &", resourcePath, daemon, nil ];
    
    int status = system([ command cString ]);
    
    if (status)
        NSLog (@"Error starting XboxHIDDaemon: %d", status);
    
    [ NSApp terminate:self ];
}

@end

int main (int argc, const char * argv[]) {

    return NSApplicationMain(argc, argv);
}