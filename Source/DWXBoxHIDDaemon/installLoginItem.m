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

int main (int argc, char** argv)
{
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    
    char *user = argv[1];
    char *path = argv[2];
    int hide = atoi(argv[3]); 
    
    NSLog(@"user=\"%s\" path=\"%s\" hide=%d",
        user, path, hide);
        
    installLoginItem(user, path, hide);
    
    [ pool release ];

    return 0;
}