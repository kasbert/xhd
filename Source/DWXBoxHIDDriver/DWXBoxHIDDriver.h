/*
Portions Copyright (c) 1999-2003 Apple Computer, Inc. All Rights Reserved.


This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Apple Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://www.apple.com/publicsource and read it before using this file.


The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
*/

/*
    How to Obtain this Code:
        Point your browser at http://homepage.mac.com/walisser/xboxhiddriver
    
    Modifications to Original Code
        05-16-2003 Added manipulateReport() method to allow subclasses to modify the hid report
                   before it's passed to HIDDevice's handleReport()

    Background:
        This class is a modified IOUSBHIDDriver for use with XBox USB devices. I wanted to
        just subclass IOUSBHIDDriver, but because the XBox has no HID descriptor (or HID
        report descriptor), and GetHIDDescriptor() is a private method, I had to create
        a complete copy.
        
        I think this really sucks, and hope that Apple's HID implementation will grow to more easily 
        support USB devices that are not HID-compatible.
        
    Problems in the Code:
        Right now, I can only support (presumably) the large XBox controller and variants. Each
        variant needs to be added to the IOKitPersonalities or it won't be matched to this
        driver.
        
        What I would *like* to do is put almost all of the device-specific crap (hid report 
        descriptor, string table, etc in the Info.plist so that it will be possible to support
        new devices without touching the code or recompiling the kext ("you can doooit!").
        
        It would be really, really, really nice if Apple's HID implementation actually consulted
        the String_Index items in the report descriptor...I've complained about this on the Apple
        usb list so we'll see.
        
        Force feedback needs to be looked into as well.
*/

#ifndef IOUSBHIDDRIVER_H
#define IOUSBHIDDRIVER_H

#include <IOKit/IOBufferMemoryDescriptor.h>

#include <IOKit/hid/IOHIDDevice.h>

#include <IOKit/usb/IOUSBBus.h>
#include <IOKit/usb/IOUSBInterface.h>
#include <IOKit/usb/USB.h>


#define ENABLE_HIDREPORT_LOGGING    0

// Report types from low level USB:
//  from USBSpec.h:
//    enum {
//        kHIDRtInputReport     = 1,
//        kHIDRtOutputReport        = 2,
//        kHIDRtFeatureReport       = 3
//    };
//    
//  from IOHIDDescriptorParser.h:
//    // types of HID reports (input, output, feature)
//    enum
//    {
//        kHIDInputReport           =   1,
//        kHIDOutputReport,
//        kHIDFeatureReport,
//        kHIDUnknownReport     =   255
//    };
//    
// Report types from high level HID Manager:
//  from IOHIDKeys.h:
//    enum IOHIDReportType
//    {
//        kIOHIDReportTypeInput = 0,
//        kIOHIDReportTypeOutput,
//        kIOHIDReportTypeFeature,
//        kIOHIDReportTypeCount
//    };
//
#define HIDMgr2USBReportType(x) (x + 1)
#define USB2HIDMgrReportType(x) (x - 1)


// Note: In other Neptune files, kMaxHIDReportSize was defined as 64. But Ferg & Keithen were unable to
// find that value in the USB HID 1.1 specs. Brent had previously changed it to 256 in the OS 9 HID Driver
// to  allow for reports spanning multiple packets. 256 may be no more a hard and fast limit, but it's 
// working for now in OS 9.
#define kMaxHIDReportSize 256           // Max packet size = 8 for low speed & 64 for high speed.
#define kHIDDriverRetryCount    3


class DWXBoxHIDDriver : public IOHIDDevice
{
    OSDeclareDefaultStructors(DWXBoxHIDDriver)

    IOUSBInterface *    _interface;
    IOUSBDevice *       _device;
    IOUSBPipe *         _interruptPipe;
    UInt32          _maxReportSize;
    IOBufferMemoryDescriptor *  _buffer;
    IOUSBCompletion     _completion;
    UInt32          _retryCount;
    thread_call_t       _deviceDeadCheckThread;
    thread_call_t       _clearFeatureEndpointHaltThread;
    bool            _deviceDeadThreadActive;
    bool            _deviceIsDead;
    bool            _deviceHasBeenDisconnected;
    bool            _needToClose;
    UInt32          _outstandingIO;
    IOCommandGate *     _gate;
    IOUSBPipe *         _interruptOutPipe;
    UInt32          _maxOutReportSize;
    IOBufferMemoryDescriptor *  _outBuffer;
    UInt32          _deviceUsage;
    UInt32          _deviceUsagePage;

