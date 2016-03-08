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
//#import "Pro_Motion_App-Swift.h"
#import "DataSimulator.h"
@import Charts;


@interface IMUStreamViewController : UIViewController <DataSimulatorDelegate, ChartViewDelegate>

@property (nonatomic, retain)NSString *string_value;

@property (weak, nonatomic) IBOutlet LineChartView *accel_view;
@property (weak, nonatomic) IBOutlet LineChartView *gyros_view;
@property (weak, nonatomic) IBOutlet UIButton *logging_btn;
- (IBAction)startstopLogging:(UIButton*)button;

@end
