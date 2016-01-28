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
NSUInteger length;
NSString *appFile_path;
NSData *logger_file_Data;
float timeInterval = 0.04;
static NSMutableData *_mutable_packet_Data;
BOOL timer_fired;
NSFileHandle *myHandle;
NSMutableData* tempFilterData;
int nPktSize = sizeof(Fusion_DataPacket_t)+sizeof(NEB_PKTHDR);



+ (DataSimulator*)sharedInstance
{
    // 1
    static DataSimulator *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[DataSimulator alloc] init];
        _mutable_packet_Data = [[NSMutableData alloc] init];
        tempFilterData = [[NSMutableData alloc] init];
        
    });
    return _sharedInstance;
}

-(NSMutableData*) getReceivedPackets
{
    return _mutable_packet_Data;
    //return filtered_packet_Data;
}

-(void)timerFireMethod
{
 //   NSLog(@"Count = %lu = %lu", (unsigned long)count, deactivate_var);
    
    if (count == deactivate_var)
    {
        [self pause];
        return;
    }
    
   
    
    Byte single_packet1[nPktSize];
    [fileData getBytes:single_packet1 range:NSMakeRange(count*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),nPktSize)];
    
    // mutable_packet_data should only contain 400 packets. If more than 400, remove 1st packet and append at the end.
//    if (count>1500)
//    {
//        NSRange range = NSMakeRange(0, 19);
//        [_mutable_packet_Data replaceBytesInRange:range withBytes:NULL length:0];
//        [self pause];
//    }
    [_mutable_packet_Data appendData:[NSData dataWithBytes:single_packet1 length:nPktSize]];
    
    // Writing data to DataLogger File
    uint8_t *fileBytes = (uint8_t *)[single_packet bytes];
    NSData *data = [[NSData alloc] initWithBytes:fileBytes length:[single_packet length]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:appFile_path])
    {
        [[NSFileManager defaultManager] createFileAtPath:appFile_path contents:nil attributes:nil];
        [data writeToFile:appFile_path atomically:YES];
    }
    else
    {
         myHandle = [NSFileHandle fileHandleForWritingAtPath:appFile_path];
        [myHandle seekToEndOfFile];
        [myHandle writeData:data];
        //[myHandle closeFile];
    }

    
    [_delegate handleDataAndParse:[NSData dataWithBytes:single_packet1 length:nPktSize]];
    count ++;
    
}

-(BOOL) isLoggingStopped
{
    if(timer_fired)
        return FALSE;
    else
        return TRUE;
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
    
    [self createLoggerFile];
    [self reset];
    
    // Read Data File
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"bin"];//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    length = [fileData length];
    NSLog(@"Length = %lu", (unsigned long)length);
    
    deactivate_var = length/nPktSize;
    [self start];
}

-(NSData *) getPacketAt:(int) i
{
    Byte single_packet1[nPktSize];
    [_mutable_packet_Data getBytes:single_packet1 range:NSMakeRange(i*(sizeof(NEB_PKTHDR)+sizeof(Fusion_DataPacket_t)),nPktSize)];
    return [NSData dataWithBytes:single_packet1 length:nPktSize];

}

-(long) getTotalPackets
{
 
    return [_mutable_packet_Data length]/nPktSize;
    
}

-(void)reset
{
    count = 0;
    length = 0;
    deactivate_var = 0;
    [_mutable_packet_Data setLength:0];
    [self pause];
   
}

-(void)createLoggerFile
{
    // Delete/Remove already created file & write fresh data into it every time.
    appFile_path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DataLogger.bin"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:appFile_path])
    {
        [[NSFileManager defaultManager] createFileAtPath:appFile_path contents:[NSData data] attributes:nil];
    }
    

}


-(void) pause
{
    if(timer_fired)
    {
        timer_fired = FALSE;
        [timer invalidate];
    }
    
}

-(void) start
{
    if(!timer_fired)
    {
        timer_fired = TRUE;
        timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
    }
}

-(void) sendLogFile
{
    
}

-(NSString*) getLogfilePath
{
    return appFile_path;
}

// used while switching of DebugConsole
// Lets only save the last 25 packets
-(void)saveFilterdData:(NSMutableData*) filteredData
{
    int nSavePkts = 25;
    if([filteredData length] > (nSavePkts*(sizeof(Fusion_DataPacket_t)+sizeof(NEB_PKTHDR))))
    {
        NSRange range = NSMakeRange([filteredData length]-(nSavePkts*(sizeof(Fusion_DataPacket_t)+sizeof(NEB_PKTHDR))), (nSavePkts*(sizeof(Fusion_DataPacket_t)+sizeof(NEB_PKTHDR))));

        tempFilterData = [NSMutableData dataWithData:[filteredData subdataWithRange:range]];
    }
    else
    {
        tempFilterData = filteredData;
    }
    
}
-(NSMutableData *) getFilterdData
{
    return tempFilterData;
}

@end
