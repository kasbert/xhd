//
//  Registrar.m
//  Registrar
//
//  Created by Darrell Walisser on Wed Jun 25 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

// My custom registration system
//
//  Pros:
//    - simple, small, and easy to implement
//    - keys are only valid 30 days after being issued (internally time-stamped)
//    - no two keys are the same (even for the same person!)
//    - key contains customer name to track source of stolen keys
//
//  Cons:
//    - keys are pretty big - 88 characters when base64 encoded (we assume cut&paste for entry)
//        could decrease the rsa key size to decrease that
//    - somewhat easy to crack:
//      1. disassemble checkRegistration
//      2. figure out how hash is generated (by appending ethernet hw address)
//      3. create rsa keypair
//      4. use (2 and 3) to create a fake code and hash


#import "Registrar.h"
#import "RSACrypto.h"
#import "Base64.h"
#import "MD5.h"
#import "Debug.h"

#import <unistd.h>

#define kExpectedCodeDataSize 64
#define kSecretTimestampKey @"DateSortMinTime" // total bullshit


// this structure has 52 bytes to work with
// to generate a 64-byte encrypted block

#pragma pack(1)
typedef struct
{
    char name[32];            //  person's name + random data filler
    NSTimeInterval interval;  //  date code was created
    char random[12];          //  more random data
    
} RegistrationStruct;

typedef int checkSize[ (sizeof(RegistrationStruct) == 52) * 2 - 1 ];

@implementation Registrar

+ (NSString*)getEthernetHWAddress;
{
    
    // If I understood Mach, I mean if I could find the documentation,
    // I wouldn't have to do this in such a hacked-up way
    
    char *script = "/sbin/ifconfig en0 | /usr/bin/grep \"ether\" | "
                   "/usr/bin/perl -e "
                        "'my @tok=split(\" \", <>);\n"
                        "print $tok[1];\n'";
    
    int pipefd[2];
    pipe(pipefd);         // create pipe
    
    int savefd = dup(1);  // save stdout
    dup2 (pipefd[1], 1);  // map stdout to write end of pipe
    system (script);      // invoke our command
    
    char buffer[18];
    int sz = read (pipefd[0], buffer, 17);  // read output
    buffer[sz] = '\0';                      // stringify
    
    dup2 (savefd, 1); 		// restore stdout
    
    close (savefd);         // close files
    close (pipefd[0]);
    close (pipefd[1]);

    NSAssert(sz==17, @"Size check error");

    NSString *macAddress = [ NSString stringWithCString:buffer ];

    return macAddress;
}

// verify registration - we do this each time you start the app
+ (RegistrationError)checkRegistration:(NSString*)registrationString 
    withPublicKeyFile:(NSString*)keyFile inOutRegistrationHash:(NSString**)hashPtr;
{
    
    // first convert registration code to raw data
    void *rawCode;
    int   rawSize;
    
    [ Base64 decode:[ registrationString cString ] inSize:[ registrationString length ] + 1
        outBuffer:&rawCode outSize:&rawSize ];
    
    // ok, now truncate to expected code size (base64 encoding/decoding can add padding)
    if (rawSize < kExpectedCodeDataSize)
        return kRegistrationCodeBadFormat;
        
    rawSize = kExpectedCodeDataSize;
    
    // load our public key
    RSACrypto *rsa = [ RSACrypto crypto ];
    if (![ rsa loadPublicKey:keyFile ])
        return kRegistrationErrorNoPublicKey;
        
    // decrypt registration data
    void *decryptedCode;
    int decryptedSize;
    
    if (! [ rsa publicDecryptBuffer:rawCode inSize:rawSize
                outBuffer:&decryptedCode outSize:&decryptedSize ])
        return kRegistrationInvalidCode;
        
    // check hash against hash(code + ethernet address)
    // this keeps copying prefs files from bypassing registration
    NSString *addr = [ Registrar getEthernetHWAddress ];
    DEBUG( NSLog (@"Ethernet addr=%@", addr); )
    
    struct MD5Context context;
    unsigned char codeMD5Digest[16];
    memset (codeMD5Digest, 0, sizeof(codeMD5Digest));
    
    MD5Init (&context);
    MD5Update (&context, decryptedCode, decryptedSize);
    MD5Update (&context, [ addr cString ], 17);
    MD5Final (codeMD5Digest, &context);
    
    // if there is a stored hash, we already registered at some point
    // so check to make sure prefs files were not copied
    if (*hashPtr) {
    
        void *storedHash = (void*)[ *hashPtr cString ];
        int storedHashSize = strlen(storedHash);
        
        // decode stored hash
        [ Base64 decode:storedHash inSize:storedHashSize
            outBuffer:&storedHash outSize:&storedHashSize ];
        
        // compare stored hash to code hash
        if (memcmp (codeMD5Digest, storedHash, 16) != 0) {
            
            DEBUG( char *encodedHash; )
            DEBUG( int encodedHashSize; )
            DEBUG( NSString *hash; )
            DEBUG( [ Base64 encode:codeMD5Digest inSize:sizeof(codeMD5Digest)
                        outBuffer:(void**)&encodedHash outSize:&encodedHashSize ]; )
            DEBUG( hash = [ NSString stringWithCString:encodedHash length:encodedHashSize ]; )
            DEBUG( free (encodedHash); )
            DEBUG( NSLog (@"Hash verify failed"); )
            DEBUG( NSLog (@"Result hash = %@", hash); )
            DEBUG( NSLog (@"Stored hash = %@", *hashPtr); )
            *hashPtr = nil;
            return kRegistrationInvalidCode;
        }
        
        free (storedHash);
    
        DEBUG( NSLog (@"Hash verified: %@", *hashPtr); )
        return kRegistrationNoError; // registration is valid
    }
    
    // do date checks
    RegistrationStruct *reg = (RegistrationStruct*)decryptedCode;
    NSDate *regDate = [ NSDate dateWithTimeIntervalSince1970:reg->interval ];
    
    // debug: print out name and generation date
    DEBUG( NSDateFormatter *fmt = [ [ NSDateFormatter alloc ] initWithDateFormat:@"%m/%d/%y %H:%M:%S" allowNaturalLanguage:NO ]; )
    DEBUG( NSLog (@"Code generated on %@ for \"%s\"", [ fmt stringForObjectValue:regDate ], reg->name); )
    
    // check that date is within 30 days of now
    NSDate *nowDate = [ NSDate date ];
    
    NSTimeInterval elapsed = [ nowDate timeIntervalSince1970 ] - [ regDate timeIntervalSince1970 ];
    DEBUG ( NSLog (@"Code age is %f days", elapsed/60/60/24); )
    if (elapsed > (60 * 60 * 24 * 30) || elapsed < 0)
        return kRegistrationCodeExpired;
    
    
    // OK, date checked out, so return stored hash for next time
    void *encodedHash;
    int encodedHashSize;
    
    [ Base64 encode:codeMD5Digest inSize:sizeof(codeMD5Digest)
        outBuffer:&encodedHash outSize:&encodedHashSize ];
    
    *hashPtr = [ NSString stringWithCString:encodedHash length:encodedHashSize ];
    //DEBUG( NSLog (@"Hash created: %@", *hashPtr); )
    
    //free (encodedHash);
    printf("foo\n");
    
    return kRegistrationNoError;
}

