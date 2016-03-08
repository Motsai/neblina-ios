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



+ (CAGradientLayer*) getbkGradient {
    
    UIColor *colorOne = [UIColor colorWithRed:(255.0/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:(0/255.0)  green:(85/255.0)  blue:(140/255.0)  alpha:0.5];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    
    return headerLayer;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CAGradientLayer* bkLayer = [ViewController getbkGradient];
    bkLayer.frame = self.view.bounds;
    [[self.view layer] insertSublayer:bkLayer atIndex:0];
    
    // Setup the simulator
    dataSim = [DataSimulator sharedInstance];
    nFileQuat = 4;
    //[self changeSimulatorFile:nil];
    
    [dataSim readBinaryFile:@"PedometerPackets"];
    //[dataSim readBinaryFile:@"QuatRotationRandom"];
    //[dataSim readBinaryFile:@"wheel_test2fixed"];
    //[dataSim readBinaryFile:@"DataLogger"];
    //[dataSim readBinaryFile:@"EulerAngleStream"];
    //[dataSim readBinaryFile:@"ForceStream"];
    
    
    
   // [dataSim pause];
   
    
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
    else if(nFileQuat == 3)
    {
        nFileQuat++;
        _lbl_SimFile.text = @"PedometerPackets.bin";
        [dataSim readBinaryFile:@"PedometerPackets"];
    }
   
    else
    {
        nFileQuat = 1;
        _lbl_SimFile.text = @"TrajectoryPackets.bin";
        [dataSim readBinaryFile:@"TrajectoryPackets"];
    }
    
}
@end
