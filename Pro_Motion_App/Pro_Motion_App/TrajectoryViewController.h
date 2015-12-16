//
//  TrajectoryViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 16/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

@interface TrajectoryViewController : UIViewController

@property(nonatomic, retain) IBOutlet SCNView *viewpoint1;
@property(nonatomic, retain) IBOutlet SCNView *viewpoint2;

@property(nonatomic, retain) IBOutlet UIButton *recorder_btn;
@property(nonatomic, retain) IBOutlet UILabel *trajectory_distance_lbl;

@end
