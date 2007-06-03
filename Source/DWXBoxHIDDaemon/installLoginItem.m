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
#import <Foundation/Foundation.h>

#define kLoginWindowDomain @"loginwindow"
#define kLoginWindowItemsArrayKey @"AutoLaunchedApplicationDictionary"
#define kLoginWindowHideKey @"Hide"
#define kLoginWindowPathKey @"Path"

static void installLoginItem(char *user, char *path, int hide)
{
    id hideObj = hide ? (id)kCFBooleanTrue : (id)kCFBooleanFalse;
    NSString *pathObj = [ NSString stringWithCString:path ];
    
    NSString *plistPath = [ NSString stringWithFormat:@"/Users/%s/Library/Preferences/%@.plist",
        user, kLoginWindowDomain, nil ];
    
    NSMutableDictionary *dict = [ NSMutableDictionary dictionaryWithContentsOfFile:plistPath ];
    NSMutableArray *loginItems = [ dict objectForKey:kLoginWindowItemsArrayKey ];
    
    // remove any login items with the same path
    int i = 0;
    for (i = 0; i < [ loginItems count ]; i++) {
    
        NSString *itemPath = [ [ loginItems objectAtIndex:i ] objectForKey:kLoginWindowPathKey ];
        if ([ itemPath isEqualTo:pathObj ]) {
        
            [ loginItems removeObjectAtIndex:i ];
            i = 0;
        }
    }
    
    // add our login item
    {
        NSMutableDictionary *item = [ NSMutableDictionary dictionary ];
        [ item setObject:hideObj forKey:kLoginWindowHideKey ];
        [ item setObject:pathObj forKey:kLoginWindowPathKey ];
    
        [ loginItems addObject:item ];
    }
    
    
    [ dict writeToFile:plistPath atomically:YES ];
}

static void removeLoginItem(char *user, char *path)
{
    NSString *pathObj = [ NSString stringWithCString:path ];
    
    NSString *plistPath = [ NSString stringWithFormat:@"/Users/%s/Library/Preferences/%@.plist",
        user, kLoginWindowDomain, nil ];
    
    NSMutableDictionary *dict = [ NSMutableDictionary dictionaryWithContentsOfFile:plistPath ];
    NSMutableArray *loginItems = [ dict objectForKey:kLoginWindowItemsArrayKey ];
    
    // remove any login items with the same path
    int i = 0;
    for (i = 0; i < [ loginItems count ]; i++) {
    
        NSString *itemPath = [ [ loginItems objectAtIndex:i ] objectForKey:kLoginWindowPathKey ];
        if ([ itemPath isEqualTo:pathObj ]) {
        
            [ loginItems removeObjectAtIndex:i ];
            i = 0;
        }
    }
    
    
    [ dict writeToFile:plistPath atomically:YES ];
}

int main (int argc, char** argv)
{
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    
    char *cmd = argv[1];
    char *user = argv[2];
    char *path = argv[3];
    
	if (strcmp(cmd, "-install") == 0)
	{
		int hide = atoi(argv[4]); 
    
	    NSLog(@"Install login item: user=\"%s\" path=\"%s\" hide=%d",
			user, path, hide);
			
		installLoginItem(user, path, hide);
	}
	else
	if (strcmp(cmd, "-remove") == 0)
	{
	    NSLog(@"Remove login item: user=\"%s\" path=\"%s\"",
			user, path);
			
		removeLoginItem(user, path);
	}
	else
	{
		NSLog(@"Install login item: unknown command: %s", cmd);
	}
  
    
    [ pool release ];

    return 0;
}