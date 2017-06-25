//
//  UARTPeripheral2.m
//  nRF UART
//
//  Created by Ole Morten on 1/12/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "Ring.h"
#import "CBUUID+StringExtraction.h"

@interface Ring ()
@property CBService *specdrumsRingService;
@property CBCharacteristic *tapCharacteristic;
@property CBCharacteristic *clickCharacteristic;
@property CBCharacteristic *batteryCharacteristic;
@property CBCharacteristic *rgbLedCharacteristic;
@property CBCharacteristic *offCharacteristic;


@end

@implementation Ring
@synthesize peripheral = _peripheral;
@synthesize delegate = _delegate;

@synthesize specdrumsRingService = _specdrumsRingService;
@synthesize tapCharacteristic = _tapCharacteristic;
@synthesize clickCharacteristic = _clickCharacteristic;
@synthesize rgbLedCharacteristic = _rgbLedCharacteristic;
@synthesize offCharacteristic = _offCharacteristic;

#pragma mark - UUID Retrieval


+ (CBUUID*)specdrumsRingServiceUUID{
    return [CBUUID UUIDWithString:@"ABC0"];
}


+ (CBUUID*)tapCharacteristicUUID{
    return [CBUUID UUIDWithString:@"ABC1"];
}

+ (CBUUID*)clickCharacteristicUUID{
    return [CBUUID UUIDWithString:@"ABC2"];
}

+ (CBUUID*)batteryCharacteristicUUID{
    return [CBUUID UUIDWithString:@"ABC3"];
}

+ (CBUUID*)rgbLedStateCharacteristicUUID{
    return [CBUUID UUIDWithString:@"ABC4"];
}

+ (CBUUID*)offCharacteristicUUID{
    return [CBUUID UUIDWithString:@"ABC5"];
}

#pragma mark - Utility methods

- (Ring*)initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<RingDelegate>) delegate{
    
    if (self = [super init]){
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        self.delegate = delegate;
        
        self.battery = [[Battery alloc]init];
    }
    return self;
}


