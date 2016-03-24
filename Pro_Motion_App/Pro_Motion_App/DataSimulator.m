//
//  DataSimulator.m
//  Pro_Motion_App
//
//  Created by Santosh Surve on 1/7/16.
//  Copyright © 2016 Mindscrub Technologies. All rights reserved.
//

#import "DataSimulator.h"


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

CBPeripheral* connPeri;

//static NSMutableArray *arForTable;



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
        
        //arForTable = [[NSMutableArray alloc] init];
      
    });
    return _sharedInstance;
}

-(void) setNeblinaperipheral:(CBPeripheral*) obj
{
    
    _neblina_dev = [[Neblina alloc] init];
    connPeri = obj;
    [_neblina_dev setPeripheral:obj];
    _neblina_dev.delegate = self;
    
    [self start];
    //return _mutable_packet_Data;
    //return filtered_packet_Data;
}

//-(NSMutableArray*) getSensorsArray
//{
//    return arForTable;
//}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"DataManager - Connected to Peripheral");
    //[peripheral discoverServices:nil];
    
    
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"DataManager - Peripheral disconnected");
}

-(void)didConnectNeblina
{
    NSLog(@"DataManager - Peripheral connected");
    // Enable the streams as per the settings
    
   dispatch_async(dispatch_get_main_queue(), ^{
       if(self.scanner)
       {
           //[self.scanner readFilterSettings];
           [self.scanner setBLEwithQueryStreamStatus];
       }
   });
    
    // Enable all streams
    //[_neblina_dev setPeripheral:connPeri];
     //_neblina_dev.delegate = self;
    
    //[self start];
    
    
//    [self.neblina_dev SendCmdQuaternionStream:1];
//    [self.neblina_dev SendCmdSixAxisIMUStream:1];
//    
//    [self.neblina_dev SendCmdEulerAngleStream:1];
//    
//    [self.neblina_dev SendCmdExternalForceStream:1];
//    
//    [self.neblina_dev SendCmdPedometerStream:1];
//    
//    [self.neblina_dev SendCmdTrajectoryRecord:1];
//    
//    [self.neblina_dev SendCmdTrajectoryInfo:1];
//    
//    [self.neblina_dev SendCmdMagStream:1];
//    
//    [self.neblina_dev SendCmdMotionStream:1];
    //    [self.neblina_dev SendCmdFlashRecord:1];
    //
    //    [self.neblina_dev SendCmdLockHeading:1];
    

    
}

- (void)didReceiveDebugData:(int32_t)type data:(const uint8_t *)data errFlag:(BOOL)errFlag
{
    _debug_flagData = data[4];
    [self.scanner didReceiveDebugData:type data:data errFlag:errFlag];
}

- (void)didReceiveFusionData:(int32_t)type data:(Fusion_DataPacket_t)data errFlag:(BOOL)errFlag
{
    
  //  NSLog(@"DM - Received Fusion data");
    
    Byte single_header[sizeof(NEB_PKTHDR)];
    single_header[0] = 0;
    single_header[1] = 0;
    single_header[2] = 0;
    single_header[3] = type;
    
    // If logging is started, then only do this, else ignore the packets
   
    if(timer_fired)
    {
    
    
        [_mutable_packet_Data appendBytes:single_header length:sizeof(NEB_PKTHDR)];
        [_mutable_packet_Data appendData:[NSData dataWithBytes:&data length:sizeof(Fusion_DataPacket_t)]];
        
        // Writing data to DataLogger File
        
        NSData *data1 = [[NSData alloc] initWithBytes:single_header length:sizeof(NEB_PKTHDR)];
        NSData *data2 = [NSData dataWithBytes:&data length:sizeof(Fusion_DataPacket_t)];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:appFile_path])
        {
            [[NSFileManager defaultManager] createFileAtPath:appFile_path contents:nil attributes:nil];
            [data1 writeToFile:appFile_path atomically:YES];
            [data2 writeToFile:appFile_path atomically:YES];
            
        }
        else
        {
            myHandle = [NSFileHandle fileHandleForWritingAtPath:appFile_path];
            [myHandle seekToEndOfFile];
            [myHandle writeData:data1];
            [myHandle writeData:data2];
            
            //[myHandle closeFile];
        }
    
        if(_delegate)
        {
            [_delegate handleDataAndParsefortype:type data:[NSData dataWithBytes:&data length:(sizeof(Fusion_DataPacket_t))]];
            //[_delegate handleDataAndParse:[NSData dataWithBytes:single_packet1 length:nPktSize]];
        }
    }
     //sleep(1);
}



-(NSMutableData*) getReceivedPackets
{
    return _mutable_packet_Data;
    //return filtered_packet_Data;
}

-(void)timerFireMethod
{
    //NSLog(@"Count = %lu = %lu", (unsigned long)count, deactivate_var);
    
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
//    [self reset];
//    
//    // Read Data File
//    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"bin"];//put the path to your file here
//    fileData = [NSData dataWithContentsOfFile: path];
//    length = [fileData length];
//    NSLog(@"Length = %lu", (unsigned long)length);
//    
//    deactivate_var = length/nPktSize;
//    [self start];
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
        //[timer invalidate];
    }
    
}

-(void) start
{
    if(!timer_fired)
    {
        timer_fired = TRUE;
        //timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
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
