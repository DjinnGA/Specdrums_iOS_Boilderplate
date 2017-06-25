//
//  BLEHandler.m
//  Specdrums-1-0
//
//  Created by Steven Dourmashkin on 2/15/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import "BLEHandler.h"

@interface BLEHandler(){
    CBCentralManager    *cm;
}

@end

Ring *_ringBeingConnected;


@implementation BLEHandler

// Max number of connected devices
+ (int)maxDevices {
    return 4;
}

- (id)initWithDelegate:(id<BLEHandlerDelegate>)delegate
{
    self = [super init]; // initialize superclass
    if (self)
    {
        cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.rings = [[NSMutableArray alloc]init];
        self.delegate = delegate;
    }
    return self;
}

- (NSArray*)getConnectedPeripherals
{
    NSArray *connectedPeripherals = [cm retrieveConnectedPeripheralsWithServices:@[Ring.specdrumsRingServiceUUID]];
    
    // connect each peripheral
    for (CBPeripheral *p in connectedPeripherals)
    {
        // see if a ring has it
        NSArray<CBPeripheral*> *peripherals = [self.rings valueForKey:@"peripheral"];
        if(![peripherals containsObject:p])
        {
            [self connectPeripheral:p];
        }
    }
    
    return connectedPeripherals;
}


