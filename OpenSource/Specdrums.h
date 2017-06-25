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

@protocol SpecdrumsDelegate;

@interface Specdrums : NSObject <BLEHandlerDelegate>

@property BLEHandler *ble;
@property (nonatomic, weak) id<SpecdrumsDelegate> delegate;
-(id)initWithDelegate:(id<SpecdrumsDelegate>)delegate;
- (void) scanForRings;
- (void)stopScanningForRings;
- (void)removeRingNumbered:(int)num;

// enums
typedef enum {
    NoBlink = 0,
    BlackBlink,
    RedBlink,
    GreenBlink,
    BlueBlink,
    YellowBlink,
    CyanBlink,
    PurpleBlink,
    WhiteBlink,
} BlinkColor;

- (void)assignBlinkColor:(BlinkColor)color toRingNumbered:(int)num;


@end

// Definition of the delegate's interface
@protocol SpecdrumsDelegate <NSObject>

-(void)receivedRed:(float)red green:(float)green blue:(float)blue fromRingNumbered:(int)idx;
- (void)receivedBatteryLevel:(NSNumber*)batteryLevel fromRingNumbered:(int)idx;
- (void)receivedLowBatteryFromRingNumbered:(int)idx;

-(void)numberOfRingsIsNow:(int)num;
-(void)beganScanning;
-(void)finishedScanning;
@end
