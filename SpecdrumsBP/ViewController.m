//
//  ViewController.m
//  OpenSource
//
//  Created by Steven Dourmashkin on 9/17/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

BOOL isScanning;
int numRings;
RGBLEDState blinkColor;

@implementation ViewController


#pragma ViewController functions
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initialize specdrums controller
    self.specdrums = [[Specdrums alloc]initWithDelegate:self];
    
    // UI
    self.scanButton.layer.cornerRadius          = 45;
    self.disconnectButton.layer.cornerRadius    = 15;
    self.blinkColorView.layer.cornerRadius      = 15;
    self.tappedColorView.layer.cornerRadius     = 75;
    self.classifiedColorView.layer.cornerRadius = 75;
    
    // other
    blinkColor = RGBLEDBlack;
    numRings = 0;
    
    
}

-(UIColor*)colorForBlinkColor:(RGBLEDState)color
{
    switch (color)
    {
        case RGBLEDNone:
            return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
            break;
        case RGBLEDBlack:
            return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
            break;
        case RGBLEDRed:
            return [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0];
            break;
        case RGBLEDGreen:
            return [UIColor colorWithRed:0 green:1.0 blue:0 alpha:1.0];
            break;
        case RGBLEDBlue:
            return [UIColor colorWithRed:0 green:0 blue:1.0 alpha:1.0];
            break;
        case RGBLEDYellow:
            return [UIColor colorWithRed:1.0 green:1.0 blue:0 alpha:1.0];
            break;
        case RGBLEDCyan:
            return [UIColor colorWithRed:0 green:1.0 blue:1.0 alpha:1.0];
            break;
        case RGBLEDPurple:
            return [UIColor colorWithRed:1.0 green:0 blue:1.0 alpha:1.0];
            break;
        case RGBLEDWhite:
            return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            break;
        default:
            NSLog(@"unknown blink color...");
            
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)blinkColorViewTouchUpInside:(id)sender {
    // increment blink color
    blinkColor= (((int)blinkColor) % 8) + 1;
    [self.specdrums assignBlinkColor:blinkColor toRingNumbered:numRings];
    [self.blinkColorView setBackgroundColor:[self colorForBlinkColor:blinkColor]];
}

- (IBAction)scanButtonTouchUpInside:(id)sender {
    
    if (isScanning)
    {
        // stop scanning
        [self.specdrums stopScanningForRings];
    }
    else
    {
        // start scanning
        [self.specdrums scanForRings];
    }
    
}

- (IBAction)disconnectButtonTouchUpInside:(id)sender {
    
    // disconnect the ring most recently connected
    [self.specdrums removeRingNumbered:numRings];
}

# pragma SpecdrumsDelegate functions

-(void)numberOfRingsIsNow:(int)num
{
    // set label
    numRings = num;
    [self.numRingsLabel setText:[[NSNumber numberWithInt:num] stringValue]];
    
    // indicate blink color as black
    blinkColor = RGBLEDBlack;
    [self.blinkColorView setBackgroundColor:[self colorForBlinkColor:RGBLEDBlack]];
}
-(void)beganScanning
{
    isScanning = YES;
    [self.scanButton setTitle:@"stop" forState:UIControlStateNormal];
}
-(void)finishedScanning
{
    isScanning = NO;
    [self.scanButton setTitle:@"start" forState:UIControlStateNormal];
    
}
- (void)receivedRed:(float)red green:(float)green blue:(float)blue fromRingNumbered:(int)num
{
    // set tapped color
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    [self.tappedColorView setBackgroundColor:color];
    
    // indcate which ring it was
    [self.tappedRingLabel setText:[NSString stringWithFormat:@"ring %d",num]];
    
}
- (void)receivedLowBatteryFromRingNumbered:(int)idx
{
    [self.batteryLevelLabel setText:[NSString stringWithFormat:@"ring %d = LOW",idx]];
}
-(void)receivedBatteryLevel:(NSNumber *)batteryLevel fromRingNumbered:(int)idx
{
    [self.batteryLevelLabel setText:[NSString stringWithFormat:@"ring %d = %.0f%%",idx,[batteryLevel floatValue]*100]];
}



@end
