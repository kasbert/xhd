//
//  Registrar.h
//  Registrar
//
//  Created by Darrell Walisser on Wed Jun 25 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  
{
    kRegistrationNoError = 0,
    kRegistrationCodeBadFormat,
    kRegistrationCodeExpired,
    kRegistrationInvalidCode,
    kRegistrationErrorNoPublicKey

} RegistrationError;

@interface Registrar : NSObject
{
}

// verify registration - we do this each time you start the app
+ (RegistrationError)checkRegistration:(NSString*)registrationString 
    withPublicKeyFile:(NSString*)keyFile inOutRegistrationHash:(NSString**)hashPtr;

+ (BOOL)createRegistration:(NSString*)registrationName 
    withPrivateKeyFile:(NSString*)keyFile 	outString:(NSString**)outString;

// read and/or create time stamp for demo expiring code
+ (NSTimeInterval)readSecretTimestamp:(NSString*)secretBundleID;
@end
