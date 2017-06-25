//
//  Specdrums.m
//  OpenSource
//
//  Created by Steven Dourmashkin on 9/18/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import "Specdrums.h"

@interface Specdrums ()

@end

@implementation Specdrums

-(id)initWithDelegate:(id<SpecdrumsDelegate>)delegate;
{
    if(self = [super init])
    {
        self.delegate = delegate;
        self.ble = [[BLEHandler alloc]initWithDelegate:self];
    }
    
    return self;
}

#pragma public functions
- (void) scanForRings
{
    [self.ble scanForPeripherals];
}

- (void)stopScanningForRings
{
    [self.ble userCanceledPeripheralScan];
}
- (void)removeRingNumbered:(int)num
{
    [self.ble removeRingAtIdx:(num-1)];
}
- (void)assignBlinkColor:(BlinkColor)color toRingNumbered:(int)num
{
    RGBLEDState state = (int)color;
    [self.ble sendRGBLEDState:state forRingAtIdx:(num-1)];
}

#pragma BLEControllerDelegate functions
- (void)numberOfRingsIsNow:(int)num
{
    // call delegate function
    id<SpecdrumsDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(numberOfRingsIsNow:)])
    {
        [strongDelegate numberOfRingsIsNow:num];
    }
    return;
}
- (void)beganScanning
{
    // call delegate function
    id<SpecdrumsDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(beganScanning)])
    {
        [strongDelegate beganScanning];
    }
    return;
}
- (void)finishedScanning
{
    // call delegate function
    id<SpecdrumsDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(finishedScanning)])
    {
        [strongDelegate finishedScanning];
    }
    return;
}
- (void)receivedRed:(float)red green:(float)green blue:(float)blue fromRingNumbered:(int)idx
{
    id<SpecdrumsDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(receivedRed:green:blue:fromRingNumbered:)])
    {
        [strongDelegate receivedRed:red green:green blue:blue fromRingNumbered:idx];
    }
    return;
    return;
}
- (void)receivedBatteryLevel:(NSNumber *)batteryLevel fromRingNumbered:(int)idx
{
    id<SpecdrumsDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(receivedBatteryLevel:fromRingNumbered:)])
    {
        [strongDelegate receivedBatteryLevel:batteryLevel fromRingNumbered:idx];
    }
    return;
}
- (void)receivedLowBatteryFromRingNumbered:(int)idx
{
    id<SpecdrumsDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(receivedLowBatteryFromRingNumbered:)])
    {
        [strongDelegate receivedLowBatteryFromRingNumbered:idx];
    }
    return;
}

@end
