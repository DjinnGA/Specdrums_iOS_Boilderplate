//
//  Specdrums.h
//  OpenSource
//
//  Created by Steven Dourmashkin on 9/18/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEHandler.h"
#import "Battery.h"
#import "Colors.h"

@protocol SpecdrumsDelegate;

@interface Specdrums : NSObject <BLEHandlerDelegate>

// class properties
@property BLEHandler *ble;
@property (nonatomic, weak) id<SpecdrumsDelegate> delegate;



// BLE connection handling methods
- (id)initWithDelegate:(id<SpecdrumsDelegate>)delegate;
- (void)scanForRings;
- (void)stopScanningForRings;
- (void)removeRingNumbered:(int)num;
- (void)removeRing:(Ring*)ring;

// ring command methods
- (void)assignBlinkColor:(RGBLEDState)color toRing:(Ring*)ring;
- (void)assignBlinkColor:(RGBLEDState)color toRingNumbered:(int)num;
- (void)assignAllAppMode:(AppMode)appMode;
- (void)assignAppMode:(AppMode)appMode toRing:(Ring*)ring;
- (BOOL)checkForConnectedRings;
- (void)assignAllRingsHP:(BOOL)hpFilterOn tapThresh:(float)tapThresh timeLimit:(float)timeLimit;
- (void)assignHP:(BOOL)hpFilterOn tapThresh:(float)tapThresh timeLimit:(float)timeLimit toRing:(Ring*)ring;

// bluetooth MIDI commands (advanced)
-(void)setPitches:(NSMutableArray<NSNumber*>*)pitches toSample:(int)sampleIdx;
-(void)removeSample:(int)sampleIdx;
-(void)setColorWithX:(float)x y:(float)y z:(float)z toSample:(int)sampleIdx;
-(void)removeAllSamples;
-(NSString*)getUniqueRingNames;


@end

// Definition of the delegate's interface
@protocol SpecdrumsDelegate <NSObject>

// BLE connection handling methods
-(void)beganScanning;
-(void)finishedScanning;
-(void)numberOfRingsIsNow:(int)num ring:(Ring*)ring wasAdded:(BOOL)wasAdded;

// BLE data receiving methods
-(void)receivedRed:(float)red green:(float)green blue:(float)blue tapIntensity:(TapIntensity)tapIntensity fromRingNumbered:(int)idx;
- (void)receivedBatteryLevel:(NSNumber*)batteryLevel fromRingNumbered:(int)idx;
- (void)receivedLowBatteryFromRingNumbered:(int)idx;




@end
