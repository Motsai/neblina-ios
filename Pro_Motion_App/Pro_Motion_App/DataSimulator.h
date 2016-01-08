//
//  DataSimulator.h
//  Pro_Motion_App
//
//  Created by Santosh Surve on 1/7/16.
//  Copyright © 2016 Mindscrub Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataSimulatorDelegate <NSObject>
-(void) handleDataAndParse:(NSData *)pktData;
@end

@interface DataSimulator : NSObject
@property (nonatomic, strong)id<DataSimulatorDelegate> delegate;
-(void)readBinaryFile:(NSString *)filename;
-(void)reset;

@end
