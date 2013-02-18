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
#import "UMAAppDelegate.h"

@interface listViewController ()
{
    UIActivityIndicatorView *spinner;
    NSMutableArray *_placesArray;
    NSMutableArray *openNowPlaces;
    NSMutableArray *openLaterPlaces;
    NSString *googleTypesString;
    int pageNum;
//    FactualAPI *_apiObject;
}

@end

@implementation listViewController

@synthesize queryResult=_queryResult;
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
    
//    _apiObject = [[FactualAPI alloc] initWithAPIKey:FACTUAL_KEY secret:FACTUAL_SECRET];
    
    openNowPlaces = [[NSMutableArray alloc]init];
    openLaterPlaces = [[NSMutableArray alloc]init];
    
    spinner = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(160, 200);
    spinner.hidesWhenStopped = YES;
    spinner.color = [UIColor blackColor];
    [self.view addSubview:spinner];
    
    //set up device location manager and get current location
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    deviceLocation = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
    NSLog(@"location: %f %f", deviceLocation.latitude, deviceLocation.longitude);
    
    pageNum = 1;
    
    //add "powered by Google"
    UIImage *footerImage = [UIImage imageNamed:@"google.png"];
    UIImageView *footerImageView = [[UIImageView alloc] initWithImage:footerImage];
    footerImageView.frame = CGRectMake(10,10,1,30);
    self.tableView.tableFooterView = footerImageView;
}
#pragma mark user authorized/denied location services
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    //user has allowed location services in this app
    if(status == 3) {
//        [self queryGooglePlaces:placesArray];
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
        
        [self queryGooglePlaces:placesArray nextPageToken:nil];
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
    // section 0 is "open now," and section 1 is "open later today"
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Open Now";
            break;
        case 1:
            return @"Open Later Today";
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return openNowPlaces.count;
            break;
        case 1:
            return openLaterPlaces.count;
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row %2 == 0)
    {
        UIColor *lightBlue = [UIColor colorWithRed:0.5 green:0.8 blue:1.0 alpha:0.35];
        cell.backgroundColor = lightBlue;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeCell"];
    
    if (indexPath.section == 0)
    {
        cell.textLabel.text = [[openNowPlaces objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.detailTextLabel.text = [[openNowPlaces objectAtIndex:indexPath.row] objectForKey:@"proximity"];
    }
    else {
        cell.textLabel.text = [[openLaterPlaces objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.detailTextLabel.text = [[openLaterPlaces objectAtIndex:indexPath.row] valueForKey:@"proximity"];
    }
    return cell;
}

- (float)calculateDistanceFromDeviceLatitudeInMiles:(float)deviceLatitude deviceLongitude:(float)deviceLongitude toPlaceLatitude:(float)placeLat placeLongitude:(float)placeLng
{
    
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

-(void)queryGooglePlaces:(NSArray *)googleTypes nextPageToken:(NSString *)nextPageToken
{
    NSLog(@"query executing");
    
    googleTypesString = [[NSString alloc]initWithString:[googleTypes objectAtIndex:0]];
    
    //if more than 1 type is supplied
    if ([googleTypes count]>1)
    {
        
        googleTypesString = [googleTypesString stringByAppendingString:@"%7C"];
        
        for (int i=1; i<[googleTypes count]; i++)
        {

            googleTypesString = [googleTypesString stringByAppendingString:[googleTypes objectAtIndex:i]];
            
            //add | character to end of googleTypesString if this is not the last string in the googleTypes array
            if (i!=[googleTypes count]-1)
            {
                googleTypesString = [googleTypesString stringByAppendingString:@"%7C"];
            }
        }
    }
    
    NSString *url = [[NSString alloc]init];
    
    // CH is around here: 35.924270, -79.052075
    
    if ( [nextPageToken length] == 0)
    {
        url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&types=%@&rankby=distance&sensor=true&key=%@&hasNextPage=true&nextPage()=true", deviceLocation.latitude, deviceLocation.longitude, googleTypesString, GOOGLE_API_KEY];
    }
    else
    {
        url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&types=%@&rankby=distance&sensor=true&key=%@&hasNextPage=true&nextPage()=true&pagetoken=%@", deviceLocation.latitude, deviceLocation.longitude, googleTypesString, GOOGLE_API_KEY, nextPageToken];
    }

    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedGoogleData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedGoogleData:(NSData *)responseData
{    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    NSString *nextPageToken = [json objectForKey:@"next_page_token"];
    
    _placesArray = [json objectForKey:@"results"];
    
    /* to-do
     Fix to make it do all this:
     - check each one to see if it's open
     - if it's open, put it in a mutable array (available to all listViewController.m) and set key openWhen to "now"
     - if not open, check if it's open at all today
     - if it's open later today, put it in mutable array and set key openWhen to "today"
     - if not open later today, don't put in array at all
     - group open ones under "Open Now" heading in list view
     - group "today" ones under "Open Later Today" heading in list view
     
     get initial results and call fetchedData.
     - load results into array and display in list
     - if <5 with openWhen=="now", then do the following:
        - get next_page token and run a query to Google with that, calling fetchedPageTwo
        - load results into array and display in list
        - get next_page and run query with that, calling fetchedPageThree
        - load results into array and display in list
     */
    
    //if < 1 open place, set value for "name" key for object 0 of openNowPlaces to @"None open within %@", farthestPlaceString
    // to-do: if all places are open, there are none "open later today", so check for count of 0
    
    int numOpenNow = 0;
    NSString *farthestPlaceString = [[NSString alloc]init];
    
    for (int i=0; i<_placesArray.count; i++)
    {
        NSMutableDictionary *place = [[NSMutableDictionary alloc]initWithDictionary:[_placesArray objectAtIndex:i]];
        
        //Get distance of farthest place in the results. Since results are ordered by distance, we'll use the place in the array
        if (i == (_placesArray.count - 1) )
        {
            //calculate the proximity of the mobile device to the establishment
            float placeLat = [[[[place objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"]floatValue];
            float placeLng = [[[[place objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"]floatValue];
            float deviceLatitude = [[NSString stringWithFormat:@"%f", deviceLocation.latitude]floatValue];
            float deviceLongitude = [[NSString stringWithFormat:@"%f", deviceLocation.longitude]floatValue];
            farthestPlaceString = [NSString stringWithFormat:@"%.2f miles",[self calculateDistanceFromDeviceLatitudeInMiles:deviceLatitude deviceLongitude:deviceLongitude toPlaceLatitude:placeLat placeLongitude:placeLng]];
            NSString *proximityMessage = [NSString stringWithFormat:@"Open restaurants within %@:",farthestPlaceString];
            
            //set message to farthest place distance. Example: "Open restaurants within 1.24 miles:"
            UIFont *font = [UIFont boldSystemFontOfSize:14.0];
            CGRect frame = CGRectMake(0, 0, [proximityMessage sizeWithFont:font].width, 44);
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:frame];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = font;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.text = proximityMessage;
            self.navBar.titleView = titleLabel;
        }
        
        //calculate the proximity of the mobile device to the establishment
        float placeLat = [[[[place objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"]floatValue];
        float placeLng = [[[[place objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"]floatValue];
        float deviceLatitude = [[NSString stringWithFormat:@"%f", deviceLocation.latitude]floatValue];
        float deviceLongitude = [[NSString stringWithFormat:@"%f", deviceLocation.longitude]floatValue];
        NSString *proximity = [NSString stringWithFormat:@"Distance: %.2f miles",[self calculateDistanceFromDeviceLatitudeInMiles:deviceLatitude deviceLongitude:deviceLongitude toPlaceLatitude:placeLat placeLongitude:placeLng]];
        [place setValue:proximity forKey:@"proximity"];
        
        //make sure opening_hours key and open_now key exist, and then keep only establishments that are currently open
        if ([place objectForKey:@"opening_hours"])
        {
            if ([[place objectForKey:@"opening_hours"] objectForKey:@"open_now"])
            {
                BOOL isOpen = [[[place objectForKey:@"opening_hours"] objectForKey:@"open_now"]boolValue];
                
                if (isOpen == TRUE)
                {    
                    numOpenNow++;
                    [openNowPlaces addObject:place];
//                    NSLog(@"place object example: %@", place);
                }
                else if (isOpen == FALSE)
                {
                    
                    [self queryFactual:[place objectForKey:@"name"] searchLatitude:placeLat searchLongitude:placeLng];
                }
            } //end if opening_hours and open_now
            
            //want to sort these by proximity or soonest one to open later today???? - to-do
            else //if open_now key doesn't exist
            {
                [self queryFactual:[place objectForKey:@"name"] searchLatitude:placeLat searchLongitude:placeLng];
            }
            
        } //end if opening_hours
        
        //if there's no opening_hours key
        else
        {
            [self queryFactual:[place objectForKey:@"name"] searchLatitude:placeLat searchLongitude:placeLng];
        }
    }//end for loop
    
    //just to have 1 object in array so that it doesn't crash: to-do
//    [openLaterPlaces addObject:[NSDictionary dictionaryWithObject:@"a name" forKey:@"name"]];
    
//    NSLog(@"count of openlater = %i", [openLaterPlaces count]);
//    NSLog(@"first openLater: %@", [openLaterPlaces objectAtIndex:0]);
    
    
    [spinner stopAnimating];
    [[self placeTableView] reloadData];
    
    //to-do: compare results with FourSquare to see if I'm missing lots of restaurants
    //if <5 restaurants are currently open, get next 20 results (unless we've already fetched page 3 of 3)
    
    //to-do: change to <9
    if ( numOpenNow <1 && pageNum <3)
    {
        [spinner startAnimating];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self queryGooglePlaces:placesArray nextPageToken:nextPageToken];
        });
        
        //increment with each new set of 20 results fetched
        pageNum++;
    }
    
} //end fetchedGoogleData

- (void)queryFactual:(NSString *)restaurantFullName searchLatitude:(float)lat searchLongitude:(float)lng
{    
    FactualQuery* queryObject = [FactualQuery query];
    
    //set search radius
    CLLocationCoordinate2D geoFilterCoords = {
        lat, lng
    };
    
    //to-do: should this be 1,000?
    [queryObject setGeoFilter:geoFilterCoords
               radiusInMeters:60.0];

    NSString *queryString = restaurantFullName;
    queryString = [queryString stringByReplacingOccurrencesOfString:@"'" withString:@""];
    queryString = [queryString stringByReplacingOccurrencesOfString:@" & " withString:@" "];
    NSArray *restaurantNameExploded = [queryString componentsSeparatedByString:@" "];

    if (([restaurantNameExploded count] > 0) & !(
        [[restaurantNameExploded objectAtIndex:0] isEqualToString:@"a"] ||
        [[restaurantNameExploded objectAtIndex:0] isEqualToString:@"an"] ||
        [[restaurantNameExploded objectAtIndex:0] isEqualToString:@"the"])) {
        
        queryString = [restaurantNameExploded objectAtIndex:0];
    }
    else if ([restaurantNameExploded count] > 1) {
        queryString = [restaurantNameExploded objectAtIndex:1];
    }
    else {
        queryString = @"";
    }
    
    NSLog(@"to get from Factual: %@", restaurantFullName);
    
    //search for queryString only in the name of the restaurant
    [queryObject addRowFilter:[FactualRowFilter fieldName:@"name" search:queryString]];
    
    //query Factual
    _activeRequest = [[UMAAppDelegate getAPIObject] queryTable:@"restaurants" optionalQueryParams:queryObject withDelegate:self];
    
}

-(void) requestComplete:(FactualAPIRequest *)request receivedQueryResult:(FactualQueryResult *)queryResultObj {
    
    self.queryResult = queryResultObj;     
    
    if ((self.queryResult != nil) & ([self.queryResult.rows objectAtIndex:0] != nil)) {
        FactualRow *row = [self.queryResult.rows objectAtIndex:0];
        
        NSLog(@"from factual: %@", self.queryResult.rows);
        
        //to-do: need to check if these are open later today. For now, I'm adding all matches with Factual instead of checking hours first.
        
        float lat = [[row valueForName:@"latitude"]floatValue];
        float lng = [[row valueForName:@"longitude"]floatValue];
        
        NSString *proximity = [NSString stringWithFormat:@"Distance: %.2f miles",[self calculateDistanceFromDeviceLatitudeInMiles:deviceLocation.latitude deviceLongitude:deviceLocation.longitude toPlaceLatitude:lat placeLongitude:lng]];
        NSString *restaurantName = [row valueForName:@"name"];
        
        NSMutableDictionary *openLaterRestaurant = [[NSMutableDictionary alloc]init];
        [openLaterRestaurant setValue:proximity forKey:@"proximity"];
        [openLaterRestaurant setValue:restaurantName forKey:@"name"];
        [openLaterRestaurant setValue:[row rowId] forKey:@"id"];
    
        [openLaterPlaces addObject:openLaterRestaurant];
        
        //to-do: sort openLaterPlaces array by proximity asc
        
        [placeTableView reloadData];
    }
}

/* to-do: remove this if unnecessary
- (void)fetchedFactualData:(NSData *)responseData
{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    NSDictionary *response = [json objectForKey:@"response"];
    NSArray *results = [response objectForKey:@"data"];
    
//    NSLog(@"results:     %@",results);
//    NSString *hoursForFirstOne = [[results objectAtIndex:0] objectForKey:@"hours"];
    
//    NSLog(@"hours: %@", hoursForFirstOne);
    NSLog(@"factual match: %@", [[results objectAtIndex:0]objectForKey:@"name"]);
 
}
*/

/*
-(void) requestComplete:(FactualAPIRequest *)request receivedRawResult:(NSDictionary *)result {
    
    
//    _rawResult = result;
     for (id key in result) {
     NSLog(@"KEY: %@, VALUE: %@", key, [result objectForKey:key]);
     }
}
*/
-(void) requestComplete:(FactualAPIRequest *)request failedWithError:(NSError *)error {
    NSLog(@"FAILED with error");
}


- (void)viewDidUnload
{
    [self setPlaceTableView:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"detailSegue"])
    {
        // Get reference to the destination view controller
        placeDetailViewController *destinationVC = [segue destinationViewController];
        
        NSIndexPath *indexPath = [self.placeTableView indexPathForSelectedRow];
        NSUInteger section = [indexPath section];
        
        switch (section)
        {
            //open now
            case 0:
                destinationVC.placeReference = [[openNowPlaces objectAtIndex:indexPath.row]objectForKey:@"reference"];
                destinationVC.placeRating = [[openNowPlaces objectAtIndex:indexPath.row]objectForKey:@"rating"];
                destinationVC.deviceLat = [NSString stringWithFormat:@"%f",deviceLocation.latitude];
                destinationVC.deviceLng = [NSString stringWithFormat:@"%f",deviceLocation.longitude];
                destinationVC.proximity = [[openNowPlaces objectAtIndex:indexPath.row]objectForKey:@"proximity"];
                destinationVC.placeLat = [[[[openNowPlaces objectAtIndex:indexPath.row]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"];
                destinationVC.placeLng = [[[[openNowPlaces objectAtIndex:indexPath.row]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"];
                break;
            //open later today
            case 1:
//                destinationVC.placeReference = [[openLaterPlaces objectAtIndex:indexPath.row]objectForKey:@"reference"];
                //to-do: should I get rating from Google or Factual? Need to set up openLaterPlace mutable dict for this entire implementation and set value for it within G query if using Google
                //                destinationVC.placeRating = [[openLaterPlaces objectAtIndex:indexPath.row]objectForKey:@"rating"];
                destinationVC.deviceLat = [NSString stringWithFormat:@"%f",deviceLocation.latitude];
                destinationVC.deviceLng = [NSString stringWithFormat:@"%f",deviceLocation.longitude];
                destinationVC.proximity = [[openLaterPlaces objectAtIndex:indexPath.row]objectForKey:@"proximity"];
                destinationVC.placeLat = [[openLaterPlaces objectAtIndex:indexPath.row]objectForKey:@"latitude"];
                destinationVC.placeLng = [[openLaterPlaces objectAtIndex:indexPath.row]objectForKey:@"longitude"];
                break;
        } //end switch
    }
}
@end