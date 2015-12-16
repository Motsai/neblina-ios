//
//  DebugConsoleViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 24/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Pro_Motion_App-Bridging-Header.h"
#import "Pro_Motion_App-Swift.h"

// This should also implement the neblina delegate protocol.

@interface DebugConsoleViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
//    char *fileBytes;
    BOOL start_flag;

    NSUInteger length;
    NSUInteger index;
    NSUInteger count;
    NSUInteger deactivate_var;
    
    NSData *fileData;
    NSData *single_packet;
    NSMutableData *mutable_packet_Data;
    
    NSString *appFile_path;
    NSData *logger_file_Data;
    
    UISegmentedControl *last_selected_segment_controller;
}

@property (strong, nonatomic) CBPeripheral *Peripheral;
@property (strong, nonatomic) NSTimer *timer;
@property(nonatomic, retain)IBOutlet UITableView *logger_tbl;

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
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_record;
@property(nonatomic, retain)IBOutlet UISegmentedControl *switch_heading;

@property(nonatomic, retain)IBOutlet UIButton *logging_btn;
@property(nonatomic, retain)IBOutlet UIButton *connect_btn;


@end