    struct ExpansionData 
    { 
    };
    ExpansionData *_expansionData;
    static void         InterruptReadHandlerEntry(OSObject *target, void *param, IOReturn status, UInt32 bufferSizeRemaining);
    void            InterruptReadHandler(IOReturn status, UInt32 bufferSizeRemaining);

    static void         CheckForDeadDeviceEntry(OSObject *target);
    void            CheckForDeadDevice();
    
    static void         ClearFeatureEndpointHaltEntry(OSObject *target);
    void            ClearFeatureEndpointHalt(void);

    virtual void processPacket(void *data, UInt32 size);

    virtual void free();

    static IOReturn ChangeOutstandingIO(OSObject *target, void *arg0, void *arg1, void *arg2, void *arg3);

public:
    // IOService methods
    virtual bool    init(OSDictionary *properties);
    virtual bool    start(IOService * provider);
    virtual bool    didTerminate( IOService * provider, IOOptionBits options, bool * defer );
    virtual bool    willTerminate( IOService * provider, IOOptionBits options );

    // IOHIDDevice methods
    virtual bool    handleStart(IOService * provider);
    virtual void    handleStop(IOService *  provider);

    virtual IOReturn newReportDescriptor(
                        IOMemoryDescriptor ** descriptor ) const;
                        
    virtual OSString * newTransportString() const;
    virtual OSNumber * newPrimaryUsageNumber() const;
    virtual OSNumber * newPrimaryUsagePageNumber() const;

    virtual OSNumber * newVendorIDNumber() const;

    virtual OSNumber * newProductIDNumber() const;

    virtual OSNumber * newVersionNumber() const;

    virtual OSString * newManufacturerString() const;

    virtual OSString * newProductString() const;

    virtual OSString * newSerialNumberString() const;

    virtual OSNumber * newLocationIDNumber() const;

    virtual IOReturn    getReport( IOMemoryDescriptor * report,
                                IOHIDReportType      reportType,
                                IOOptionBits         options = 0 );
                                
    virtual IOReturn    setReport( IOMemoryDescriptor * report,
                                IOHIDReportType      reportType,
                                IOOptionBits         options = 0 );
            
    virtual IOReturn    message( UInt32 type, IOService * provider,  void * argument = 0 );

    // HID driver methods
    virtual OSString * newIndexedString(UInt8 index) const;

    virtual UInt32 getMaxReportSize();

    virtual void    DecrementOutstandingIO(void);
    virtual void    IncrementOutstandingIO(void);
    virtual IOReturn    StartFinalProcessing();
    virtual IOReturn    SetIdleMillisecs(UInt16 msecs);
    
    // new stuff
    
    // driver or subclasses can change the format of the report here
    // for example, to reverse the Y axis values
    virtual void manipulateReport(IOBufferMemoryDescriptor *report);
    
private:    // Should these be protected or virtual?
    IOReturn GetHIDDescriptor(UInt8 inDescriptorType, UInt8 inDescriptorIndex, UInt8 *vOutBuf, UInt32 *vOutSize);
    IOReturn GetReport(UInt8 inReportType, UInt8 inReportID, UInt8 *vInBuf, UInt32 *vInSize);
    IOReturn SetReport(UInt8 outReportType, UInt8 outReportID, UInt8 *vOutBuf, UInt32 vOutSize);
    IOReturn GetIndexedString(UInt8 index, UInt8 *vOutBuf, UInt32 *vOutSize, UInt16 lang = 0x409) const;

#if ENABLE_HIDREPORT_LOGGING
    void LogBufferReport(char *report, UInt32 len);
    void LogMemReport(IOMemoryDescriptor * reportBuffer);
    char GetHexChar(char hexChar);
#endif

public:
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver,  0);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver,  1);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver,  2);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver,  3);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver,  4);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver,  5);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver,  6);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver,  7);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver,  8);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver,  9);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver, 10);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver, 11);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver, 12);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver, 13);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver, 14);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver, 15);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver, 16);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver, 17);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver, 18);
    OSMetaClassDeclareReservedUnused(DWXBoxHIDDriver, 19);
};

#endif  // IOUSBHIDDRIVER_H
