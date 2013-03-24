//
//  mapViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/24/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface mapViewController : UIViewController
@property (nonatomic) CLLocationCoordinate2D restaurantCoordinates;
@property (nonatomic, strong) NSString *markerTitle;
@property (nonatomic, strong) NSString *markerSnippet;
@end
