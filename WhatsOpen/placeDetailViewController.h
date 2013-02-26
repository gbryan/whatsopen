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
#import "websiteViewController.h"
#import "queryController.h"

@interface placeDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *ratingIcon;
@property (weak, nonatomic) IBOutlet UIImageView *priceIcon;
@property (weak, nonatomic) IBOutlet UITextView *phoneTextView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIcon;
@property (nonatomic, strong) NSString *deviceLat;
@property (nonatomic, strong) NSString *deviceLng;
@property (nonatomic, strong) restaurant *restaurantObject;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UITextView *openNowOrLater;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;

@end