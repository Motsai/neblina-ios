//
//  DataSimulator.h
//  Pro_Motion_App
//
//  Created by Santosh Surve on 1/7/16.
//  Copyright © 2016 Mindscrub Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@protocol DataSimulatorDelegate <NSObject>
-(void) handleDataAndParse:(NSData *)pktData;
@end

@interface DataSimulator : NSObject <MFMailComposeViewControllerDelegate>
{

}

-(NSMutableData*) getReceivedPackets;
@property (nonatomic,strong)id<DataSimulatorDelegate> delegate;
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


@end
