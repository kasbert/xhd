#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import "DWXBoxHIDDriverInterface.h"
#import "DWXBoxHIDPrefsLoader.h"
#include <signal.h>

/*
void sigquit(int sig)
{
    NSLog(@"sigquit");
    // reenable signal
    signal(SIGQUIT, SIG_DFL);
}
*/

// wait for an xbox device to be connected
// when a device is connected, load settings from disk
// to configure the device
static void driversDidLoad(void *refcon, io_iterator_t iterator)
{
    io_object_t driver;

    while (driver = IOIteratorNext(iterator)) {
    
        NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
        
        DWXBoxHIDDriverInterface *device = [ DWXBoxHIDDriverInterface interfaceWithDriver:driver ];
        [ DWXBoxHIDPrefsLoader createDefaultsForDevice:device ];
        [ DWXBoxHIDPrefsLoader loadSavedConfigForDevice:device ];

            
        NSLog(@"loaded config \"%@\" for device id \"%@\"", 
            [ DWXBoxHIDPrefsLoader configNameForDevice:device ],
            [ device identifier ]);
    
    
        [ pool release ];
    }
}


static void registerForDriverLoadedNotification()
{
 	IOReturn 				kr = kIOReturnSuccess;
	mach_port_t 			masterPort = NULL;
	IONotificationPortRef   notificationPort = NULL;
    CFRunLoopSourceRef      runLoopSource = NULL;
    CFMutableDictionaryRef 	matchDictionary = NULL;
	io_iterator_t           notification;
    
	kr = IOMasterPort (bootstrap_port, &masterPort);
	if (kIOReturnSuccess != kr) {
		printf("IOMasterPort error with bootstrap_port.\n");
		exit(-1);
	}   

    notificationPort = IONotificationPortCreate (masterPort);
    if (NULL == notificationPort) {
        printf("Couldn't create notification port.\n");
        exit(-2);
    }
    
    runLoopSource = IONotificationPortGetRunLoopSource (notificationPort);    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);

    matchDictionary = IOServiceMatching ("DWXBoxHIDDriver");
    if (!matchDictionary) {
        printf("IOServiceMatching returned NULL.\n");
        exit(-3);
    }
    
    kr = IOServiceAddMatchingNotification (
            notificationPort,
            kIOMatchedNotification,
            matchDictionary,
            driversDidLoad,
            NULL,
            &notification);
    if (kIOReturnSuccess != kr) {
    
        printf("IOServiceAddMatchingNotification failed with 0x%x\n", kr);
        exit(-4);
    }
    
    if (notification)
        driversDidLoad(NULL, notification);
}

int main (int argc, const char * argv[]) {
    
    //signal(SIGQUIT, sigquit);
    
    registerForDriverLoadedNotification();
    
    CFRunLoopRun();
        
    return 0;
}
