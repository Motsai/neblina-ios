//
//  IMUStreamViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 04/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "APLGraphView.h"

@interface IMUStreamViewController : UIViewController

@property (nonatomic, retain)NSString *string_value;
@property (weak, nonatomic) IBOutlet APLGraphView *accel_view;
@property (weak, nonatomic) IBOutlet APLGraphView *gyro_view;

@end
