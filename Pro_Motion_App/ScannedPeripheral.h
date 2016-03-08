//
//  ScannedPeripheral.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 23/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ScannedPeripheral : NSObject

@property (strong, nonatomic) CBPeripheral* peripheral;
@property (assign, nonatomic) int RSSI;
@property (nonatomic) BOOL isConnected;
@property UInt64 id;

+ (ScannedPeripheral*) initWithPeripheral:(CBPeripheral*)peripheral rssi:(int)RSSI isPeripheralConnected:(BOOL)isConnected;
-(void)setDict:(NSDictionary*) advData;
-(NSDictionary*) getDict;


- (NSString*) name;

@end
