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
//  registerTool.m
//  Registrar
//
//  Created by Darrell Walisser on Wed Jun 25 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "Registrar.h"

int main (int argc, char *argv[])
{
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    
    if (strcmp(argv[1], "-c") == 0) {
    
        char *key = argv[2];
        char *name = argv[3];
        //char *email = argv[4];
                
        NSString *regCode;
        
        [ Registrar createRegistration:[ NSString stringWithCString:name ]
            withPrivateKeyFile:[ NSString stringWithCString:key ]
            outString:&regCode ];
            
        printf ("Name: %s\n", name);
        printf ("Code: %s\n", [ regCode cString ]);
    }
    else
    if (strcmp(argv[1], "-v") == 0) {
    
        char *key  = argv[2];
        char *code = argv[3];
    
        RegistrationError err;
        NSString *regHash = argc < 5 ? nil : [ NSString stringWithCString:argv[4] ];
        
        err = [ Registrar checkRegistration:[ NSString stringWithCString:code ]
            withPublicKeyFile:[ NSString stringWithCString:key ]
            inOutRegistrationHash:&regHash ];
        
        char *error;
        switch (err) {
        case kRegistrationNoError:       	error = "no error"; break;
        case kRegistrationCodeBadFormat: 	error = "bad format"; break;
        case kRegistrationCodeExpired:   	error = "expired"; break;
        case kRegistrationInvalidCode:		error = "invalid"; break;
        case kRegistrationErrorNoPublicKey: error = "bad key"; break;
        default:
            error = "unspecified error";
        }
        
        printf ("Verification said: \"%s\"\n", error);
        printf ("Reg hash is: \"%s\"\n", [ regHash cString ]);
    }

    [ pool release ];
    
    return 0;
}