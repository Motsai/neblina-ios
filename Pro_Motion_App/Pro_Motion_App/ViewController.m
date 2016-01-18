//
//  ViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 23/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "ViewController.h"
#import "SWRevealViewController.h"
#import "DataSimulator.h"

@implementation ViewController
BOOL bFileQuat;
DataSimulator* dataSim;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup the simulator
    bFileQuat = true;
    
    dataSim = [DataSimulator sharedInstance];
    [dataSim readBinaryFile:@"QuatRotationRandom"];
    //[dataSim readBinaryFile:@"wheel_test2fixed"];
    //[dataSim readBinaryFile:@"DataLogger"];
    //[dataSim readBinaryFile:@"EulerAngleStream"];
    //[dataSim readBinaryFile:@"ForceStream"];
    
    
    
    //[dataSim pause];
   
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.slider_button setTarget: self.revealViewController];
        [self.slider_button setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeSimulatorFile:(id)sender {
    if(bFileQuat == true)
    {
        bFileQuat = false;
        _lbl_SimFile.text = @"wheel_test2fixed.bin";
        [dataSim readBinaryFile:@"wheel_test2fixed"];
    }
    else
    {
        bFileQuat = true;
        _lbl_SimFile.text = @"QuatRotationRandom.bin";
        [dataSim readBinaryFile:@"QuatRotationRandom"];
    }
}
@end
