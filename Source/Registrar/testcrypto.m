#import "RSACrypto.h"
#import "Base64.h"

void printBuffer(unsigned char *buffer, int length)
{
    int i;
    printf("\t");
    for (i = 0; i < length; i++) {
        printf("%.2x", buffer[i]);
        if (((i+1)%16) == 0)
            printf("\n\t");
    }
    printf("\n");
    
    char *outBuffer;
    int outSize;
    
    [ Base64 encode:buffer inSize:length
        outBuffer:(void**)&outBuffer outSize:&outSize ];
        
    printf ("base64 encoded: %d bytes\n", outSize);
    printf ("\t");
    for (i = 0; i < outSize; i++) {
        printf ("%c", outBuffer[i]);
        if (((i+1)%32) == 0)
            printf("\n\t");
    }
    printf ("\n\n");
    
    unsigned char *outDecodedBuffer;
    int outDecodedLength;
    
    [ Base64 decode:outBuffer inSize:outSize
        outBuffer:(void**)&outDecodedBuffer outSize:&outDecodedLength ];
    
    printf ("base64 decoded: %d bytes\n", outDecodedLength);
    printf("\t");
    for (i = 0; i < outDecodedLength; i++) {
        printf("%.2x", outDecodedBuffer[i]);
        if (((i+1)%16) == 0)
            printf("\n\t");
    }
    printf("\n\n");
    
    free(outDecodedBuffer);
    free(outBuffer);
}

int main (int argc, char *argv[]) {

    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];

    RSACrypto *crypto = [ RSACrypto crypto ];

    // first test private->public encryption
    //[ crypto loadPublicKey:@"pubkey" ];
    [ crypto loadPrivateKey:@"privkey" ];
    
    //char *message = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcefghijklmnopqrstuvwxyz!@#$%^&*()_+-=~`";
    //char *message = "test123456test123456test123456test123456test12345612";
    char *message = "6/25/03";
    
    char *encryptedBuffer;
    int encryptedSize;
    
    [ crypto privateEncryptBuffer:message inSize:strlen(message) + 1
        outBuffer:(void**)&encryptedBuffer outSize:&encryptedSize ];
    
    printf("encrypted message: %d bytes\n", encryptedSize);
    printBuffer(encryptedBuffer, encryptedSize);
    
    [ crypto loadPublicKey:@"pubkey" ];
    //[ crypto loadPrivateKey:@"privkey" ];
    
    char *originalMessage;
    int originalMessageSize;
    
    [ crypto publicDecryptBuffer:encryptedBuffer inSize:encryptedSize
        outBuffer:(void**)&originalMessage outSize:&originalMessageSize ];
    
    printf ("decrypted message:\n");
    printf ("\t\"%s\"\n", originalMessage);
    
    
    // test public->private encryption

    [ pool release ];
    
    return 0;
}