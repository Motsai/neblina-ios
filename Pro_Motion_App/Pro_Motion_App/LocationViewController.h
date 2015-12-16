//
//  LocationViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 16/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationViewController : UIViewController

@property(nonatomic, retain) IBOutlet UIView *walkingRunningMan_view;
@property(nonatomic, retain) IBOutlet UIView *walkingDirection_view;
@property(nonatomic, retain) IBOutlet UIView *walkingPath_view;

@property(nonatomic, retain) IBOutlet UIButton *clear_btn;

@property(nonatomic, retain) IBOutlet UILabel *steps_lbl;
@property(nonatomic, retain) IBOutlet UILabel *cadense_lbl;

@end
