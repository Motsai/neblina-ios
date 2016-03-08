//
//  DebugConsoleViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 24/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DataSimulator.h"
#import <MessageUI/MessageUI.h>

// This should also implement the neblina delegate protocol.

@interface DebugConsoleViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DataSimulatorDelegate, MFMailComposeViewControllerDelegate>
{
//    char *fileBytes;
    BOOL start_flag;

    NSUInteger length;
    NSUInteger index;
    NSUInteger count;
    NSUInteger deactivate_var;
    
    NSData *fileData;
    NSData *single_packet;
    NSMutableData *mutable_packet_Data1;
    
    NSString *appFile_path;
    NSData *logger_file_Data;
    NSUInteger inserted_index;
    
}
- (IBAction)sendLogfile:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail;

@property (strong, nonatomic) CBPeripheral *Peripheral;
@property (strong, nonatomic) NSTimer *timer;
@property(nonatomic, retain)IBOutlet UITableView *logger_tbl;
@property (weak, nonatomic) IBOutlet UIButton *OptionToggled;

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
- (IBAction)btnSwitched:(id)sender;

@property(nonatomic, retain)IBOutlet UIView *switch_view;

@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_9axis;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_quaternion;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_euler;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_external;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_pedometer;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_traj_record;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_traj_distance;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_magnetometer;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_motindata;
@property (weak, nonatomic) IBOutlet UIButton *btn_9_Axis;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_record;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_heading;
@property (weak, nonatomic) IBOutlet UIButton *btn_Pedometer;
@property (weak, nonatomic) IBOutlet UIButton *btn_Traj_distance;
@property (weak, nonatomic) IBOutlet UIButton *btn_Magnetometer;
@property (weak, nonatomic) IBOutlet UIButton *btn_Motion;
@property (weak, nonatomic) IBOutlet UIButton *btn_Record;
@property (weak, nonatomic) IBOutlet UIButton *btn_Heading;

@property (weak, nonatomic) IBOutlet UIButton *btn_Quaternion;
@property (weak, nonatomic) IBOutlet UIButton *btn_Trajectory;

@property (weak, nonatomic) IBOutlet UIButton *btn_EulerAngles;

@property (weak, nonatomic) IBOutlet UIButton *btn_external_force;

@property(nonatomic, retain)IBOutlet UIButton *logging_btn;
@property(nonatomic, retain)IBOutlet UIButton *connect_btn;


@end
