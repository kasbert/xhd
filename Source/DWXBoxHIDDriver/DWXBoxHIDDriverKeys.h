/*
 *  DWXBoxHIDDriverKeys.h
 *  DWXBoxHIDDriver
 *
 *  Created by Darrell Walisser on Wed May 28 2003.
 *  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
 *
 */

// -- keys for client configuration -------------------------
// ----------------------------------------------------------

#define kClientOptionKeyKey   "OptionKey"
#define kClientOptionValueKey "OptionValue"
#define kClientOptionSetElementsKey "Elements"

// -- keys for XML configuration ----------------------------
// ----------------------------------------------------------

#define kDeviceDataKey "DeviceData"

#define kKnownDevicesKey "KnownDevices"

// device types
#define kDeviceTypePadKey "Pad"   
#define kDeviceTypeIRKey  "IR"
//kDeviceTypeWheel "Wheel"
//kDeviceTypeStick "Stick"
//add more later, maybe

// top-level device properties
#define kDeviceGenericPropertiesKey   "GenericProperties"
#define kDeviceHIDReportDescriptorKey "HIDReportDescriptor"
#define kDeviceUSBStringTableKey      "USBStrings"
#define kDeviceOptionsKey             "Options"
#define kDeviceButtonMapKey           "ButtonMap"

// axes
#define kOptionInvertYAxisKey            "InvertYAxis"
#define kOptionInvertXAxisKey            "InvertXAxis"
#define kOptionInvertRyAxisKey           "InvertRyAxis"
#define kOptionInvertRxAxisKey           "InvertRxAxis"

// buttons
#define kOptionClampButtonsKey           "ClampButtons"

// triggers
#define kOptionClampLeftTriggerKey            "ClampLeftTrigger"
#define kOptionLeftTriggerIsButtonKey         "LeftTriggerIsButton"
#define kOptionLeftTriggerThresholdKey        "LeftTriggerThreshold"

#define kOptionClampRightTriggerKey           "ClampRightTrigger"
#define kOptionRightTriggerIsButtonKey        "RightTriggerIsButton"
#define kOptionRightTriggerThresholdKey "RightTriggerThreshold"

// generic device properties
#define kGenericInterfacesKey      "Interfaces"
#define kGenericEndpointsKey       "Endpoints"
#define kGenericMaxPacketSizeKey   "MaxPacketSize"
#define kGenericPollingIntervalKey "PollingInterval"
#define kGenericAttributesKey      "Attributes"

// general usage keys
#define kVendorKey  "Vendor"
#define kNameKey    "Name"
#define kTypeKey    "Type"

// ------------------------------------------------------
