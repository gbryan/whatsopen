//
//  locationServices.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/22/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "locationServices.h"

@implementation locationServices
@synthesize locationManager;
@synthesize deviceLocation;

- (id)init
{
    NSLog(@"locationServices: init");
    
    self = [super init];
    
    if (self)
    {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return self;
}

-(void)getLocation
{
    NSLog(@"locationServices: get location called");    

    [self.locationManager startUpdatingLocation];
    
    //    UNCOMMENT THIS CODE TO TEST THE APP WITH A CHAPEL HILL, NC LOCATION
    //    self.deviceLocation = CLLocationCoordinate2DMake(35.913164,-79.055765);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray* )locations
{   
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"got a location");
    NSLog(@"intermediate: %f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    //Make sure we're using a location acquired in the last 15 seconds
    NSDate *updateDate = newLocation.timestamp;
    NSTimeInterval age = fabs([updateDate timeIntervalSinceNow]);
    NSLog(@"loc age: %f", age);
    
    if (age < 15.0)
    {        
        //Make sure acquired location meets our accuracy requirements of ~10 meters
        if(newLocation.horizontalAccuracy <= manager.desiredAccuracy)
        {
            [self.locationManager stopUpdatingLocation];
            
            NSLog(@"real lat lng: %f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
            NSLog(@"accuracy: %f", newLocation.horizontalAccuracy);
            
            self.deviceLocation = newLocation.coordinate;
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    UIAlertView *locationDisabled = [[UIAlertView alloc]initWithTitle:@"Location Services Disabled" message:@"You have chosen to disable location services for \"What's Open\", but the app cannot run without knowing your current location. Please enable location services for \"What's Open\" in the iPhone Settings -> Privacy -> Location Services and reopen the app." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusDenied:
            [locationDisabled show];
            break;
        case kCLAuthorizationStatusRestricted:
            [locationDisabled show];
            break;
        case kCLAuthorizationStatusAuthorized:
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location manager error");
}
@end
