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

@property (nonatomic) CLLocationCoordinate2D deviceLocation;

-(void)getLocation;
@end