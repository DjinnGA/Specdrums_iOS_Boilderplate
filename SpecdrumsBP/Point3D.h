//
//  Point3D.h
//  Specdrums
//
//  Created by Steven Dourmashkin on 5/23/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Point3D : NSObject

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat z;

-(id)initWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
-(id)initWithTheta:(CGFloat)theta radius:(CGFloat)radius z:(CGFloat)z;
-(float)getSaturation;
-(float)distanceToPoint:(Point3D*)point in3D:(BOOL)in3D;
-(float)thetaDistanceToPoint:(Point3D*)point;
-(float)getHue;
@end
