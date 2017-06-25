//
//  Battery.m
//  OpenSource
//
//  Created by Steven Dourmashkin on 9/18/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import "Battery.h"

@interface Battery ()

@end

// CONSTANTS:

float totalmAh = 0.060;
float voltageRatio = 0.217; //0.175;
float criticalBatteryLevel = 0.1;


@implementation Battery

-(id)init
{
    if(self = [super init])
    {
    }
    return self;
}

-(void)updateBatteryGivenReading:(uint8_t)adcReading
{
    
    // get battery level for adc reading
    float batteryLevelReading = [self batteryRemainingForADCReading:adcReading];
    
    // get the ring's previous battery level
    
    float batteryLevelFloat = [self.batteryLevel floatValue];
    
    // perform low pass filter effect
    float scaleFactor = 0.9; // between 0-1, how much old battery level reading should scale to new one
    batteryLevelFloat = batteryLevelFloat + (batteryLevelReading-batteryLevelFloat)*scaleFactor;
    
    // assign battery level
    self.batteryLevel =[NSNumber numberWithFloat:batteryLevelFloat];

}

-(float)batteryRemainingForADCReading:(int)adcReading
{
    // get battery voltage corresponding to ADC raeding
    float batteryVoltage = [self batteryVoltageForADCReading:adcReading];
    
    // get mAh given battery voltage
    float mAh = [self mAhUsedForBatteryVoltage:batteryVoltage];
    
    // get fraction remaining
    float fraction = (totalmAh - mAh) / totalmAh;
    
    return fraction;
    
}

-(float)mAhUsedForBatteryVoltage:(float)v
{
    // (get better experimental values)
    
    if (v>4.2)
    {
        // don't extrapolate
        return 0;
    }
    else
    {
        
        // convert voltage to mah used
        float a,b,c,d;
        a = 0.18697;
        b = -2.04831;
        c = 7.36878;
        d = -8.66752;
        float mAh = a*pow(v,3) + b*pow(v,2) + c*v + d;
        
        //bound mah
        mAh = MAX(0,mAh);
        mAh = MIN(totalmAh,mAh);
        
        return mAh;
    }
    
}

//float voltageRatio = 0.185;
-(float)batteryVoltageForADCReading:(int)adcReading
{
    
    // get voltage
    float measVoltage = ((float)adcReading)/255 * 2.0 * 1.024;
    //    NSLog(@"Measured Voltage: %.3f",measVoltage);
    float voltage = measVoltage / voltageRatio;
    //    NSLog(@"Measured Supply: %.3f",voltage);
    
    // update voltage ratio
    voltageRatio = [self voltageRatioForMeasuredVoltage:voltage];
    
    // return value
    return voltage;
}

-(float)voltageRatioForMeasuredVoltage:(float)voltage
{
    return voltageRatio; // don't worry about interpolation for now
    //return 0.189 - (0.006202)*(voltage-2.9) - .01; // added constant to get closer for new resistors
}

-(BOOL)isLow
{
    // check if battery level is below critical level
    float batteryLevelFloat = [self.batteryLevel floatValue];
    if (batteryLevelFloat>0 && batteryLevelFloat<criticalBatteryLevel)
    {
        return YES;
        // NOTE: shouldn't return yes if equals zero, since it sometimes sends zero at start. besides, if it were zero, it wouldn't have connected in the first place.
    }
    return NO;
}


@end
