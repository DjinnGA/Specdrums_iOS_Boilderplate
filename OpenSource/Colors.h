//
//  SpecdrumsColors.h
//  Specdrums
//
//  Created by Steven Dourmashkin on 7/1/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Point3D.h"

@interface Colors : NSObject

+(UIColor*)blueColor;
+(UIColor*)greenColor;
+(UIColor*)yellowColor;
+(UIColor*)yellowOrangeColor;
+(UIColor*)orangeColor;
+(UIColor*)orangeRedColor;
+(UIColor*)redColor;
+(UIColor*)pinkColor;
+(UIColor*)violetColor;
+(UIColor*)purpleColor;
+(UIColor*)navyColor;
+(UIColor*)blackColor;
+(UIColor*)randomSpecdrumsColor;
+(Point3D*)hsvPointForRed:(float)red green:(float)green blue:(float)blue;

@end
