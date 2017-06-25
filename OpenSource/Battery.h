//
//  Battery.h
//  OpenSource
//
//  Created by Steven Dourmashkin on 9/18/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Battery : NSObject

@property NSNumber *batteryLevel;

-(id)init;
-(void)updateBatteryGivenReading:(uint8_t)adcReading;
-(BOOL)isLow;
@end