// Note: Should probably comment out this function in production code
// for security reasons. A person can create their own keypair
// and call this function (via APE or otherwise) to generate
// a key. Leaving this out makes it tougher by forcing one
// to disassemble/analyze +checkRegistration to figure out
// the structure format.
//
+ (BOOL)createRegistration:(NSString*)registrationName 
    withPrivateKeyFile:(NSString*)keyFile outString:(NSString**)outString
{
    RegistrationStruct reg;
    
    reg.interval = [ [ NSDate date ] timeIntervalSince1970 ];
    
    const char *name = [ registrationName cString ];
    int i;
    int copy = strlen(name) < 32 ? strlen (name) : 31;
    
    // copy in name
    for (i = 0; i < copy; i++)
        reg.name[i] = name[i];
    reg.name[i++] = '\0';
    
    // maybe there are better ways to seed, but that doesn't matter much here
    srand (time(NULL));
    
    // copy in random numbers to fill name
    for (; i < 32; i++)
        reg.name[i] = random() / 255;
    
    // copy in random numbers to fill rest of struct
    for (i = 0; i < 12; i++)
        reg.random[i] = random() / 255;

    RSACrypto *rsa = [ RSACrypto crypto ];
    if (![ rsa loadPrivateKey:keyFile ]) {
        DEBUG( NSLog (@"Bad private key file: \"%@\"", keyFile); )
        return NO;
    }

    void *encryptedData;
    int encryptedDataSize;
    
    if (![ rsa privateEncryptBuffer:&reg inSize:sizeof(reg)
            outBuffer:&encryptedData outSize:&encryptedDataSize ]) {
        DEBUG( NSLog(@"Private encryption failed"); )
        return NO;
    }

    void *encodedData;
    int encodedDataSize;
    
    [ Base64 encode:encryptedData inSize:encryptedDataSize
        outBuffer:&encodedData outSize:&encodedDataSize ];
        
    *outString = [ NSString stringWithCString:encodedData length:encodedDataSize ];
    
    free (encryptedData);
    free (encodedData);
    
    return YES;
}
    
// read and/or create time stamp for demo expiring code
+ (NSTimeInterval)readSecretTimestamp:(NSString*)secretBundleID
{
    NSUserDefaults *userDefaults = [ NSUserDefaults standardUserDefaults ];
    [ userDefaults synchronize ];
    NSDictionary *defaults = [ userDefaults persistentDomainForName:secretBundleID ];
    
    NSTimeInterval stamp;
    
    if ([ defaults objectForKey:kSecretTimestampKey ]) {
    
        stamp = [ [ defaults objectForKey:kSecretTimestampKey ] doubleValue ];
    }
    else {
    
        NSMutableDictionary *defaultsMutable = [ defaults mutableCopy ];
        stamp = [ [ NSDate date ] timeIntervalSince1970 ];
        [ defaultsMutable setObject:[ NSNumber numberWithDouble:stamp ] forKey:kSecretTimestampKey ];
        [ userDefaults setPersistentDomain:defaultsMutable forName:secretBundleID ];
    }
    
    return stamp;
}

@end
