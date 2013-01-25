//
//  listViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//






// when user refreshes this list by pulling down, need to re-run [locationManager startUpdatingLocation], which will update location and then call queryGooglePlaces.  Will the placesArray still be set, though???

#import "listViewController.h"
#import "placeDetailViewController.h"

@interface listViewController () {
    UIActivityIndicatorView *spinner;
    NSMutableArray *_placesArray;
    NSMutableArray *openPlaces;
}

@end

@implementation listViewController
@synthesize placeTableView;
@synthesize locationMeasurements;
@synthesize bestEffortAtLocation;
@synthesize placesArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    spinner = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 200);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    //set up device location manager and get current location
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    deviceLocation = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
    NSLog(@"%f %f", deviceLocation.latitude, deviceLocation.longitude);
}
#pragma mark user authorized/denied location services
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    //user has allowed location services in this app
    if(status == 3) {
        [self queryGooglePlaces:placesArray];
    }
    else if(status == 2){
        UIAlertView *locationDisabled = [[UIAlertView alloc]initWithTitle:@"Location Services Disabled" message:@"You have chosen to disable location services for WhatsUp, but the app cannot run without knowing your current location. Please enable location services for WhatsUp in the Settings menu, force the app to quit, and reopen it." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [locationDisabled show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // store all of the measurements, just so we can see what kind of data we might receive
    [locationMeasurements addObject:newLocation];
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        
        NSLog(@"%f, %f", deviceLocation.latitude, deviceLocation.longitude);
//        [self queryGooglePlaces:[NSArray arrayWithObjects:@"bakery", @"cafe", @"restaurant", nil]];
        [self queryGooglePlaces:placesArray];
        [locationManager stopUpdatingLocation];
        
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            
            NSLog(@"here");
            
            // we have a measurement that meets our requirements, so we can stop updating the location
            //
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return openPlaces.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row %2 == 0) {
        UIColor *lightBlue = [UIColor colorWithRed:0.5 green:0.8 blue:1.0 alpha:0.35];
        cell.backgroundColor = lightBlue;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeCell"];
    NSDictionary *place = [openPlaces objectAtIndex:indexPath.row];
    cell.textLabel.text = [place objectForKey:@"name"];
    cell.detailTextLabel.text = [place objectForKey:@"proximity"];
    return cell;
}

- (float)calculateDistanceFromDeviceLatitudeInMiles:(float)deviceLatitude deviceLongitude:(float)deviceLongitude toPlaceLatitude:(float)placeLat placeLongitude:(float)placeLng {
    
    float latDiffFloat = deviceLatitude - placeLat;
    float lngDiffFloat = deviceLongitude - placeLng;
    float latSquaredFloat = powf(latDiffFloat, 2);
    float lngSquaredFlaot = powf(lngDiffFloat, 2);
    
    float distanceInMilesFloat = sqrtf(latSquaredFloat + lngSquaredFlaot) * (10000/90) * .621371;
    float distance = [[NSString stringWithFormat:@"%.2f", distanceInMilesFloat] floatValue];
    
    return distance;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)queryGooglePlaces:(NSArray *)googleTypes
{
    NSLog(@"query executing");
//    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&types=%@&rankby=distance&sensor=true&key=%@", deviceLocation.latitude, deviceLocation.longitude, googleType, GOOGLE_API_KEY];
    
    NSString *googleTypesString = [[NSString alloc]initWithString:[googleTypes objectAtIndex:0]];
    
    //if more than 1 type is supplied
    if ([googleTypes count]>1) {
        
        googleTypesString = [googleTypesString stringByAppendingString:@"%7C"];
        
        for (int i=1; i<[googleTypes count]; i++) {

            googleTypesString = [googleTypesString stringByAppendingString:[googleTypes objectAtIndex:i]];
            
            //add | character to end of googleTypesString if this is not the last string in the googleTypes array
            if (i!=[googleTypes count]-1) {
                googleTypesString = [googleTypesString stringByAppendingString:@"%7C"];
            }
        }
    }
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&types=%@&rankby=distance&sensor=true&key=%@", deviceLocation.latitude, deviceLocation.longitude, googleTypesString, GOOGLE_API_KEY];
    
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    _placesArray = [json objectForKey:@"results"];
    openPlaces = [[NSMutableArray alloc]init];

    for (int i=0; i<_placesArray.count; i++) {
        
        NSMutableDictionary *place = [[NSMutableDictionary alloc]initWithDictionary:[_placesArray objectAtIndex:i]];
        
        //make sure opening_hours key and open_now key exist, and then only keep establishments that are currently open
        if ([place objectForKey:@"opening_hours"]) {
            if ([[place objectForKey:@"opening_hours"] objectForKey:@"open_now"]) {
                BOOL isOpen = [[[place objectForKey:@"opening_hours"] objectForKey:@"open_now"]boolValue];
                
                if (isOpen == TRUE) {
                    
                    //calculate the proximity of the mobile device to the establishment
                    float placeLat = [[[[place objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"]floatValue];
                    float placeLng = [[[[place objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"]floatValue];
                    float deviceLatitude = [[NSString stringWithFormat:@"%f", deviceLocation.latitude]floatValue];
                    float deviceLongitude = [[NSString stringWithFormat:@"%f", deviceLocation.longitude]floatValue];
                    NSString *proximity = [NSString stringWithFormat:@"Distance: %.2f miles",[self calculateDistanceFromDeviceLatitudeInMiles:deviceLatitude deviceLongitude:deviceLongitude toPlaceLatitude:placeLat placeLongitude:placeLng]];
                    [place setValue:proximity forKey:@"proximity"];
                    
                    [openPlaces addObject:place];
                }
            }
        }
        
    }//end for loop

    
    /*
     
    placesMutableArray = [[NSMutableArray alloc]initWithArray:_placesArray];
    
     for (int i=0; i<placesMutableArray.count; i++) {
        
        NSMutableDictionary *place = [[NSMutableDictionary alloc]initWithDictionary:[placesMutableArray objectAtIndex:i]];
        
        float placeLat = [[[[place objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"]floatValue];
        float placeLng = [[[[place objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"]floatValue];
        float deviceLatitude = [[NSString stringWithFormat:@"%f", deviceLocation.latitude]floatValue];
        float deviceLongitude = [[NSString stringWithFormat:@"%f", deviceLocation.longitude]floatValue];
        
        NSString *proximity = [NSString stringWithFormat:@"Distance: %.2f miles",[self calculateDistanceFromDeviceLatitudeInMiles:deviceLatitude deviceLongitude:deviceLongitude toPlaceLatitude:placeLat placeLongitude:placeLng]];
        //        NSNumber *proximity = [NSNumber numberWithFloat:[[NSString stringWithFormat:@"Distance: %.2f miles",[self calculateDistanceFromDeviceLatitudeInMiles:deviceLatitude deviceLongitude:deviceLongitude toPlaceLatitude:placeLat placeLongitude:placeLng]]floatValue]];
        
        [place setValue:proximity forKey:@"proximity"];
        
        
        //make sure opening_hours key and open_now key exist, and then only keep establishments that are currently open
        if ([place objectForKey:@"opening_hours"]) {
            if ([[place objectForKey:@"opening_hours"] objectForKey:@"open_now"]) {
                BOOL isOpen = [[[place objectForKey:@"opening_hours"] objectForKey:@"open_now"]boolValue];
                
                if (isOpen == TRUE) {
                    [place setValue:@"true" forKey:@"open_now"];
                }
                //if esablishment is closed, don't show in list
                else {
                    [place setValue:@"false" forKey:@"open_now"];
                }
                
                [placesMutableArray removeObjectAtIndex:i];
                [placesMutableArray insertObject:place atIndex:i];
            }
            //if open_now key doesn't exist, don't show establishment in list
            else {
                [place setValue:@"false" forKey:@"open_now"];
                [placesMutableArray removeObjectAtIndex:i];
                [placesMutableArray insertObject:place atIndex:i];
            }
        }
        //if opening_hours key doesn't exist, don't show establishment in list
        else {
            [place setValue:@"false" forKey:@"open_now"];
            [placesMutableArray removeObjectAtIndex:i];
            [placesMutableArray insertObject:place atIndex:i];
        }
    }
    
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"proximity" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    sortedArray = [placesMutableArray sortedArrayUsingDescriptors:sortDescriptors];
    
    //    NSLog(@"all places: %@", sortedArray);
    
     */
    
    [spinner stopAnimating];
    [[self placeTableView] reloadData];
    
}

- (void)viewDidUnload {
    [self setPlaceTableView:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailSegue"])
    {
        // Get reference to the destination view controller
        placeDetailViewController *destinationVC = [segue destinationViewController];
        
        NSIndexPath *indexPath = [self.placeTableView indexPathForSelectedRow];
        destinationVC.placeReference = [[openPlaces objectAtIndex:indexPath.row]objectForKey:@"reference"];
        destinationVC.placeRating = [[openPlaces objectAtIndex:indexPath.row]objectForKey:@"rating"];
        destinationVC.deviceLat = [NSString stringWithFormat:@"%f",deviceLocation.latitude];
        destinationVC.deviceLng = [NSString stringWithFormat:@"%f",deviceLocation.longitude];
        destinationVC.proximity = [[openPlaces objectAtIndex:indexPath.row]objectForKey:@"proximity"];
        destinationVC.placeLat = [[[[openPlaces objectAtIndex:indexPath.row]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"];
        destinationVC.placeLng = [[[[openPlaces objectAtIndex:indexPath.row]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"];
    }
}
@end
