//
//  placeDetail.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "restaurant.h"
#import "keys.h"
#import "locationServices.h"
#import "hoursViewController.h"
#import "queryController.h"
#import "selectProblemViewController.h"
#import "moreDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "mapViewController.h"
#import "SVWebViewController.h"

@interface placeDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *ratingIcon;
@property (weak, nonatomic) IBOutlet UIImageView *priceIcon;
@property (nonatomic, strong) NSString *deviceLat;
@property (nonatomic, strong) NSString *deviceLng;
@property (nonatomic, strong) restaurant *restaurantObject;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UITextView *openNowOrLater;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) IBOutlet UITableView *contactInfoTableView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *googleMapView;

- (IBAction)flagButtonPressed:(id)sender;


@end