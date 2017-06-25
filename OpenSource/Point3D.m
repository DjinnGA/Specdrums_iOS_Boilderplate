//
//  Point3D.m
//  Specdrums
//
//  Created by Steven Dourmashkin on 5/23/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import "Point3D.h"

@implementation Point3D

-(id)initWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
    self = [super init];
    if (self)
    {
        self.x = x;
        self.y = y;
        self.z = z;
    }
    return self;
}

-(id)initWithTheta:(CGFloat)theta radius:(CGFloat)radius z:(CGFloat)z
{
    self = [super init];
    if (self)
    {
        // convert to cartesiaon
        CGFloat x = radius*cos(theta);
        CGFloat y = radius*sin(theta);
        
        // assign to properties
        self.x = x;
        self.y = y;
        self.z = z;
    }
    return self;
}

-(float)getSaturation
{
    CGFloat x1,y1;
    x1 = self.x;    y1 = self.y;
    float sat = powf(powf(x1,2)+powf(y1,2),0.5);
    return sat;
}

-(float)getHue
{
    float x1 = self.x;
    float y1 = self.y;
    float theta1 = atan2f(y1, x1);
    return theta1;
}

// theta is 2d plane angle
-(float)thetaDistanceToPoint:(Point3D*)point
{
    CGFloat x1,x2,y1,y2,theta1,theta2;
    x1 = self.x;    y1 = self.y;
    x2 = point.x;   y2 = point.y;
    theta1 = atan2f(y1, x1);
    theta2 = atan2f(y2, x2);
    float dTheta = ABS(theta2-theta1);
//    NSLog(@"dtheta: %f",dTheta);
    return dTheta;
}

-(float)distanceToPoint:(Point3D*)point in3D:(BOOL)in3D
{
    CGFloat x1,x2,y1,y2;
    float dist;
    
    if (!in3D)
    {
        x1 = self.x;    y1 = self.y;
        x2 = point.x;   y2 = point.y;
        dist = powf(powf(x2-x1,2.0) + pow(y2-y1,2.0), 0.5);
    }
    else
    {
        CGFloat z1, z2;
        z1 = self.z; z2 = point.z;
        dist =  powf(powf(x2-x1,2.0) + pow(y2-y1,2.0) + pow(z2-z1,2.0), 0.5);
    }
    return dist;
    
}

@end
