//
//  mapViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/24/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "mapViewController.h"

@interface mapViewController ()

@end

@implementation mapViewController
{
    GMSMapView *mapView_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.restaurantCoordinates.latitude
                                                            longitude:self.restaurantCoordinates.longitude
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    mapView_.myLocationEnabled = YES;
    GMSMarkerOptions *options = [[GMSMarkerOptions alloc] init];
    options.position = self.restaurantCoordinates;
    options.title = self.markerTitle;
    options.snippet = self.markerSnippet;
    [mapView_ addMarkerWithOptions:options];
    self.view = mapView_;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
