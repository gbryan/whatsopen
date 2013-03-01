//
//  openNowViewController.m
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
 
#import "openNowViewController.h"

@interface openNowViewController ()
{
    NSMutableArray *_openNow;
    queryController *_queryController;
    BOOL isInitialLoad;
    BOOL internationalQuery;
}

@end

@implementation openNowViewController

@synthesize restaurantTableView=_restaurantTableView;
@synthesize spinner=_spinner;

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
    [pullToRefresh addTarget:self action:@selector(refreshRestaurantList) forControlEvents:UIControlEventValueChanged];
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
    //This runs when the view first loads (get initial list of results) and when user scrolls to bottom of list to request more restaurants (they are appended to bottom of list).
    
    //to-do: make it run this method when user scrolls to bottom of existing results list in tableview
    [_queryController appendNewRestaurants];
}

- (void)refreshRestaurantList
{
    //This runs only when user pulls down to refresh. It clears out existing arrays and gets all new results.
    [_queryController refreshRestaurants];
}

- (void)restaurantsAcquired:(NSNotification *)notification
{
    //to-do: set internationalQuery based on value pulled from queryController
    internationalQuery = FALSE;
    
    if (internationalQuery == TRUE)
    {
        //Only non-U.S. queries are using Google data, so only load footer with attribution if international
        UIImage *footerImage = [UIImage imageNamed:@"google.png"];
        UIImageView *footerImageView = [[UIImageView alloc] initWithImage:footerImage];
        footerImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_restaurantTableView setTableFooterView:footerImageView];
    }
    else
    {
        //to-do: display Factual attribution (if required)
    }
    
    _openNow = [[NSMutableArray alloc]
                initWithArray:_queryController.openNow];
    
    NSLog(@"Restaurants acquired:  openNow: %i", [_openNow count]);
    
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
    
    //Since reloadSections withRowAnimation will crash the app if there are < 1 array items, we run reloadData the first time and then subsequent times ensure that there is at least 1 restaurant in the array before reloadingSections.
    if (isInitialLoad == TRUE)
    {
        
        [_restaurantTableView reloadData];
        isInitialLoad = FALSE;
    }

    else
    {
        if ([_openNow count] > 0)
        {
//            UIAlertView *initialLoad = [[UIAlertView alloc]initWithTitle:@"initial load" message:@"this is the first time results have loaded" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
//            [initialLoad show];
            [_restaurantTableView reloadData];
//            [_restaurantTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
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

#pragma mark - Table view delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Open Now";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _openNow.count;
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
    
    restaurant *restaurantObject = [_openNow objectAtIndex:indexPath.row];
    cell.textLabel.text = restaurantObject.name;
    cell.detailTextLabel.text = restaurantObject.proximity;
    
    //remove halo effect in background color
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0];
    cell.selectedBackgroundView = selectionColor;
    return cell;
}

//Thanks to Henri Normak for this: http://stackoverflow.com/questions/6023683/add-rows-to-uitableview-when-scrolled-to-bottom
//This loads more restaurants if user scrolls to the end of the existing results.
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (currentOffset >= maximumOffset) {
        NSLog(@"adding more restaurants to the list");
        [self loadRestaurantList];
    }
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
        destinationVC.restaurantObject = [_openNow objectAtIndex:indexPath.row];
    }
}
@end
