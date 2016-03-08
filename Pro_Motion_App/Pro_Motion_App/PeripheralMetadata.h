//
//  PeripheralMetadata.h
//  Pro_Motion_App
//
//  Created by Santosh Surve on 2/18/16.
//  Copyright © 2016 Mindscrub Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralMetadata : NSObject

@property(nonatomic) int type;
@property(strong, nonatomic) NSString* keyname;
@property(strong, nonatomic) NSString* keyvalue;

@end
