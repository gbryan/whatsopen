//
//  locationServices.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/22/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "locationServices.h"

@implementation locationServices
{
    bool isFirstTimeLocationServicesEnabled;
}
@synthesize locationManager;

-(CLLocationCoordinate2D)getCurrentLocation
{
    //to-do: actually get device location
//    UNCOMMENT THIS CODE TO TEST THE APP WITH A CHAPEL HILL, NC LOCATION
    deviceLocation = CLLocationCoordinate2DMake(35.913164,-79.055765);
    
    return deviceLocation;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    UIAlertView *locationDisabled = [[UIAlertView alloc]initWithTitle:@"Location Services Disabled" message:@"You have chosen to disable location services for WhatsUp, but the app cannot run without knowing your current location. Please enable location services for WhatsUp in the Settings menu, force the app to quit, and reopen it." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
            isFirstTimeLocationServicesEnabled = TRUE;
            break;
        case kCLAuthorizationStatusDenied:
            [locationDisabled show];
            break;
        case kCLAuthorizationStatusRestricted:
            [locationDisabled show];
            break;
        case kCLAuthorizationStatusAuthorized:
            if (isFirstTimeLocationServicesEnabled == TRUE)
            {
                //to-do: check how this works now
//                [queryControl getRestaurants];
            }
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}
@end
