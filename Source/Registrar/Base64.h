//
//  Base64.h
//  Registrar
//
//  Created by Darrell Walisser on Wed Jun 25 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Base64 : NSObject
{
}
+(void)encode:(const void*)inBuffer inSize:(int)inSize
    outBuffer:(void**)outBuffer outSize:(int*)outSize;
    
+(void)decode:(const void*)inBuffer inSize:(int)inSize
    outBuffer:(void**)outBuffer outSize:(int*)outSize;
@end
