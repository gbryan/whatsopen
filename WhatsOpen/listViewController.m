//
//  listViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//


/*
 to-do: set color when selecting row (needs to match dark blue color scheme)
to-do: move querying into different file and set up as a singleton
 //to-do: will queries fail gracefully if there's no location found?
//to-do: what happens if there are none open now in 3 pages?
//to-do: what if there are none open later today?
//to-do: what if Google returns null result? Will it crash?
//to-do: what if factual returns null result? will it crash?
 to-do: comment out test location code
 to-do: I occasionally get a data is nil exception. Be sure to implement success and failure blocks for the API calls.
*/
 
#import "listViewController.h"
#import "placeDetailViewController.h"

@interface listViewController ()

@end

@implementation listViewController

@synthesize restaurantTableView;
@synthesize spinner;
@synthesize openNow;
@synthesize openLater;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Begin query to Google and Factual to retrieve restaurants that are open today
    queryControl = [UMAAppDelegate getQueryController];
    [queryControl getRestaurants];
    
    //set tint color of section headers
    [[UITableViewHeaderFooterView appearance]setTintColor:[UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0]];
    
    //set up pull to refresh
    UIRefreshControl *pullToRefresh = [[UIRefreshControl alloc]init];
    [pullToRefresh addTarget:self action:@selector(refreshResults) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = pullToRefresh;
    
    //display spinner to indicate to the user that the query is still running
    spinner = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(160, 200);
    spinner.hidesWhenStopped = YES;
    spinner.color = [UIColor blackColor];
    [self.view addSubview:spinner];
    
/*
    //set up device location manager and get current location
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    //Restaurant list will update only if user pulls down to refresh. I'm setting the
    //distance filter to an arbitrarily high number to ensure that didUpdateToLocation is
    //called only once each time I want to get an updated location. When it was set to none,
    //I wasn't always able to stopUpdatingLocation before the location was detected more than
    //once, triggering multiple calls to queryGooglePlaces.
    [locationManager setDistanceFilter:500.0f];
    [locationManager startUpdatingLocation];
*/    
    //add "powered by Google"
    //to-do: make this float or at least format right dimensions
    UIImage *footerImage = [UIImage imageNamed:@"google.png"];
    UIImageView *footerImageView = [[UIImageView alloc] initWithImage:footerImage];
//    footerImageView.frame = CGRectMake(10,10,1,30);
    restaurantTableView.tableFooterView = footerImageView;
}


