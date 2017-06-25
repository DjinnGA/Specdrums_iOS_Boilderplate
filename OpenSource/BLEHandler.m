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

-(void)removeRingAtIdx:(int)idx
{
    // tell ring to turn off
    Ring *ring = [self ringOfIdx:idx];
    RingPowerStateCmd cmd = RING_POWER_DOWN;
    uint8_t bytes[1]= {cmd};
    NSData *data= [[NSData alloc ]initWithBytes:bytes length:1];
    [self sendData:data toPeripheral:ring forCharacteristicUUID:[Ring offCharacteristicUUID]];
}

-(void)sendRGBLEDState:(RGBLEDState)state forRingAtIdx:(int)idx
{
    uint8_t bytes[1]= {state};
    NSData *data= [[NSData alloc ]initWithBytes:bytes length:1];
    Ring *ring = [self ringOfIdx:idx];
    [self sendData:data toPeripheral:ring forCharacteristicUUID:[Ring rgbLedStateCharacteristicUUID]];
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
    [self.rings addObject:[[Ring alloc] initWithPeripheral:peripheral delegate:self]];
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
    
    for (Ring* sp in self.rings)
    {
        
        if ([sp.peripheral isEqual:peripheral])
        {
            if(peripheral.services){
                NSLog(@"Did connect to existing peripheral %@", peripheral.name);
                [sp peripheral:peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
                //[currentPeripheral peripheral:peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
            }
            
            else{
                NSLog(@"Did connect peripheral %@", peripheral.name);
                [sp didConnect];
                [self.delegate finishedScanning];
                //[currentPeripheral didConnect];
                
            }
            return;
        }
    }
}

- (void)didFinishFindingCharacteristics
{
    // indicate that it finished connecting
    [self.delegate numberOfRingsIsNow:(int)[self.rings count]];

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
            [self.rings removeObject:sp];
            [self.delegate numberOfRingsIsNow:(int)[self.rings count]];
            return;
        }
    }
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
        
        // Form RGB values
        uint16_t red    = redHigh<<8 | redLow;
        uint16_t green  = greenHigh<<8 | greenLow;
        uint16_t blue   = blueHigh<<8 | blueLow;
        
        // normalize
        float r,g,b;
        r = [self normalize:red];
        g = [self normalize:green];
        b = [self normalize:blue];
        
        [self.delegate receivedRed:r green:g blue:b fromRingNumbered:idx];

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
