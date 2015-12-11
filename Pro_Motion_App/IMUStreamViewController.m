//
//  IMUStreamViewController.m
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 04/12/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import "IMUStreamViewController.h"
#import "neblina.h"
#import "FusionEngineDataTypes.h"
#import "Pro_Motion_App-Swift.h"

@implementation IMUStreamViewController
{
    //   BOOL start_flag;
    
    NSUInteger length;
    NSUInteger count;
    NSUInteger deactivate_var;
    NSData *fileData;
    NSTimer* timer;
    
}
@synthesize string_value;


-(void)readBinaryFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"wheel_test2fixed" ofType:@"bin"];//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    length = [fileData length];
    NSLog(@"Length = %lu", (unsigned long)length);
    deactivate_var = length/20;
    float timeInterval = 0.04;
    count=0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
}


-(void)timerFireMethod
{
    NSLog(@"Count = %lu = %lu", (unsigned long)count, deactivate_var);
    
    Byte single_packet1 [20];
    int16_t orient_x,orient_y,orient_z,accel_x,accel_y,accel_z;
    
    int8_t nCmd;
    [fileData getBytes:&nCmd range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))+3,1)];
    
    // checking for MAG packe
    if(nCmd == 12)
    {
        
        [fileData getBytes:single_packet1 range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),20)];
        [fileData getBytes:&orient_x range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))+8,2)];
        [fileData getBytes:&orient_y range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))+10,2)];
        [fileData getBytes:&orient_z range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))+12,2)];
        [fileData getBytes:&accel_x range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))+14,2)];
        [fileData getBytes:&accel_y range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))+16,2)];
        [fileData getBytes:&accel_z range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))+18,2)];
        
        orient_x = (int16_t)CFSwapInt16HostToLittle(orient_x);
        orient_y = (int16_t)CFSwapInt16HostToLittle(orient_y);
        orient_z = (int16_t)CFSwapInt16HostToLittle(orient_z);
        
        accel_x = (int16_t)CFSwapInt16HostToLittle(accel_x);
        accel_y = (int16_t)CFSwapInt16HostToLittle(accel_y);
        accel_z = (int16_t)CFSwapInt16HostToLittle(accel_z);
        
        NSLog(@"Accel is = %d, %d, %d", accel_x,accel_y,accel_z);
        NSLog(@"Mag is = %d, %d, %d", orient_x,orient_y,orient_z);
        
        int scalefactor = 200;
        orient_x = orient_x/scalefactor;
        orient_y = orient_y/scalefactor;
        orient_z = orient_z/scalefactor;
        
        accel_x = accel_x/scalefactor;
        accel_y = accel_y/scalefactor;
        accel_z = accel_z/scalefactor;
        
        
        //NSLog(@"Scaled down Accel is = %d, %d, %d", accel_x,accel_y,accel_z);
        //NSLog(@"Scaled down Mag is = %d, %d, %d", orient_x,orient_y,orient_z);
        // update the accel graph
        [self.accel_view addX:accel_x y:accel_y z:accel_z];
        
        //update the gyro graph
        [self.gyro_view addX:orient_x y:orient_y z:orient_z];
    }
    else
    {
        NSLog(@"Not a MAG packet. Packet number is %lu", (unsigned long)count);
    }
    
    
    if (count == deactivate_var)
    {
        [timer invalidate];
    }
    
    count ++;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.accel_view.clipsToBounds = YES;
    self.gyro_view.clipsToBounds = YES;

    [self readBinaryFile];
    
    
   // NSLog(@"Data = %@", string_value);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
