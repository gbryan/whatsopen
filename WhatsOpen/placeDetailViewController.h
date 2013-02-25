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

@interface placeDetailViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, strong) NSString *deviceLat;
@property (nonatomic, strong) NSString *deviceLng;
@property (nonatomic, strong) restaurant *restaurantObject;
/*
@property (nonatomic, strong) NSString *proximity;
@property (nonatomic, strong) NSString *placeReference;
@property (nonatomic, strong) NSString *provider;
@property (nonatomic, strong) NSNumber *placeRating;
@property (nonatomic, strong) NSString *placeLat;
@property (nonatomic, strong) NSString *placeLng;
 */
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIWebView *googleMap;
@property (weak, nonatomic) IBOutlet UIButton *viewDirections;
- (IBAction)viewDirections:(id)sender;

@end