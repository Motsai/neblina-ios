//
//  TrajectoryViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 16/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "DataSimulator.h"

@interface TrajectoryViewController : UIViewController

@property(nonatomic, retain) IBOutlet SCNView *viewpoint1;
@property(nonatomic, retain) IBOutlet SCNView *viewpoint2;

@property(nonatomic, retain) IBOutlet UIButton *recorder_btn;

- (IBAction)startstopLogging:(UIButton*)button;
@property (weak, nonatomic) IBOutlet UIButton *logging_btn;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Y;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Z;
@property (weak, nonatomic) IBOutlet UILabel *lbl_X;

@property (weak, nonatomic) IBOutlet UILabel *lbl_repetition;

@end