- (void)scanForPeripherals{
    
    //Look for available Bluetooth LE devices
    
    NSLog(@"Scanning for Specdrums Ring...");
    [self.delegate beganScanning];
//    NSArray *connectedPeripherals = [cm retrieveConnectedPeripheralsWithServices:@[Ring.specdrumsRingServiceUUID]];
    [cm scanForPeripheralsWithServices:@[Ring.specdrumsRingServiceUUID]
                                   options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
    
    
}


-(Ring*)ringOfIdx:(int)idx
{
    Ring *ring;
    if ([self.rings count]>idx)
    {
        ring = [self.rings objectAtIndex:idx];;
    }
    return ring;
}

-(Ring*)ringOfPeripheral:(CBPeripheral*)peripheral
{
    return [self ringOfIdx:[self idxOfPeripheral:peripheral]];
}

- (int)idxOfPeripheral:(CBPeripheral*)peripheral
{
    NSArray<CBPeripheral*> *peripherals = [self.rings valueForKey:@"peripheral"];
    int ringIdx = (int)[peripherals indexOfObject:peripheral];
    return ringIdx;
}

-(void)removeRing:(Ring *)ring
{
    // tell ring to turn off
    RingPowerStateCmd cmd = RING_POWER_DOWN;
    uint8_t bytes[1]= {cmd};
    NSData *data= [[NSData alloc ]initWithBytes:bytes length:1];
    [self sendData:data toPeripheral:ring forCharacteristicUUID:[Ring offCharacteristicUUID]];
}

-(void)removeRingAtIdx:(int)idx
{
    // tell ring to turn off
    Ring *ring = [self ringOfIdx:idx];
    [self removeRing:ring];
}

-(void)sendRGBLEDState:(RGBLEDState)state forRing:(Ring*)ring
{
    uint8_t bytes[1]= {state};
    NSData *data= [[NSData alloc ]initWithBytes:bytes length:1];
    [self sendData:data toPeripheral:ring forCharacteristicUUID:[Ring rgbLedStateCharacteristicUUID]];

}

-(void)sendRGBLEDState:(RGBLEDState)state forRingAtIdx:(int)idx
{
    Ring *ring = [self ringOfIdx:idx];
    [self sendRGBLEDState:state forRing:ring];
}

-(void)sendAppMode:(AppMode)appMode forRingAtIdx:(int)idx
{

    Ring *ring = [self ringOfIdx:idx];
    [self sendAppMode:appMode toRing:ring];
}

+(uint8_t)minTapThresh
{
    return 0x01;
}

+(uint8_t)maxTapThresh
{
    return 0x7F;
}

+(uint8_t)minTimeLimit
{
    return 0x01;
}

+(uint8_t)maxTimeLimit
{
    return 0x7F;
}

+(BOOL)defaultHP
{
    return YES;
}

+(float)defaultTapThresh
{
    float f = (((float) 0x1E) - ((float)[BLEHandler minTapThresh])) / ( ((float)[BLEHandler maxTapThresh]) - ((float)[BLEHandler minTapThresh]) );
    return f;
}

+(float)defaultTimeLimit
{
    float f = (((float) 0x64) - ((float)[BLEHandler minTimeLimit])) / ( ((float)[BLEHandler maxTimeLimit]) - ((float)[BLEHandler minTimeLimit]) );
    return f;
}

-(uint8_t)tapThreshForFloat:(float)f


{
    float fval = f * ( ((float)[BLEHandler maxTapThresh]) - ((float)[BLEHandler minTapThresh]))  +   (float)[BLEHandler minTapThresh];
    uint8_t val = ((uint8_t) (fval));
    return val;
}

-(uint8_t)timeLimitForFloat:(float)f
{
    uint8_t val = ((uint8_t) (f * ( ((float)[BLEHandler maxTimeLimit]) - ((float)[BLEHandler minTimeLimit]))))  +   [BLEHandler minTimeLimit];
    return val;
}



-(void)sendHP:(BOOL)hpFilterOn tapThresh:(float)tapThresh timeLimit:(float)timeLimit forRingAtIdx:(int)idx
{
    Ring *ring = [self ringOfIdx:idx];
    
    [self sendHP:hpFilterOn tapThresh:tapThresh timeLimit:timeLimit toRing:ring];
    
}

-(void)sendHP:(BOOL)hpFilterOn tapThresh:(float)tapThresh timeLimit:(float)timeLimit toRing:(Ring*)ring
{
    // get threshold + limit based on min / max
    uint8_t b1 = (uint8_t)hpFilterOn;
    uint8_t b2 = [self tapThreshForFloat:tapThresh];
    uint8_t b3 = [self timeLimitForFloat:timeLimit];
    uint8_t bytes[3] = {b1, b2, b3};
    NSData *data= [[NSData alloc ]initWithBytes:bytes length:3];
    NSLog(@"Sending HP: %d, thresh: %d, limit: %d",b1,b2,b3);
    [self sendData:data toPeripheral:ring forCharacteristicUUID:[Ring paramsCharacteristicUUID]];
}

- (void)sendAppMode:(AppMode)appMode toRing:(Ring*)ring
{
    uint8_t bytes[1]= {appMode};
    NSData *data= [[NSData alloc ]initWithBytes:bytes length:1];
    [self sendData:data toPeripheral:ring forCharacteristicUUID:[Ring appModeCharacteristicUUID]];
}

-(void)setPitches:(NSMutableArray<NSNumber*>*)pitches toSample:(int)sampleIdx
{
    // pack bytes
    uint8_t sample = (uint8_t)(sampleIdx+1);
    uint8_t bytes[9]= {sample,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    for (int i = 0; i <[pitches count] && i<8;i++)
    {
        int p = [[pitches objectAtIndex:i] intValue] + 1; // add 1 when packing
        uint8_t b = (uint8_t)p;
        bytes[i+1] = b;
    }
    NSData *data= [[NSData alloc ]initWithBytes:bytes length:9];
    
    // send data to every connected peripheral
    for (Ring *ring in self.rings)
    {
        [ring writeRawData:data forCharacteristicUUID:[Ring pitchSetCharacteristicUUID]];
    }
    
    NSLog(@"sent pitch set to each ring");
}

-(void)removeSample:(int)sampleIdx
{
    // set empty pitches for this sample Int to remove it on ring
    [self setPitches:[[NSMutableArray alloc]init] toSample:sampleIdx];
}

-(uint16_t) hsvCoord2uint16:(float)x
{
    float max16Bit = 65535.0;
    x = x+1;
    uint16_t x16 =  (uint16_t) (x * (max16Bit/2));
    return x16;
    
}

-(void)setColorWithX:(float)x y:(float)y z:(float)z toSample:(int)sampleIdx
{
    // x,y, and z are in range [-1,1]...
    
    uint8_t sample = (uint8_t)(sampleIdx+1);
    
    // get uint8 values
    uint16_t x16 = [self hsvCoord2uint16:x];
    uint8_t xh = x16>>8;
    uint8_t xl = x16 & 0xff;
    
    uint16_t y16 = [self hsvCoord2uint16:y];
    uint8_t yh = y16>>8;
    uint8_t yl = y16 & 0xff;
    
    uint16_t z16 = [self hsvCoord2uint16:z];
    uint8_t zh = z16>>8;
    uint8_t zl = z16 & 0xff;
    
    // pack bytes
    uint8_t bytes[9]= {sample,xh,xl,yh,yl,zh,zl};
    NSData *data= [[NSData alloc ]initWithBytes:bytes length:9];
    
    // send data to every connected ring
    for (Ring *ring in self.rings)
    {
        [ring writeRawData:data forCharacteristicUUID:[Ring colorSetCharacteristicUUID]];
    }
    NSLog(@"sent color set to each ring");
    
}

-(void)removeAllSamples
{
    // remove all samples by sending 0 through colorset
    [self setColorWithX:0 y:0 z:0 toSample:-1];
    
}

- (Ring*)specdrumsPeripheralForCBPeripheral:(CBPeripheral*)p
{
    NSArray<CBPeripheral*> *peripherals = [self.rings valueForKey:@"peripheral"];
    int idx = (int)[peripherals indexOfObject:p];
    return [self.rings objectAtIndex:idx];
    
}

- (void)connectPeripheral:(CBPeripheral*)peripheral{
    
    //Connect Bluetooth LE device
    
    //Clear off any pending connections
    [cm cancelPeripheralConnection:peripheral];
    
    //Connect
    _ringBeingConnected=   [[Ring alloc] initWithPeripheral:peripheral delegate:self];
    [cm connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
    NSLog(@"Attempting to connect to a Specdrums Ring.");
    
    
}

#pragma mark CBCentralManagerDelegate


- (void) centralManagerDidUpdateState:(CBCentralManager*)central{
    
    if (central.state == CBCentralManagerStatePoweredOn){
        
        //respond to powered on
    }
    
    else if (central.state == CBCentralManagerStatePoweredOff){
        
        //respond to powered off
    }
    
}


- (void) centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI{
    
    NSLog(@"Did discover peripheral %@", peripheral.name);
    
    [cm stopScan];
    [self connectPeripheral:peripheral];
}


- (void) centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral{
    
    
    Ring *sp = _ringBeingConnected;
    [self.rings addObject:sp];
//    
//    for (Ring* sp in self.rings)
//    {
//        
//        if ([sp.peripheral isEqual:peripheral])
//        {
//            if(peripheral.services){
//                NSLog(@"Did connect to existing peripheral %@", peripheral.name);
//                [sp peripheral:peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
//                //[currentPeripheral peripheral:peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
//            }
//            
//            else{
                NSLog(@"Did connect peripheral %@", peripheral.name);
                [sp didConnect];
                [self.delegate finishedScanning];
                //[currentPeripheral didConnect];
                
//            }
            return;
//        }
//    }
}

- (void)didFinishFindingCharacteristicsForRing:(Ring*)ring
{
    // indicate that it finished connecting
    ring.wasInitialized = YES;
    [self.delegate numberOfRingsIsNow:(int)[self.rings count] ring:ring wasAdded:YES];
    

}


- (void) centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error{
    
    NSLog(@"Did disconnect peripheral %@", peripheral.name);
    
    //respond to disconnected
    [self peripheralDidDisconnect];
    
    for (Ring *sp in self.rings)
    {
        if ([sp.peripheral isEqual:peripheral])
        {
            [sp didDisconnect];
            
            [self.delegate numberOfRingsIsNow:((int)[self.rings count]-1) ring:sp wasAdded:NO];
            [self.rings removeObject:sp];
            return;
        }
    }
    [central connectPeripheral:peripheral options:@{}];
}

#pragma mark RingDelegate

- (void)didReadHardwareRevisionString:(NSString*)string{
    
    //Once hardware revision string is read, connection to Bluetooth is complete
    
    NSLog(@"HW Revision: %@", string);
    
}


- (void)didEncounterError:(NSString*)error{
    
    //Dismiss "scanning …" alert view if shown
    NSLog(@"-------ERROR--------: %@",error);
}

- (float) normalize:(uint16_t)c
{
    return ((float)c)/1024.0;
}

- (void)didReceiveData:(NSData*)newData fromPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic{
    
    //Received data - parse it then send it out to delegate
    const char* bytes = (const char*)[newData bytes];
    int idx = [self idxOfPeripheral:peripheral];

    CBUUID *UUID       = characteristic.UUID;
    CBUUID *tapUUID    = [Ring tapCharacteristicUUID];
    CBUUID *batUUID    = [Ring batteryCharacteristicUUID];

    if([UUID isEqual:tapUUID])
    {
        // tap data...
        // Extract bytes
        uint8_t redHigh     = bytes[0];
        uint8_t redLow      = bytes[1];
        uint8_t greenHigh   = bytes[2];
        uint8_t greenLow    = bytes[3];
        uint8_t blueHigh    = bytes[4];
        uint8_t blueLow     = bytes[5];
        uint8_t intensity   = bytes[6];
        
        // Form RGB values
        uint16_t red    = redHigh<<8 | redLow;
        uint16_t green  = greenHigh<<8 | greenLow;
        uint16_t blue   = blueHigh<<8 | blueLow;
        
        // normalize
        float r,g,b;
        r = [self normalize:red];
        g = [self normalize:green];
        b = [self normalize:blue];
        
        TapIntensity tapIntensity = (TapIntensity)intensity;
        
        [self.delegate receivedRed:r green:g blue:b tapIntensity:tapIntensity fromRingNumbered:idx];

    }
    else if ([UUID isEqual:batUUID])
    {
        // batt data...
        
        // Get ring of this peripheral
        Ring *ring = [self ringOfIdx:idx];
        
        // Get the battery data received
        uint8_t adcReading = bytes[0];
        
        // update battery estimation given reading
        [ring.battery updateBatteryGivenReading:adcReading];
        
        // check if it's low
        if ([ring.battery isLow])
        {
            
            // ring battery is critically low - shut it off to keep some power for "low power" warning on ring
            RingPowerStateCmd cmd = RING_LOW_POWER;
            uint8_t bytes[1]= {cmd};
            NSData *data= [[NSData alloc ]initWithBytes:bytes length:1];
            [self sendData:data toPeripheral:ring forCharacteristicUUID:UUID];
            
            // alert of low power
            [self.delegate receivedLowBatteryFromRingNumbered:idx];

        }
        else
        {
            // alert of new battery level
            [self.delegate receivedBatteryLevel:ring.battery.batteryLevel fromRingNumbered:idx];
        }
    }
    else
    {
        NSLog(@"Unused or unkown BLE UUID received.");
    }
}

- (void)sendData:(NSData*)newData toPeripheral:(Ring*)sp forCharacteristicUUID:(CBUUID *)UUID{
    
    //Output data to UART peripheral
    [sp writeRawData:newData forCharacteristicUUID:UUID];
    
}


- (void)peripheralDidDisconnect{
    
    //respond to device disconnecting
    
    //if we were in the process of scanning/connecting, dismiss alert
    [self didEncounterError:@"Peripheral disconnected"];
}


- (void)alertBluetoothPowerOff{
    
    //Respond to system's bluetooth disabled
    NSLog(@"You must turn on Bluetooth in Settings in order to connect to a device");
}


- (void) userCanceledPeripheralScan
{
    [cm stopScan];
    NSLog(@"stopped scanning");
    [self.delegate finishedScanning];
}

@end
