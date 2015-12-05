//
//  IMUStreamViewController.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 04/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
@interface IMUStreamViewController : UIViewController

@property (nonatomic, retain)IBOutlet SCNView *accelerometer_view;
@property (nonatomic, retain)IBOutlet SCNView *gyroscope_view;
@property (nonatomic, retain)NSString *string_value;

@end
