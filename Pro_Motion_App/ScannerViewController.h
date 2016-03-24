
//
//  ScannerViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 23/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#include "ScannerDelegate.h"

@interface ScannerViewController : UIViewController <CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSString *ServiceUUIDString;

    UIButton *button;    
}

@property (nonatomic, retain) NSArray *arrayOriginal;
//@property (nonatomic, retain) NSMutableArray *arForTable;



@property (weak, nonatomic) IBOutlet UITableView *devicesTable;
@property (weak, nonatomic) IBOutlet UIButton *start_stop_scanning_lbl;

@property (strong, nonatomic) id <ScannerDelegate> delegate;
@property (strong, nonatomic) CBUUID *filterUUID;

/*!
 * List of the peripherals shown on the table view. Peripheral are added to this list when it's discovered.
 * Only peripherals with bridgeServiceUUID in the advertisement packets are being displayed.
 */
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) NSTimer *timer; /* The timer is used to periodically reload table */

- (void)timerFireMethod:(NSTimer *)timer;
- (IBAction)didCancelClicked:(id)sender; /* Cancel button has been clicked */

@property (weak, nonatomic) IBOutlet UIButton *btn_9_Axis;
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

-(void) readFilterSettings;
-(void) setBLEwithQueryStreamStatus;
- (void)didReceiveDebugData:(int32_t)type data:(const uint8_t *)data errFlag:(BOOL)errFlag;



@end
