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
int8_t nFileQuat;
DataSimulator* dataSim;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup the simulator
    dataSim = [DataSimulator sharedInstance];
    nFileQuat = 3;
    [self changeSimulatorFile:nil];
    //[dataSim readBinaryFile:@"PedometerPackets"];
    //[dataSim readBinaryFile:@"QuatRotationRandom"];
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
    if(nFileQuat == 1)
    {
        nFileQuat++;
        _lbl_SimFile.text = @"wheel_test2fixed.bin";
        [dataSim readBinaryFile:@"wheel_test2fixed"];
    }
    else if(nFileQuat == 2)
    {
        nFileQuat++;
        _lbl_SimFile.text = @"QuatRotationRandom.bin";
        [dataSim readBinaryFile:@"QuatRotationRandom"];
    }
    
    else
    {
        nFileQuat = 1;
        _lbl_SimFile.text = @"PedometerPackets.bin";
        [dataSim readBinaryFile:@"PedometerPackets"];
    }
    
    
}
@end
