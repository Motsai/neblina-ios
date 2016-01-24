//
//  GeoPointCompass.h
//  GeoPointCompass
//
//  Created by Maduranga Edirisinghe on 3/27/14.
//  Copyright (c) 2014 Maduranga Edirisinghe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GeoPointCompass : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager* locationManager;

@property (nonatomic, retain) UIImageView *arrowImageView;

@property (nonatomic) CLLocationDegrees latitudeOfTargetedPoint;

@property (nonatomic) CLLocationDegrees longitudeOfTargetedPoint;

- (void)updateCompasswithDegress:(float) newDirection;


@end
