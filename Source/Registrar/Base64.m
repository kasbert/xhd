//
//  Base64.m
//  Registrar
//
//  Created by Darrell Walisser on Wed Jun 25 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

// http://www.ietf.org/rfc/rfc2045.txt
// note: this implementation might not be compliant with the rfc
//
// There is one very obvious change: the '/' and '+' have been
// remapped so "double click word select" works in mailers, etc
//
// Usually these implementations use tables, but I decided not to.
// Tables just waste processor cache and bloat the exe - and speed
// doesn't matter much here.
//
#import "Base64.h"
#import "Debug.h"

@implementation Base64

static char encodeTable(int value)
{
    char encoded = 0;
    
    if (value >= 0 && value <= 25)
        encoded = 'A' + value;
    else
    if (value >= 26 && value <= 51)
        encoded = 'a' + (value - 26);
    else
    if (value >= 52 && value <= 61)
        encoded = '0' + (value - 52);
    else
    if (value == 62)
        encoded = '+';
    else
    if (value == 63)
        encoded = '/';
    else
        DEBUG( NSLog(@"encoding logic error"); ) ;
    
    return encoded;
}

static unsigned char decodeTable(char value)
{
    unsigned char decoded = 0;
    
    if (value >= 'A' && value <= 'Z')
        decoded = value - 'A';
    else
    if (value >= 'a' && value <= 'z')
        decoded = (value - 'a') + 26;
    else
    if (value >= '0' && value <= '9')
        decoded = (value - '0') + 52;
    else
    if (value == '+')
        decoded = 62;
    else
    if (value == '/')
        decoded = 63;
    else
        DEBUG( NSLog(@"illegal base64 encoding"); ) ;
    
    return decoded;
}

+(void)encode:(const void*)inBuffer inSize:(int)inSize
    outBuffer:(void**)outBuffer outSize:(int*)outSize
{
    int numGroups = inSize / 3;
    int restSize  = inSize % 3;
    
    int dstSize = restSize ? (numGroups+1)*4 : numGroups*4;

    unsigned char *srcBuffer = (unsigned char*)inBuffer;
    unsigned char *dstBuffer = (unsigned char*)malloc (dstSize);
    
    NSAssert (dstBuffer != 0, @"Out of memory");
    
    int i;
    for (i = 0; i < numGroups; i++) {

        int srcIndex = i * 3;
        int group = 
            (srcBuffer[srcIndex] << 16) |
            (srcBuffer[srcIndex+1] << 8) |
            (srcBuffer[srcIndex+2]);
        
        int dstIndex = i * 4;
        
        dstBuffer[dstIndex] = encodeTable(group >> 18);
        dstBuffer[dstIndex+1] = encodeTable((group & (0x3f<<12)) >> 12);
        dstBuffer[dstIndex+2] = encodeTable((group & (0x3f<<6)) >> 6);
        dstBuffer[dstIndex+3] = encodeTable(group & 0x3f);
    }
    
    if (restSize) {
    
        int group = 0;
        int srcIndex = i * 3;
        
        switch (restSize) {
        case 2:
            group |= srcBuffer[srcIndex+1] << 8;
        case 1:
            group |= srcBuffer[srcIndex] << 16;
        default:
            ;
        }
            
        int dstIndex = i * 4;
        dstBuffer[dstIndex] = encodeTable(group >> 18);
        dstBuffer[dstIndex+1] = encodeTable((group & (0x3f<<12)) >> 12);
        dstBuffer[dstIndex+2] = encodeTable((group & (0x3f<<6)) >> 6);
        dstBuffer[dstIndex+3] = encodeTable(group & 0x3f);
    }
    
    *outBuffer = dstBuffer;
    *outSize = dstSize;
}
    
+(void)decode:(const void*)inBuffer inSize:(int)inSize
    outBuffer:(void**)outBuffer outSize:(int*)outSize
{
    int numGroups = inSize / 4;
    
    int dstSize = numGroups * 3;

    unsigned char *srcBuffer = (unsigned char*)inBuffer;
    unsigned char *dstBuffer = (unsigned char*)malloc (dstSize);
    
    NSAssert (dstBuffer != 0, @"Out of memory");
    
    int i;
    for (i = 0; i < numGroups; i++) {

        int srcIndex = i * 4;
        
        char c1, c2, c3, c4;
        int group;
        
        c1 = srcBuffer[srcIndex];
        c2 = srcBuffer[srcIndex+1];
        c3 = srcBuffer[srcIndex+2];
        c4 = srcBuffer[srcIndex+3];
        
        group =
            (decodeTable(c1) << 18) |
            (decodeTable(c2) << 12) |
            (decodeTable(c3) << 6) |
            decodeTable(c4);
             
        int dstIndex = i * 3;
        
        dstBuffer[dstIndex] = group >> 16;
        dstBuffer[dstIndex+1] = (group & 0xFF00) >> 8;
        dstBuffer[dstIndex+2] = group & 0xFF;
    }
    
    *outBuffer = dstBuffer;
    *outSize = dstSize;
}

@end
