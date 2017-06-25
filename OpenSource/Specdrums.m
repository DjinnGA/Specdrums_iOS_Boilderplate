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
- (void)removeRing:(Ring *)ring
{
    [self.ble removeRing:ring];
}
- (void)assignBlinkColor:(RGBLEDState)state toRingNumbered:(int)num
{
    [self.ble sendRGBLEDState:state forRingAtIdx:(num-1)];
}

- (void)assignBlinkColor:(RGBLEDState)color toRing:(Ring*)ring;
{
    RGBLEDState state = (int)color;
    [self.ble sendRGBLEDState:state forRing:ring];
}


- (void)assignAllAppMode:(AppMode)appMode
{
    for (int i = 0; i<[self.ble.rings count];i++)
    {
        [self.ble sendAppMode:appMode forRingAtIdx:i];
    }
}

-(void)assignAllRingsHP:(BOOL)hpFilterOn tapThresh:(float)tapThresh timeLimit:(float)timeLimit
{
    for (int i = 0; i<[self.ble.rings count];i++)
    {
        [self.ble sendHP:hpFilterOn tapThresh:tapThresh timeLimit:timeLimit forRingAtIdx:i];
    }
}

-(void)assignHP:(BOOL)hpFilterOn tapThresh:(float)tapThresh timeLimit:(float)timeLimit toRing:(Ring*)ring
{
    [self.ble sendHP:hpFilterOn tapThresh:tapThresh timeLimit:timeLimit toRing:ring];
}

- (void)assignAppMode:(AppMode)appMode toRing:(Ring*)ring
{
    [self.ble sendAppMode:appMode toRing:ring];
}

-(BOOL)checkForConnectedRings
{
    NSArray *peripherals = [self.ble getConnectedPeripherals];
    return [peripherals count]>0;
}

- (Point3D*)hsvPointForRed:(float)red green:(float)green blue:(float)blue
{
    return [Colors hsvPointForRed:red green:green blue:blue];
}

-(NSString*)getUniqueRingNames
{
    // pack unique names into array
    NSMutableArray<NSString*> *names = [[NSMutableArray<NSString*> alloc]init];
    for (Ring *ring in self.ble.rings)
    {
        NSString *n = ring.peripheral.name;
        if(![names containsObject:n])
        {
            [names addObject:n];
        }
    }
    
    
    // create string from array
    NSString *namesStr = @"";
    int i = 0;
    for (NSString *n in names)
    {
        if(i>0)
        {
            namesStr = [namesStr stringByAppendingString:@", "];
        }
        namesStr = [namesStr stringByAppendingString:n];
        i++;
    }
    
    return namesStr;
}

#pragma bluetooth MIDI settings changing

-(void)setPitches:(NSMutableArray<NSNumber*>*)pitches toSample:(int)sampleIdx
{
    [self.ble setPitches:pitches toSample:sampleIdx];
}
-(void)removeSample:(int)sampleIdx
{
    [self.ble removeSample:sampleIdx];
}
-(void)setColorWithX:(float)x y:(float)y z:(float)z toSample:(int)sampleIdx
{
    [self.ble setColorWithX:x y:y z:z toSample:sampleIdx];
}
-(void)removeAllSamples
{
    [self.ble removeAllSamples];
}

#pragma BLEControllerDelegate functions
- (void)numberOfRingsIsNow:(int)num ring:(Ring *)ring wasAdded:(BOOL)wasAdded
{
    // call delegate function
    id<SpecdrumsDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(numberOfRingsIsNow:ring:wasAdded:)])
    {
        [strongDelegate numberOfRingsIsNow:num ring:ring wasAdded:wasAdded];
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
- (void)receivedRed:(float)red green:(float)green blue:(float)blue tapIntensity:(TapIntensity)tapIntensity fromRingNumbered:(int)idx
{
    id<SpecdrumsDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(receivedRed:green:blue:tapIntensity:fromRingNumbered:)])
    {
        [strongDelegate receivedRed:red green:green blue:blue tapIntensity:tapIntensity fromRingNumbered:idx];
    }
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
