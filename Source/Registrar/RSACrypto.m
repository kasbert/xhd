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
#import "RSACrypto.h"
#import "Debug.h"

#include <openssl/rsa.h>
#include <openssl/pem.h>

// this code is mostly copied from: 
//	http://qadpz.idi.ntnu.no/doxy/html/RSAcrypter_8cpp-source.html

// except it does private->public encryption (think digital signatures) and not public->private

// this class requires linking to libcrypto in OpenSSL (pass -lcrypto to gcc)

@implementation RSACrypto

#pragma mark ----- "Private" Methods ---

- (BOOL)loadKey:(NSString*)path isPublic:(BOOL)isPublic
{
    // create private key with: > openssl genrsa -out privateKey
    // create public key with:  > openssl rsa -pubout -in privateKey -out publicKey
    
    BOOL success = NO;
    
    if (_key) {
        RSA_free (_key);
        _key = 0;
    }
    
    FILE *f = fopen ([ path cString ], "r");
    if (f)
        if (isPublic)
            _key = PEM_read_RSA_PUBKEY (f, 0, 0, 0);
        else
            _key = PEM_read_RSAPrivateKey (f, 0, 0, 0);
    else
        DEBUG( NSLog(@"Cannot open file \"%@\" for reading", path); ) ;
    
	fclose(f);
	
    if (_key)
        success = YES;
    
    return success;
}



#pragma mark ----- Interface Methods ---

- (id)init
{
    self = [ super init ];
    if (self) {
    
        _key = 0;
    }
    
    return self;
}

- (void)dealloc
{
    if (_key) {
        RSA_free(_key);
        _key = 0;
    }
    
    [ super dealloc ];
}

+ (id)crypto
{
    return [ [ [ RSACrypto alloc ] init ] autorelease ];
}

- (BOOL)loadPublicKey:(NSString*)path
{
    return [ self loadKey:path isPublic:YES ];
}

- (BOOL)loadPrivateKey:(NSString*)path
{
    return [ self loadKey:path isPublic:NO ];   
}

// In theory, rsa encryption uses the exact same process as decryption...
// Q: So, why the two different procedures in OpenSSL?
// A: Because OpenSSL puts padding into blocks to strengthen the encryption,
//    so the size of the encrypted data is slightly larger, and size of decrypted
//    data is slightly smaller (the amount depends on the padding used, and the size
//    of the encryption key - bigger keys mean you don't waste as much on padding).
//
//    note: RSA_private_encrypt (which is used here) doesn't do random padding
//
// At least, this is how I understand it... I haven't looked for an explanation elsewhere
//
// Note: you'll need to load an rsa private key for this operation
//
- (BOOL)privateEncryptBuffer:(const void*)inBuffer inSize:(int)inSize
    outBuffer:(void**)outBuffer outSize:(int*)outSize
{
    int modulusSize = RSA_size(_key);
    
    // Decrease the block size to leave room for RSA_PKCS1_PADDING
    int blockSize   = modulusSize - 12;

    // Figure out how data fits into whole-number of blocks
    int numFullBlocks  = inSize / blockSize;
    int remainingSize  = inSize - (numFullBlocks * blockSize); 
    int dstSize        = remainingSize > 0 ? (numFullBlocks + 1) * modulusSize : numFullBlocks * modulusSize;
    
    char* srcBuffer = (char*)inBuffer;
    char* dstBuffer = (char*)malloc (dstSize);

    NSAssert (dstBuffer != 0, @"Out of memory");

    int i;
    
    char *srcPtr = srcBuffer;
    char *dstPtr = dstBuffer;
        
    for (i = 0; i < numFullBlocks; i++) {
    
        int ret = RSA_private_encrypt (blockSize, srcPtr, dstPtr, _key, RSA_PKCS1_PADDING);
        if (ret != modulusSize) {
            DEBUG( NSLog(@"RSA_private_encrypt error: %d", ret); )
            return NO;
        }
        
        srcPtr += blockSize;
        dstPtr += modulusSize;
    }
    
    if (remainingSize > 0) {
    
        int ret = RSA_private_encrypt (remainingSize, srcPtr, dstPtr, _key, RSA_PKCS1_PADDING);
        if (ret != modulusSize) {
            DEBUG( NSLog(@"RSA_private_encrypt finish error: %d", ret); )
            return NO;
        }
    }
    
    *outBuffer = dstBuffer;
    *outSize   = dstSize;
    
    return YES;
}

// Note: you'll need to load an rsa public key for this to work
- (BOOL)publicDecryptBuffer:(const void*)inBuffer inSize:(int)inSize
    outBuffer:(void**)outBuffer outSize:(int*)outSize
{
    int modulusSize = RSA_size(_key);
    
    // Decrease the block size to leave room for RSA_PKCS1_PADDING
    int blockSize   = modulusSize - 12;

    // Figure out many blocks we'll be getting out
    int numFullBlocks  = inSize / modulusSize;
    int remainingSize  = inSize - (numFullBlocks * modulusSize);
    int dstSize        = (numFullBlocks) * blockSize;
    
    // this should be 0 if the key size is right for the job
    if (remainingSize != 0) {
        DEBUG( NSLog(@"Encryption key mismatch!"); )
        return NO;
    }
    
    char* srcBuffer = (char*)inBuffer;
    char* dstBuffer = (char*)malloc (dstSize);

    NSAssert (dstBuffer != 0, @"Out of memory");

    int i;
    
    char *srcPtr = srcBuffer;
    char *dstPtr = dstBuffer;
        
    for (i = 0; i < numFullBlocks; i++) {
    
        int ret = RSA_public_decrypt (modulusSize, srcPtr, dstPtr, _key, RSA_PKCS1_PADDING);
        if (ret <= 0) {
            DEBUG( NSLog(@"RSA_public_decrypt error: %d", ret); )
            return NO;
        }
        
        srcPtr += modulusSize;
        dstPtr += blockSize;
    }
    
    *outBuffer = dstBuffer;
    *outSize   = dstSize;
    
    return YES;
}

@end