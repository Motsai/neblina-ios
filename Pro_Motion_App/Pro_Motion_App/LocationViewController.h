//
//  LocationViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 16/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "APLGraphView.h"
//#import "Pro_Motion_App-Swift.h"
#import "DataSimulator.h"
#import "CorePlot-CocoaTouch.h"

@import Charts;




@interface LocationViewController : UIViewController <DataSimulatorDelegate, CPTPlotDataSource>

@property(nonatomic, retain) IBOutlet UIView *walkingRunningMan_view;
@property(nonatomic, retain) IBOutlet UIView *walkingDirection_view;
@property(nonatomic, retain) IBOutlet UIView *walkingPath_view;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;

@property(nonatomic, retain) IBOutlet UIButton *clear_btn;
@property (weak, nonatomic) IBOutlet UIImageView *img_RunningMan;
@property (weak, nonatomic) IBOutlet LineChartView *chartWalking;

@property(nonatomic, retain) IBOutlet UILabel *steps_lbl;
@property(nonatomic, retain) IBOutlet UILabel *cadense_lbl;
@property(nonatomic, retain) IBOutlet UILabel *headingAngle_lbl;
@property (weak, nonatomic) IBOutlet UIButton *btnStartStopLog;
- (IBAction)start_stop_logging:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imgCompass;
- (IBAction)onClear:(UIButton *)sender;

@end
