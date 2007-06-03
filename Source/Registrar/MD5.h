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
//  MD5.h
//  ConvertMake
//
//  Created by Darrell Walisser on Mon Feb 24 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef MD5_H
#define MD5_H

#ifdef __alpha
typedef unsigned int uint32;
#else
typedef unsigned long uint32;
#endif
 
 struct MD5Context
 {
    uint32 buf[4];
    uint32 bits[2];
    unsigned char in[64];
 };
 
void MD5Init (struct MD5Context *context);
void MD5Update (struct MD5Context *context, unsigned char const *buf, unsigned len);
void MD5Final (unsigned char digest[16], struct MD5Context *context);
void MD5Transform (uint32 buf[4], uint32 const in[16]);

/*
* This is needed to make RSAREF happy on some MS-DOS compilers.
*/
typedef struct MD5Context MD5_CTX;

#endif /* !MD5_H */

/*
@interface MD5 : NSObject {

}
@end
*/

//
// EOF
//