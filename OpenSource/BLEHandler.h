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
- (void)removeRing:(Ring*)ring;
-(void)sendRGBLEDState:(RGBLEDState)state forRing:(Ring*)ring;
-(void)sendRGBLEDState:(RGBLEDState)state forRingAtIdx:(int)idx;
-(void)sendAppMode:(AppMode)appMode forRingAtIdx:(int)idx;
- (void)sendAppMode:(AppMode)appMode toRing:(Ring*)ring;
-(void)sendHP:(BOOL)hpFilterOn tapThresh:(float)tapThresh timeLimit:(float)timeLimit forRingAtIdx:(int)idx;
-(void)sendHP:(BOOL)hpFilterOn tapThresh:(float)tapThresh timeLimit:(float)timeLimit toRing:(Ring*)ring;

-(void)setPitches:(NSMutableArray<NSNumber*>*)pitches toSample:(int)sampleIdx;
-(void)removeSample:(int)sampleIdx;
-(void)setColorWithX:(float)x y:(float)y z:(float)z toSample:(int)sampleIdx;
-(void)removeAllSamples;

+(BOOL)defaultHP;
+(float)defaultTapThresh;
+(float)defaultTimeLimit;

// added api's
- (NSArray*)getConnectedPeripherals;

@end

// Definition of the delegate's interface
@protocol BLEHandlerDelegate <NSObject>

- (void)numberOfRingsIsNow:(int)num ring:(Ring*)ring wasAdded:(BOOL)wasAdded;
- (void)beganScanning;
- (void)finishedScanning;
- (void)receivedRed:(float)red green:(float)green blue:(float)blue tapIntensity:(TapIntensity)tapIntensity fromRingNumbered:(int)idx;
- (void)receivedBatteryLevel:(NSNumber*)batteryLevel fromRingNumbered:(int)idx;
- (void)receivedLowBatteryFromRingNumbered:(int)idx;

@end
