//
//  SpecdrumsColors.m
//  Specdrums
//
//  Created by Steven Dourmashkin on 7/1/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import "Colors.h"

@implementation Colors

+(UIColor*)blueColor
{
    return [UIColor colorWithRed:0.000 green:.600  blue:0.831 alpha:1.0];
}
+(UIColor*)greenColor
{
    return [UIColor colorWithRed:0.514 green:0.733 blue:0.192 alpha:1.0];
}
+(UIColor*)yellowColor
{
    return [UIColor colorWithRed:0.953 green:0.914 blue:0.188 alpha:1.0];
}
+(UIColor*)yellowOrangeColor
{
    return [UIColor colorWithRed:0.988 green:0.812 blue:0.094 alpha:1.0];
}
+(UIColor*)orangeColor
{
    return [UIColor colorWithRed:0.894 green:0.471 blue:0.137 alpha:1.0];
}
+(UIColor*)orangeRedColor
{
    return [UIColor colorWithRed:0.835 green:0.231 blue:0.129 alpha:1.0];
}
+(UIColor*)redColor
{
    return [UIColor colorWithRed:0.804 green:0.039 blue:0.129 alpha:1.0];
}
+(UIColor*)pinkColor
{
    return [UIColor colorWithRed:0.800 green:0.008 blue:0.420 alpha:1.0];
}
+(UIColor*)violetColor
{
    return [UIColor colorWithRed:0.596 green:0.043 blue:0.412 alpha:1.0];
}
+(UIColor*)purpleColor
{
    return [UIColor colorWithRed:0.267 green:0.102 blue:0.400 alpha:1.0];
}
+(UIColor*)navyColor
{
    return [UIColor colorWithRed:0.114 green:0.153 blue:0.388 alpha:1.0];
}
+(UIColor*)blackColor
{
    return [UIColor colorWithRed:0.078 green:0.075 blue:0.075 alpha:1.0];
}

+(UIColor*)randomSpecdrumsColor
{
    int nColors = 12;
    NSUInteger idx = arc4random_uniform(nColors);
    
    UIColor *color;
    switch (idx)
    {
        case 0:
            color = [self blueColor];
            break;
        case 1:
            color = [self greenColor];
            break;
        case 2:
            color = [self yellowColor];
            break;
        case 3:
            color = [self yellowOrangeColor];
            break;
        case 4:
            color = [self orangeColor];
            break;
        case 5:
            color = [self orangeRedColor];
            break;
        case 6:
            color = [self redColor];
            break;
        case 7:
            color = [self pinkColor];
            break;
        case 8:
            color = [self violetColor];
            break;
        case 9:
            color = [self purpleColor];
            break;
        case 10:
            color = [self navyColor];
            break;
        case 11:
            color = [self blackColor];
            break;
        default:
            color = [self redColor];
            break;
    }
    return color;
}

-(Point3D*)hsvPointForRed:(float)red green:(float)green blue:(float)blue
{
    float cmax, cmin, delta;
    cmax = (red>green && red>blue)? red : (green>blue? green: blue );
    cmin = (red<green && red<blue)? red : (green<blue? green: blue );
    delta = cmax - cmin;
    
    CGFloat hue, sat, val;
    
    // calculate hue
    if (delta==0)
    {
        hue = 0;
    }
    else
    {
        if (cmax==red)
        {
            hue = (green-blue)/delta;
        }
        else if (cmax==green)
        {
            hue = (blue-red)/delta + 2;
        }
        else
        {
            hue = (red-green)/delta + 4;
        }
        
        hue *= M_PI/3; // radians
        
    }
    if (hue<0)
    {
        hue += 2*M_PI;
    }
    
    // calculate saturation
    if (cmax==0)
    {
        sat = 0;
    }
    else
    {
        sat = delta/cmax;
    }
    
    // calculate value
    val = cmax;
    
    // convert hsv to point
    CGFloat x, y, z;
    x = sat*cos(hue);
    y = sat*sin(hue);
    z = val;
    
    
    // return point
    return [[Point3D alloc] initWithX:x y:y z:z];
}

@end