- (void)didConnect{
    
    //Respond to peripheral connection
    
    if(_peripheral.services){
        printf("Skipping service discovery for %s\r\n", [_peripheral.name UTF8String]);
        [self peripheral:_peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
        return;
    }
    
    printf("Starting service discovery for %s\r\n", [_peripheral.name UTF8String]);
    
    [_peripheral discoverServices:@[self.class.specdrumsRingServiceUUID]];

    
}


- (void)didDisconnect{
    
    //Respond to peripheral disconnection
    
}

- (BOOL)compareID:(CBUUID*)firstID toID:(CBUUID*)secondID{
    
    if ([[firstID representativeString] compare:[secondID representativeString]] == NSOrderedSame) {
        return YES;
    }
    
    else
        return NO;
    
}


- (void)setupPeripheralForUse:(CBPeripheral*)peripheral{
    
    printf("Set up peripheral for use\r\n");
    
    for (CBService *s in peripheral.services) {
        
        for (CBCharacteristic *c in [s characteristics]){
            
            if ([self compareID:c.UUID toID:self.class.tapCharacteristicUUID]){
                
                printf("Found TAP characteristic\r\n");
                self.tapCharacteristic = c;
                
                [self.peripheral setNotifyValue:YES forCharacteristic:self.tapCharacteristic];
            }
            
            else if ([self compareID:c.UUID toID:self.class.clickCharacteristicUUID]){
                
                printf("Found CLICK characteristic\r\n");
                self.clickCharacteristic = c;
                [self.peripheral setNotifyValue:YES forCharacteristic:self.clickCharacteristic];
            }
            else if ([self compareID:c.UUID toID:self.class.batteryCharacteristicUUID]){
                
                printf("Found BATTERY characteristic\r\n");
                self.batteryCharacteristic = c;
                [self.peripheral setNotifyValue:YES forCharacteristic:self.batteryCharacteristic];
            }
            else if ([self compareID:c.UUID toID:self.class.rgbLedStateCharacteristicUUID]){
                
                printf("Found RGB LED characteristic\r\n");
                self.rgbLedCharacteristic = c;
                
                // write to indicate connection to specdrums app
                uint8_t bytes[1]= {0x02};
                NSData *data= [[NSData alloc ]initWithBytes:bytes length:1];
                [self writeRawData:data forCharacteristicUUID:self.class.rgbLedStateCharacteristicUUID];
                
            }
            else if ([self compareID:c.UUID toID:self.class.offCharacteristicUUID]){
                
                printf("Found OFF characteristic\r\n");
                self.offCharacteristic = c;
            }
            
        }
        
    }
    
    [_delegate didFinishFindingCharacteristics];
    
}


#pragma mark - CBPeripheral Delegate methods


- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error{
    
    //Respond to finding a new service on peripheral
    
    printf("Did Discover Services\r\n");
    
    if (!error) {
        
        for (CBService *s in [peripheral services]){
            
            if (s.characteristics){
                [self peripheral:peripheral didDiscoverCharacteristicsForService:s error:nil]; //already discovered characteristic before, DO NOT do it again
            }
            
            else if ([self compareID:s.UUID toID:self.class.specdrumsRingServiceUUID]){
                
                printf("Found correct service\r\n");
                
                self.specdrumsRingService = s;
                
                [self.peripheral discoverCharacteristics:@[self.class.tapCharacteristicUUID, self.class.clickCharacteristicUUID, self.class.batteryCharacteristicUUID, self.class.rgbLedStateCharacteristicUUID, self.class.offCharacteristicUUID] forService:self.specdrumsRingService];
            }
            
        }
    }
    
    else{
        
        printf("Error discovering services\r\n");
        
        [_delegate didEncounterError:@"Error discovering services"];
        
        return;
    }
    
}


- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error{
    
    //Respond to finding a new characteristic on service
    
    if (!error){
        
        CBService *s = [peripheral.services lastObject];
        if([self compareID:service.UUID toID:s.UUID]){
            
            //last service discovered
            printf("Found all characteristics\r\n");
            
            [self setupPeripheralForUse:peripheral];
            
        }
        
    }
    
    else{
        
        printf("Error discovering characteristics: %s\r\n", [error.description UTF8String]);
        
        [_delegate didEncounterError:@"Error discovering characteristics"];
        
        return;
    }
    
}


- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error{
    
    // NSLog(@"didUpdateValueForCharacteristic"); //testing delay
    
    //Respond to value change on peripheral
    
    if (!error){
        if (characteristic == self.tapCharacteristic || characteristic == self.clickCharacteristic || characteristic == self.batteryCharacteristic || characteristic == self.rgbLedCharacteristic || characteristic == self.offCharacteristic){
            
            //NSLog(@"Received: %@", [characteristic value]);
            
            [self.delegate didReceiveData:[characteristic value] fromPeripheral:peripheral forCharacteristic:characteristic];
        }
        
    }
    
    else{
        
        printf("Error receiving notification for characteristic %s: %s\r\n", [characteristic.description UTF8String], [error.description UTF8String]);
        
        [_delegate didEncounterError:@"Error receiving notification for characteristic"];
        
        return;
    }
    
}

- (void) writeRawData:(NSData*)newData forCharacteristicUUID:(CBUUID*)UUID
{
    
    //Send data to peripheral
    if ([self compareID:UUID toID:self.rgbLedCharacteristic.UUID])
    {
        if ((self.rgbLedCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0){
            // send rgb data
            [self.peripheral writeValue:newData forCharacteristic:self.rgbLedCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if ((self.rgbLedCharacteristic.properties & CBCharacteristicPropertyWrite) != 0){
            [self.peripheral writeValue:newData forCharacteristic:self.rgbLedCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        else{
            NSLog(@"No write property on RGBLED characteristic, %d.", (int)self.rgbLedCharacteristic.properties);
        }
    }
    else if ([self compareID:UUID toID:self.offCharacteristic.UUID])
    {
        if ((self.offCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0){
            // send rgb data
            [self.peripheral writeValue:newData forCharacteristic:self.offCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if ((self.offCharacteristic.properties & CBCharacteristicPropertyWrite) != 0){
            [self.peripheral writeValue:newData forCharacteristic:self.offCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        else{
            NSLog(@"No write property on OFF characteristic, %d.", (int)self.offCharacteristic.properties);
        }
    }
    else
    {
        NSLog(@"Invalid write characteristic");
    }
}


@end
