
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
    NSString *dfuServiceUUIDString;
    NSUInteger expanded_height;
    NSUInteger collapsed_height;
    
    NSUInteger selected_row;
    NSUInteger row_height;
    
    UIButton *button;
}
@property (strong, nonatomic) CBCentralManager *bluetoothManager;
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

@end
