//
//  ScannerDelegate.h
//  Pro_Motion_App
//
//  Created by Amol Deshmukh on 23/11/15.
//  Copyright © 2015 Mindscrub Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol ScannerDelegate <NSObject>

- (void) centralManager:(CBCentralManager*) manager didPeripheralSelected:(CBPeripheral*) peripheral;

@end
