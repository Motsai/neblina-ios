//
//  DataSimulator.m
//  Pro_Motion_App
//
//  Created by Santosh Surve on 1/7/16.
//  Copyright © 2016 Mindscrub Technologies. All rights reserved.
//

#import "DataSimulator.h"
#import "neblina.h"
#import "FusionEngineDataTypes.h"
#import "Pro_Motion_App-Swift.h"


@implementation DataSimulator
NSTimer *timer;
NSUInteger count;
NSUInteger deactivate_var;

NSData *fileData;
NSData *single_packet;
NSMutableData *mutable_packet_Data;
NSUInteger length;


-(void)timerFireMethod
{
    NSLog(@"Count = %lu = %lu", (unsigned long)count, deactivate_var);
    
    if (count == deactivate_var)
    {
        [timer invalidate];
        return;
    }
    
    Byte single_packet1[20];
    [fileData getBytes:single_packet1 range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),20)];
    
    [_delegate handleDataAndParse:[NSData dataWithBytes:single_packet1 length:20]];
    count ++;
    
}


-(void)readBinaryFile:(NSString *)filename
{
    // Delete/Remove already created file & write a fresh data into it every time.
    
    
    /* Test Files
     1. QuaternionStream.bin
     2. EulerAngleStream.bin
     3. ForceStream.bin
     4. IMUStream.bin
     */
    
    [self reset];
    
    // Read Data File
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"bin"];//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    length = [fileData length];
    NSLog(@"Length = %lu", (unsigned long)length);
    
    deactivate_var = length/20;
    float timeInterval = 0.04;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
}

-(void)reset
{
    count = 0;
    length = 0;
    deactivate_var = 0;
    [mutable_packet_Data setLength:0];
    [timer invalidate];
}



@end
