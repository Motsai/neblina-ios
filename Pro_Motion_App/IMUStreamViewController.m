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
    BOOL start_flag;
    
    NSUInteger length;
    NSUInteger index;
    NSUInteger count;
    NSUInteger deactivate_var;
    
    NSData *fileData;
    NSData *single_packet;
    NSMutableData *mutable_packet_Data;
    
    NSData *logger_file_Data;
    NSTimer* timer;
    uint8_t* bytePtr;
    
}
@synthesize string_value;


-(void)readBinaryFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"wheel_test2fixed" ofType:@"bin"];//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    length = [fileData length];
    NSLog(@"Length = %lu", (unsigned long)length);
    bytePtr = (uint8_t  * )[fileData bytes];
    deactivate_var = length/20;
    float timeInterval = 0.04;
    count=0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
}

-(void)timerFireMethod
{
    NSLog(@"Count = %lu = %lu", (unsigned long)count, deactivate_var);
    
    
    single_packet= (__bridge NSData *)((__bridge void *)([NSData dataWithBytes:(void *)(bytePtr+(count*sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t))) length:20]));
    uint8_t *fileBytes = (uint8_t *)[single_packet bytes];
 
    IMU_6Axis_t* imu= (__bridge IMU_6Axis_t *)([NSData dataWithBytes:(void *)(fileBytes+(sizeof(NEB_PKTHDR)+sizeof(uint32_t))) length:12]);
    
    
    NSLog(@"Accel X is = %x", (int16_t)imu->Acc.Data[0]);
    NSLog(@"Accel Y is = %x", (int16_t)imu->Acc.Data[1]);
    NSLog(@"Accel Z is = %x", (int16_t)imu->Acc.Data[2]);
    NSLog(@"Gyro X is = %x", (int16_t)imu->Gyr.Data[0]);
    NSLog(@"Gyro Y is = %x", (int16_t)imu->Gyr.Data[1]);
    NSLog(@"Gyro Z is = %x", (int16_t)imu->Gyr.Data[2]);
    
    // update the accel graph
    [self.accel_view addX:(int16_t)imu->Acc.Data[0] y:(int16_t)imu->Acc.Data[1] z:(int16_t)imu->Acc.Data[2]];
    
    //update the gyro graph
    [self.gyro_view addX:(int16_t)imu->Gyr.Data[0] y:(int16_t)imu->Gyr.Data[1] z:(int16_t)imu->Gyr.Data[2]];   // NSLog(@"q3 = %x", (int16_t)t->q[3]);
    
    
    
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
