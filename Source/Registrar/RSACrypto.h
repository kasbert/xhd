#import <Foundation/Foundation.h>

// This is an RSA encryption utility for
// signature-like encryption scenarios
//
// For example, when generating a serial number,
// 	you encrypt some data with the private key
//
// The end user's machine decrypts the serial number
//   with the public key to unlock the software.
//
// This always encrypts the exact same source the same way,
// so you'll want to add some random salt if you want good
// variability

@interface RSACrypto : NSObject
{
    void *_key;
}
- (id)init;
+ (id)crypto;

- (BOOL)loadPublicKey:(NSString*)path;
- (BOOL)loadPrivateKey:(NSString*)path;

- (BOOL)privateEncryptBuffer:(const void*)inBuffer inSize:(int)inSize
    outBuffer:(void**)outBuffer outSize:(int*)outSize;
    
- (BOOL)publicDecryptBuffer:(const void*)inBuffer inSize:(int)inSize
    outBuffer:(void**)outBuffer outSize:(int*)outSize;
@end