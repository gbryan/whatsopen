//
//  openNowViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//


/*
 //to-do: will queries fail gracefully if there's no location found?
//to-do: what happens if there are none open now in 3 pages?
//to-do: what if there are none open later today?
//to-do: what if factual returns null result? will it crash?
*/
 
#import "openNowViewController.h"

@interface openNowViewController ()
{
    NSMutableArray* _openNow;
    BOOL isInitialLoad;
    BOOL internationalQuery;
    BOOL _isListening;
}

@end

@implementation openNowViewController

@synthesize restaurantTableView=_restaurantTableView;
@synthesize spinner=_spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];

    isInitialLoad = TRUE;
    _isListening = FALSE;
    
    //Set title
    UILabel *navBarTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,40,320,40)];
    navBarTitle.textAlignment = NSTextAlignmentLeft;
    navBarTitle.text = @"Open Now";
    navBarTitle.backgroundColor = [UIColor clearColor];
    navBarTitle.font = [UIFont fontWithName:@"Georgia-Bold" size:25];
    navBarTitle.textColor = [UIColor whiteColor];
    _navBar.titleView = navBarTitle;
    
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
    
    [self refreshRestaurantList];
    
}

- (void)startListeningForCompletedQuery
{
    _isListening = TRUE;
    
    NSLog(@"LISTENING!!!!");
    //listViewController will listen for queryController to give notification that it has finished the query
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restaurantsAcquired:)
                                                 name:@"restaurantsAcquired"
                                               object:nil];
}

- (void) loadRestaurantList
{
    NSLog(@"user requested additional restaurants");
    
    //This runs when user scrolls to bottom of list to request more restaurants (they are appended to bottom of list).
    if ([[UMAAppDelegate queryControllerShared]noMoreResults] == FALSE)
    {
        if (_isListening == FALSE)
        {
            [self startListeningForCompletedQuery];
        }
        
        [_spinner startAnimating];
        [[UMAAppDelegate queryControllerShared] appendNewRestaurants];
    }
}

- (void)refreshRestaurantList
{
    NSLog(@"1 user refreshed list");
    
    //This runs only when user pulls down to refresh. It clears out existing arrays and gets all new results.
    if (_isListening == FALSE)
    {
        [self startListeningForCompletedQuery];
    }
    
    [_spinner startAnimating];
    [[UMAAppDelegate queryControllerShared] refreshRestaurants];
}

- (void)restaurantsAcquired:(NSNotification *)notification
{
    //to-do: set internationalQuery based on value pulled from queryController
    //to-do: if I use Google results for something other than just international queries, I need to display attribution then
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
    
    NSLog(@"openNowVC: # openNow before removeAll:%d", _openNow.count);
    
    [_openNow removeAllObjects];
    
    NSLog(@"openNowVC: # openNow after removeAll:%d", _openNow.count);
    
    _openNow = [[NSMutableArray alloc]initWithArray:[UMAAppDelegate queryControllerShared].openNow];
    
    NSLog(@"Restaurants acquired:  openNow: %i", [_openNow count]);
    NSLog(@"# openNow in queryC: %d", [UMAAppDelegate queryControllerShared].openNow.count);

    NSLog(@"10 openNowVC: update private arrays and reload table");
    if (isInitialLoad == TRUE)
    {
        isInitialLoad = FALSE;
    }
    
    [_restaurantTableView reloadData];
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

//- (NSString* )tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    //such as "Within 1.25 miles"
//    return [_queryController farthestPlaceString];
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //If this is the initial load, _openNow.count will always be 0 until we've retrieved results. Don't show the cell (return 1) telling the user there are no restaurants unless we've gotten the query back and know that there are actually no results.
    if (_openNow.count < 1 && isInitialLoad == FALSE)
    {
        return 1;
    }
    
    return _openNow.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row %2 == 0)
    {
        UIColor *lightBlue = [UIColor colorWithRed:0.05 green:0.1 blue:0.15 alpha:0.15];
        cell.backgroundColor = lightBlue;
    }

    //Use red background to indicate that the restaurant is closing soon
    if (_openNow.count > 0)
    {
        restaurant* restaurantObject = [_openNow objectAtIndex:indexPath.row];
        if (restaurantObject.closingSoon == TRUE)
        {
            cell.backgroundColor = [UIColor colorWithRed:.7 green:0 blue:.1 alpha:.3];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
        }
        else
        {
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //to-do: once I update tableViewCell with custom design, I need to use separate identifier for cell showing no results
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"openNowCell"];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    nameLabel.text = nil;
    UILabel *cuisine = (UILabel *)[cell viewWithTag:2];
    cuisine.text = nil;
    UILabel *closingTime = (UILabel *)[cell viewWithTag:3];
    closingTime.text = nil;
    UIImageView *ratingView = (UIImageView *)[cell viewWithTag:4];
    ratingView.image = nil;
    UILabel *distance = (UILabel *)[cell viewWithTag:5];
    distance.text = nil;
    UILabel *price = (UILabel *)[cell viewWithTag:6];
    price.text = nil;
    
    //Make cell dark blue when selecting it
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0];
    cell.selectedBackgroundView = selectionColor;
    
    if (_openNow.count > 0)
    {
        restaurant* restaurantObject = [_openNow objectAtIndex:indexPath.row];
        
        nameLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:15.5];
        nameLabel.numberOfLines = 2;
        nameLabel.backgroundColor = [UIColor clearColor];
        
        nameLabel.text = restaurantObject.name;
        cuisine.text = restaurantObject.cuisineLabel;
        closingTime.text = restaurantObject.closingNextDisplay;
        ratingView.image = restaurantObject.ratingImage;
        distance.text = restaurantObject.proximity;
        price.text = restaurantObject.priceLevelDisplay;
    }
    else
    {
        cell.textLabel.text = @"No nearby restaurants are open :(";
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

//Thanks to Henri Normak for this: http://stackoverflow.com/questions/6023683/add-rows-to-uitableview-when-scrolled-to-bottom
//This loads more restaurants if user scrolls to the end of the existing results.
//to-do:if there are < a few restaurants, it will append when you pull down to refresh
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
//    NSLog(@"current:%i  max:%i", currentOffset, maximumOffset);
    
    if (currentOffset >= (maximumOffset + 40)) {
        NSLog(@"adding more restaurants to the list");
        _spinner.center = CGPointMake(160, currentOffset+150);
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
