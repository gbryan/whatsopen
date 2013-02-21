//
//  listViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import <FactualSDK/FactualAPI.h>
#import <FactualSDK/FactualQuery.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "keys.h"

@interface listViewController : UITableViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, FactualAPIDelegate>
{
    FactualAPIRequest* _activeRequest;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D deviceLocation;
    NSMutableArray *locationMeasurements;
    CLLocation *bestEffortAtLocation;
}
@property (nonatomic,retain)  FactualQueryResult* queryResult;
@property (nonatomic, weak) IBOutlet UINavigationItem *navBar;
@property (nonatomic, weak) IBOutlet UITableView *placeTableView;
@property (nonatomic, retain) NSMutableArray *locationMeasurements;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, strong) NSArray *queryCategories;
@end