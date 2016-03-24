//
//  DataSimulator.h
//  Pro_Motion_App
//
//  Created by Santosh Surve on 1/7/16.
//  Copyright © 2016 Mindscrub Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
//#import "neblina.h"
//#import "FusionEngineDataTypes.h"
//#import "Pro_Motion_App-Bridging-Header.h"
#import "Pro_Motion_App-Swift.h"
#import "ScannerViewController.h"





@protocol DataSimulatorDelegate <NSObject>
-(void) handleDataAndParse:(NSData *)pktData;
-(void)handleDataAndParsefortype:(UInt8)type data:(NSData*)data;
@end

@interface DataSimulator : NSObject <MFMailComposeViewControllerDelegate, NeblinaDelegate, CBPeripheralDelegate>
{

    
}
@property (nonatomic,weak) ScannerViewController* scanner;

-(NSMutableData*) getReceivedPackets;
@property (nonatomic,strong)id<DataSimulatorDelegate> delegate;
@property (nonatomic,strong)Neblina * neblina_dev;
@property int8_t debug_flagData;
+ (DataSimulator*)sharedInstance;
-(void)readBinaryFile:(NSString *)filename;
-(void)reset;
-(void) pause;
-(void) start;
-(BOOL) isLoggingStopped;
-(long) getTotalPackets;
-(NSData *) getPacketAt:(int) i;
-(void) sendLogFile;
-(NSString*) getLogfilePath;
-(void)saveFilterdData:(NSMutableData*) filteredData;
-(NSMutableData *) getFilterdData;
-(void) setNeblinaperipheral:(CBPeripheral*) obj;
-(NSMutableArray*) getSensorsArray;


@end
