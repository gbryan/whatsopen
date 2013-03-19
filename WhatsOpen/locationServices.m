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
    BOOL isFirstTimeLocationServicesEnabled;
}
@synthesize locationManager;
@synthesize deviceLocation;
@synthesize getLocationCalled;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        getLocationCalled = FALSE;
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return self;
}

-(void)getLocation
{
    NSLog(@"3 locationServices: get location called");
    getLocationCalled = TRUE;
    [self.locationManager startUpdatingLocation];
    
    //    UNCOMMENT THIS CODE TO TEST THE APP WITH A CHAPEL HILL, NC LOCATION
    //    self.deviceLocation = CLLocationCoordinate2DMake(35.913164,-79.055765);
    //    Belmopan, Belize
    //    self.deviceLocation = CLLocationCoordinate2DMake(17.2511,-88.7676);
    //    London, England
    //    self.deviceLocation = CLLocationCoordinate2DMake(51.516607,-0.143207);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray* )locations
{   
    CLLocation *newLocation = [locations lastObject];
    
    NSLog(@"intermediate: %f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    //Make sure we're using a location acquired in the last 5 seconds
    NSDate *updateDate = newLocation.timestamp;
    NSTimeInterval age = [updateDate timeIntervalSinceNow];
    
    if (abs(age) < 5.0)
    {        
        //Make sure acquired location meets our accuracy requirements of ~10 meters
        if(newLocation.horizontalAccuracy <= manager.desiredAccuracy)
        {
            [self.locationManager stopUpdatingLocation];
            
            NSLog(@"real lat lng: %f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
            NSLog(@"accuracy: %f", newLocation.horizontalAccuracy);
            
            //Sometimes, new location updates come in without explicity calls from getLocation, and
            //I want the location to be updated only if I explicitly call this method. Prevents unnecessary queries.
            //Also, two duplicate lat/lng come in at same time, triggering 2 queries. This prevents duplicate queries.
            if (getLocationCalled == TRUE)
            {
                getLocationCalled = FALSE;
                
                self.deviceLocation = newLocation.coordinate;
            }
        }
    }
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
    NSLog(@"location manager error");
}
@end
