//
//  ViewController.h
//  OpenSource
//
//  Created by Steven Dourmashkin on 9/17/16.
//  Copyright © 2016 Specdrums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Specdrums.h"

@interface ViewController : UIViewController <SpecdrumsDelegate>

#pragma Class Properties
@property Specdrums *specdrums;

#pragma IBOutlets

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UILabel *numRingsLabel;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UIView *tappedColorView;
@property (weak, nonatomic) IBOutlet UIView *classifiedColorView;
@property (weak, nonatomic) IBOutlet UIButton *blinkColorView;
@property (weak, nonatomic) IBOutlet UILabel *tappedRingLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;


#pragma IBActions
- (IBAction)blinkColorViewTouchUpInside:(id)sender;

- (IBAction)scanButtonTouchUpInside:(id)sender;
- (IBAction)disconnectButtonTouchUpInside:(id)sender;


@end

