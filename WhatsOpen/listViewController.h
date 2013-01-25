//
//  listViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "keys.h"

@interface listViewController : UITableViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D deviceLocation;
    NSMutableArray *locationMeasurements;
    CLLocation *bestEffortAtLocation;
}
@property (nonatomic, weak) IBOutlet UITableView *placeTableView;
@property (nonatomic, retain) NSMutableArray *locationMeasurements;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, strong) NSArray *placesArray;
@end