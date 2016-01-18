//
//  ViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 23/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (nonatomic, retain) IBOutlet UIBarButtonItem *slider_button;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *setting_button;
- (IBAction)changeSimulatorFile:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lbl_SimFile;

@end

