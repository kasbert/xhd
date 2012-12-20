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
//  installLoginItem.m
//  DWXBoxHIDDaemon
//
//  Created by Darrell Walisser on Mon Jun 16 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//
//  Modified 12/18/2012 to support Standard 32/64-bit architecture. Compiled with Mac OS X 10.6 SDK.
//
//  New code from http://cocoatutorial.grapewave.com/tag/lssharedfilelist-h/
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

#define kLoginWindowDomain @"loginwindow"
#define kLoginWindowItemsArrayKey @"AutoLaunchedApplicationDictionary"
#define kLoginWindowHideKey @"Hide"
#define kLoginWindowPathKey @"Path"

static void installLoginItem(NSString *path, int global, int hidden)
{
    NSString *appPath = path;
    
	// This will retrieve the path for the application
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
    
    // Handle hidden flag
    NSDictionary *properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"com.apple.loginitem.HideOnLaunch"];
    CFDictionaryRef hide = NULL;
    if (hidden == 1) { hide = (CFDictionaryRef)properties; }
    
	// Create a reference to the shared file list.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
    
    // Checks to see if installLoginItem is Session or Global
    CFStringRef *KLSSharedFileList;
    if (global == 1) {KLSSharedFileList = &kLSSharedFileListGlobalLoginItems;} else {KLSSharedFileList = &kLSSharedFileListSessionLoginItems;}
    
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, *KLSSharedFileList, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, hide, NULL);
		if (item){
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

static void removeLoginItem(NSString *path, int global)
{
    NSString *appPath = path;
    
	// This will retrieve the path for the application
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
    CFStringRef *KLSSharedFileList;
    
    // Checks to see if installLoginItem is Session or Global    
    if (global == 1) {KLSSharedFileList = &kLSSharedFileListGlobalLoginItems;}
    else {KLSSharedFileList = &kLSSharedFileListSessionLoginItems;}
    
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, *KLSSharedFileList, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        
		for( int i = 0; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
                //if ([urlPath hasPrefix:appPath]){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
		[loginItemsArray release];
        }
        
    
}
int main (int argc, char** argv)
{
    @autoreleasepool {
        // one parameter is required
        if ((argc<2) || (argc>5))
        {
            printf("Invalid number of aruments.\nUsage: (-install -g -h <dir>) or (-remove -g <dir>)\n");
            exit(1);
        }
        
        int global = 0;
        int hidden = 0;
        int install = 0;
        int remove = 0;
        
        // convert path to NSString
        NSString *path = NULL;
        
        // get values of arguments
        for (int i=0; i<argc; i++)
        {
            
            NSString *str = [NSString stringWithUTF8String:argv[i]];
            //NSLog(@"argv[%d] = '%@'", i, str);
            
            if( ([str isEqualToString:@"-g"]) || ([str isEqualToString:@"-h"]) || ([str isEqualToString:@"-install"]) || ([str isEqualToString:@"-remove"]) ) {
                
                if ([str isEqualToString:@"-g"]) {global = 1;}
                
                if ([str isEqualToString:@"-h"]) {hidden = 1;}
                
                if ([str isEqualToString:@"-install"]) {install = 1;}
                
                if ([str isEqualToString:@"-remove"]) {remove = 1;}
            }
            else {path = str;}
        }
        
        // Basic error checking
        if ( (install+remove!=1) || (global+hidden+install+remove !=argc-2) || (!path) ||(remove+hidden==2) ){
            printf("Invalid arguments.\nUsage: (-install -g -h <dir>) or (-remove -g <dir>)\nn");
            exit(1);
        }
        
        // call functions
        if (install == 1) {installLoginItem(path, global, hidden);}
        else {
            if (remove == 1) {removeLoginItem(path, global);
            }
        }
        
        //NSLog(@"global = '%d', hidden = '%d', install = '%d', remove = '%d', path = '%@'", global, hidden, install, remove, path);
        
    } return 0;
}