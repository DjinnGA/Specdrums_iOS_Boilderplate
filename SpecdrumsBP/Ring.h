//
//  UARTPeripheral.h
//  nRF UART
//
//  Created by Ole Morten on 1/12/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Battery.h"

@protocol RingDelegate;

@interface Ring : NSObject <CBPeripheralDelegate>

// enums
typedef enum {
    RGBLEDNone = 0,
    RGBLEDBlack,
    RGBLEDRed,
    RGBLEDGreen,
    RGBLEDBlue,
    RGBLEDYellow,
    RGBLEDCyan,
    RGBLEDPurple,
    RGBLEDWhite,
} RGBLEDState;

typedef enum
{
    RING_POWER_ON = 0,
    RING_POWER_DOWN,
    RING_LOW_POWER,
    RING_WAS_CHARGED,
} RingPowerStateCmd;

typedef enum
{
    MIDI_MODE = 0,
    SPECDRUMS_MODE,
    INTERFACE_MODE,
} AppMode;

typedef enum {
    NO_TAP = 0,
    SOFT_TAP,
    NORMAL_TAP,
} TapIntensity;

@property CBPeripheral *peripheral;
@property Battery *battery;
@property id<RingDelegate> delegate;
@property BOOL wasInitialized;

+ (CBUUID*)specdrumsRingServiceUUID;
+ (CBUUID*)tapCharacteristicUUID;
+ (CBUUID*)clickCharacteristicUUID;
+ (CBUUID*)batteryCharacteristicUUID;
+ (CBUUID*)rgbLedStateCharacteristicUUID;
+ (CBUUID*)offCharacteristicUUID;
+ (CBUUID*)appModeCharacteristicUUID;
+ (CBUUID*)pitchSetCharacteristicUUID;
+ (CBUUID*)colorSetCharacteristicUUID;
+ (CBUUID*)paramsCharacteristicUUID;

- (Ring*)initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<RingDelegate>) delegate;
- (void) writeRawData:(NSData*)newData forCharacteristicUUID:(CBUUID*)UUID;
- (void) didConnect;
- (void) didDisconnect;




@end

@protocol RingDelegate

- (void) didReceiveData:(NSData*)newData fromPeripheral:(CBPeripheral*)peripheral forCharacteristic:(CBCharacteristic*)characteristic;
- (void) didReadHardwareRevisionString:(NSString*) string;
- (void) didEncounterError:(NSString*) error;
- (void) didFinishFindingCharacteristicsForRing:(Ring*)ring;


@end
