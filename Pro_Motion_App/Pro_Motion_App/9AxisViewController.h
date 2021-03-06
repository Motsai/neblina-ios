//
//  9AxisViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 16/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "DataSimulator.h"

@interface _AxisViewController : UIViewController <DataSimulatorDelegate>
- (IBAction)startstopLogging:(UIButton*)button;
@property (weak, nonatomic) IBOutlet UIButton *logging_btn;

@property(nonatomic, retain) IBOutlet SCNView *viewpoint1;
@property(nonatomic, retain) IBOutlet SCNView *viewpoint2;

@property(nonatomic, retain)IBOutlet UIView *displayValue_view;
@property(nonatomic, retain)IBOutlet UILabel *QuaternionA_lbl;
@property(nonatomic, retain)IBOutlet UILabel *QuaternionB_lbl;
@property(nonatomic, retain)IBOutlet UILabel *QuaternionC_lbl;
@property(nonatomic, retain)IBOutlet UILabel *QuaternionD_lbl;
@property(nonatomic, retain)IBOutlet UILabel *GravityX_lbl;
@property(nonatomic, retain)IBOutlet UILabel *GravityY_lbl;
@property(nonatomic, retain)IBOutlet UILabel *GravityZ_lbl;
@property(nonatomic, retain)IBOutlet UILabel *Pitch_lbl;
@property(nonatomic, retain)IBOutlet UILabel *Yaw_lbl;
@property(nonatomic, retain)IBOutlet UILabel *Roll_lbl;

@end