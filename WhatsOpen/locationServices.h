//
//  locationServices.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/22/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UMAAppDelegate.h"

@interface locationServices : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D deviceLocation;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
-(CLLocationCoordinate2D) getCurrentLocation;

@end