/*
//to-do: update to non-deprecated method (only 12.4% of iPhone users have iOS < 6 as of Feb 2013)
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{    
//    NSLog(@"got a location: %f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);

    //to-do: is the location accurate? How to make it more accurate? If I set desiredAccuracy, how do I get the app to wait to perform the query until after obtaining sufficient accuracy?
    
    //ensure that this measurement isn't cached (> 2 seconds old)
    [locationMeasurements addObject:newLocation];
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 2.0) return;

    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    
    // ensure measurement is at least as accurate as previous measurement
    if (bestEffortAtLocation == nil || (bestEffortAtLocation.horizontalAccuracy >= newLocation.horizontalAccuracy))
    {
        self.bestEffortAtLocation = newLocation;
        deviceLocation = bestEffortAtLocation.coordinate;
        
//        UNCOMMENT THIS CODE TO TEST THE APP WITH A CHAPEL HILL, NC LOCATION
        deviceLocation = CLLocationCoordinate2DMake(35.913164,-79.055765);
        
        [locationManager stopUpdatingLocation];
        
        NSLog(@"location: %f,%f", deviceLocation.latitude, deviceLocation.longitude);
        
        //find restaurants based on the new location
        [self queryGooglePlaces:queryCategories nextPageToken:nil];
    }
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshResults
{
    [queryControl getRestaurants];
    
    //to-do: would it look better to wait 2-3 seconds before stopping the animation?
    [self.refreshControl endRefreshing];
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
        default:
            return nil;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return openNow.count;
            break;
        case 1:
            return openLater.count;
            break;
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row %2 == 0)
    {
        UIColor *lightBlue = [UIColor colorWithRed:0.05 green:0.1 blue:0.15 alpha:0.15];
        cell.backgroundColor = lightBlue;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeCell"];
        
    if (indexPath.section == 0)
    {
        cell.textLabel.text = [[openNow objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.detailTextLabel.text = [[openNow objectAtIndex:indexPath.row] objectForKey:@"proximity"];
    }
    else {
        cell.textLabel.text = [[openLater objectAtIndex:indexPath.row] objectForKey:@"name"];
//        cell.detailTextLabel.text = [[openLater objectAtIndex:indexPath.row] objectForKey:@"proximity"];
        NSDate *openNext = [[openLater objectAtIndex:indexPath.row] objectForKey:@"openNext"];
        NSDateFormatter *openNextFormatter = [[NSDateFormatter alloc]init];
        [openNextFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [openNextFormatter setDateFormat:@"h:mm a"];
        NSString *openNextString = [openNextFormatter stringFromDate:openNext];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Opening at %@", openNextString];
    }
    
    //remove halo effect in background color
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}



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

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"detailSegue"])
    {
        // Get reference to the destination view controller
        placeDetailViewController *destinationVC = [segue destinationViewController];
        
        NSIndexPath *indexPath = [restaurantTableView indexPathForSelectedRow];
        NSUInteger section = [indexPath section];
        
        
//        destinationVC.deviceLat = [NSString stringWithFormat:@"%f",deviceLocation.latitude];
//        destinationVC.deviceLng = [NSString stringWithFormat:@"%f",deviceLocation.longitude];
        
        switch (section)
        {
                
            //to-do: some items in openNow may have been added from Factual. Do we want to pull the info from Google or Factual for the details page? If pulling from Google, we need to somehow get the "reference" value from Google into the NSMutableDictionary containing the restaurant that we added to openNow from Factual.  We would then query Google with the reference to get the details.
            //to-do: I've set a value for key "provider" that is either "google" or "factual". Check this one to see which db to query and whether to use key "reference" (google) or key "factual_id" (factual).
                
            //open now
            case 0:
                destinationVC.placeReference = [[openNow objectAtIndex:indexPath.row]objectForKey:@"reference"];
                destinationVC.provider = [[openNow objectAtIndex:indexPath.row]objectForKey:@"provider"];
                destinationVC.placeRating = [[openNow objectAtIndex:indexPath.row]objectForKey:@"rating"];
                destinationVC.proximity = [[openNow objectAtIndex:indexPath.row]objectForKey:@"proximity"];
                destinationVC.placeLat = [[[[openNow objectAtIndex:indexPath.row]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"];
                destinationVC.placeLng = [[[[openNow objectAtIndex:indexPath.row]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"];
                break;
            //open later today
            case 1:
//                destinationVC.placeReference = [[openLater objectAtIndex:indexPath.row]objectForKey:@"reference"];
                //to-do: make sure tapping a place takes you to the right details page!
                //to-do: should I get rating from Google or Factual? Need to set up openLaterPlace mutable dict for this entire implementation and set value for it within G query if using Google
                //                destinationVC.placeRating = [[openLater objectAtIndex:indexPath.row]objectForKey:@"rating"];
                destinationVC.placeReference = [[openLater objectAtIndex:indexPath.row]objectForKey:@"reference"];
                destinationVC.provider = [[openLater objectAtIndex:indexPath.row]objectForKey:@"provider"];
                destinationVC.placeRating = [[openLater objectAtIndex:indexPath.row]objectForKey:@"rating"];
                destinationVC.proximity = [[openLater objectAtIndex:indexPath.row]objectForKey:@"proximity"];
                destinationVC.placeLat = [[openLater objectAtIndex:indexPath.row]objectForKey:@"latitude"];
                destinationVC.placeLng = [[openLater objectAtIndex:indexPath.row]objectForKey:@"longitude"];
                break;
        } //end switch
    }
}

//to-do: is it better to call this method from queryController or to directly call [[listView tableView]reloadData]; ?
-(void)refreshTable
{
    [[self tableView]reloadData];
}

//to-do: is it better to call this method from queryController or to set spinner as a property to directly call [[listView spinner]stopAnimating]; ?
-(void)stopSpinner
{
    [spinner stopAnimating];
}
@end
