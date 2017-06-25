//
//  BLEHandler.h
//  Specdrums-1-0
//
//  Created by Steven Dourmashkin on 2/15/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Ring.h"

@protocol BLEHandlerDelegate;

@interface BLEHandler : NSObject <RingDelegate,CBCentralManagerDelegate>


typedef enum {
    ConnectionStatusDisconnected = 0,
    ConnectionStatusScanning,
    ConnectionStatusConnected,
} ConnectionStatus;

@property (nonatomic, weak) id<BLEHandlerDelegate> delegate;
@property (nonatomic, assign) ConnectionStatus  connectionStatus;
@property (nonatomic) NSMutableArray<Ring*> *rings;

+ (int)maxDevices;
- (id)initWithDelegate:(id<BLEHandlerDelegate>)delegate;
- (void)scanForPeripherals;
- (void)userCanceledPeripheralScan;
- (void)sendData:(NSData*)newData toPeripheral:(Ring*)peripheral forCharacteristicUUID:(CBUUID *)UUID;
- (int)idxOfPeripheral:(CBPeripheral*)peripheral;
- (Ring*)ringOfIdx:(int)idx;
- (Ring*)specdrumsPeripheralForCBPeripheral:(CBPeripheral*)p;
- (void)removeRingAtIdx:(int)idx;
-(void)sendRGBLEDState:(RGBLEDState)state forRingAtIdx:(int)idx;

@end

// Definition of the delegate's interface
@protocol BLEHandlerDelegate <NSObject>

- (void)numberOfRingsIsNow:(int)num;
- (void)beganScanning;
- (void)finishedScanning;
- (void)receivedRed:(float)red green:(float)green blue:(float)blue fromRingNumbered:(int)idx;
- (void)receivedBatteryLevel:(NSNumber*)batteryLevel fromRingNumbered:(int)idx;
- (void)receivedLowBatteryFromRingNumbered:(int)idx;

@end
