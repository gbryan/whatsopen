//
//  listViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//


/*
 to-do: set color when selecting row (needs to match dark blue color scheme)
 //to-do: will queries fail gracefully if there's no location found?
//to-do: what happens if there are none open now in 3 pages?
//to-do: what if there are none open later today?
//to-do: what if factual returns null result? will it crash?
 to-do: comment out test location code
*/
 
#import "listViewController.h"

@interface listViewController ()
{
    NSMutableArray *_openNow;
    NSMutableArray *_openLater;
    queryController *_queryController;
    BOOL isInitialLoad;
}

@end

@implementation listViewController

@synthesize restaurantTableView=_restaurantTableView;
@synthesize spinner=_spinner;

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
    
    _queryController = [[queryController alloc]init];
    isInitialLoad = TRUE;
    
    //display spinner to indicate to the user that the query is still running
    _spinner = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(160, 200);
    _spinner.hidesWhenStopped = YES;
    _spinner.color = [UIColor blackColor];
    [self.view addSubview:_spinner];
        
    //set tint color of section headers
    [[UITableViewHeaderFooterView appearance]setTintColor:[UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0]];
    
    //set up pull to refresh
    UIRefreshControl *pullToRefresh = [[UIRefreshControl alloc]init];
    [pullToRefresh addTarget:self action:@selector(loadRestaurantList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = pullToRefresh;
    
    [self startListeningForCompletedQuery];
    [self loadRestaurantList];
//    [_queryController getGeocode];

    
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
    [_restaurantTableView setTableFooterView:footerImageView];
}

- (void)startListeningForCompletedQuery
{
    NSLog(@"LISTENING!!!!");
    
    [_spinner startAnimating];
    //listViewController will listen for queryController to give notification that it has finished the query
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restaurantsAcquired:)
                                                 name:@"restaurantsAcquired"
                                               object:nil];
}

- (void)loadRestaurantList
{
    //Begin query to Google and Factual to retrieve restaurants that are open today
    [_queryController getRestaurants];
}

- (void)restaurantsAcquired:(NSNotification *)notification
{
    _openNow = [[NSMutableArray alloc]
                initWithArray:_queryController.openNow];
    _openLater = [[NSMutableArray alloc]
                  initWithArray:_queryController.openLater];
    
    NSLog(@"Restaurants acquired:  openNow: %i   openLater: %i", [_openNow count], [_openLater count]);
    
    //set message to farthest place distance. Example: "Open restaurants within 1.24 miles:"
    //to-do: is this the right size for iPhone 5 screen also?
    NSString *farthestPlaceString = _queryController.farthestPlaceString;
    UIFont *font = [UIFont boldSystemFontOfSize:18.0];
    CGRect frame = CGRectMake(0, 0, [farthestPlaceString sizeWithFont:font].width, 44);
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = font;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = farthestPlaceString;
    
    //to-do: make this bigger?
    _navBar.titleView = titleLabel;
    
    //check if this is the initial view load, and if so, just use reloadData. Subsequent times, use reloadSections. May need to check whether section 1 is displayed at all since there may not be any openLaters
    if (isInitialLoad == TRUE)
    {
        [_restaurantTableView reloadData];
        isInitialLoad = FALSE;
    }

    else
    {
        [_restaurantTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([_openLater count] > 0)
        {
            [_restaurantTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
    }

    [_spinner stopAnimating];
    [self.refreshControl endRefreshing];

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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //Don't display "open later" if there are no nearby restaurants open later.
    //Always display "open now" since it'll crash if there is not > 0 sections.
    int numSections=1;

    if ([_openLater count] > 0) numSections=2;

    return numSections;
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
            return _openNow.count;
            break;
        case 1:
            return _openLater.count;
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
        restaurant *restaurantObject = [_openNow objectAtIndex:indexPath.row];
        cell.textLabel.text = restaurantObject.name;
        cell.detailTextLabel.text = restaurantObject.proximity;
    }
    else {
        restaurant *restaurantObject = [_openLater objectAtIndex:indexPath.row];
        cell.textLabel.text = restaurantObject.name;
//        cell.detailTextLabel.text = [[_openLater objectAtIndex:indexPath.row] objectForKey:@"proximity"];
        cell.detailTextLabel.text = restaurantObject.openNextDisplay;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"detailSegue"])
    {
        // Get reference to the destination view controller
        placeDetailViewController *destinationVC = [segue destinationViewController];
        
        NSIndexPath *indexPath = [_restaurantTableView indexPathForSelectedRow];
        NSUInteger section = [indexPath section];
        
        
//        destinationVC.deviceLat = [NSString stringWithFormat:@"%f",deviceLocation.latitude];
//        destinationVC.deviceLng = [NSString stringWithFormat:@"%f",deviceLocation.longitude];
        
        
        //to-do: do I want a different view for those open later today than those open now?
        
        //open now
        if (section == 0)
        {
            destinationVC.restaurantObject = [_openNow objectAtIndex:indexPath.row];
        }
        //open later today
        else if (section == 1)
        {
            destinationVC.restaurantObject = [_openLater objectAtIndex:indexPath.row];
        }
        else
        {
            NSLog(@"ERROR: Section %i has not been implemented in prepareForSegue.", section);
        }
    }
}
@end
