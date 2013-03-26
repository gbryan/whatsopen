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
    NSMutableArray *_openNow;
    BOOL isInitialLoad;
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
    navBarTitle.textAlignment = NSTextAlignmentCenter;
    navBarTitle.text = [UMAAppDelegate queryControllerShared].queryIntention;
    navBarTitle.backgroundColor = [UIColor clearColor];
    navBarTitle.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
    navBarTitle.textColor = [UIColor whiteColor];
    _navBar.titleView = navBarTitle;
            
    //set tint color of section headers
    [[UITableViewHeaderFooterView appearance]setTintColor:[UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0]];
    
    //set up pull to refresh
    UIRefreshControl *pullToRefresh = [[UIRefreshControl alloc]init];
    [pullToRefresh addTarget:self action:@selector(refreshRestaurantList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = pullToRefresh;
    
    //Other views can notify openNowVC to start its spinner if they are presenting this VC.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startSpinner)
                                                 name:@"startSpinner"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopSpinner)
                                                 name:@"stopSpinner"
                                               object:nil];
    [self startSpinner];
    [self startListeningForCompletedQuery];
    
}

- (void)startSpinner
{
    NSLog(@"openNowVC: start spinner called");
    //display spinner to indicate to the user that the query is still running
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.hidesWhenStopped = YES;
    _spinner.color = [UIColor blackColor];
    [self.view addSubview:_spinner];
    
    
    //Ensure that spinner is centered wherever user has scrolled in tableView
    _spinner.center = CGPointMake(self.tableView.center.x, (self.tableView.contentOffset.y)+(self.view.center.y));
    
    if (isInitialLoad == TRUE)
    {
        _spinner.center = CGPointMake(self.tableView.center.x, (self.tableView.center.y) - 44);
    }
    [_spinner startAnimating];
}

- (void)stopSpinner
{
    [_spinner stopAnimating];
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
        
        //This keeps the user from scrolling and sending an additional query request while this one executes.
        [_restaurantTableView setScrollEnabled:FALSE];
        
        [[UMAAppDelegate queryControllerShared] appendNewRestaurants];
    }
}

- (void)refreshRestaurantList
{
    NSLog(@"user refreshed list");
    
    //This runs only when user pulls down to refresh. It clears out existing arrays and gets all new results.
    if (_isListening == FALSE)
    {
        [self startListeningForCompletedQuery];
    }
    
    //This keeps the user from scrolling and sending an additional query request while this one executes.
    [_restaurantTableView setScrollEnabled:FALSE];
    
    [[UMAAppDelegate queryControllerShared] refreshRestaurants];
    
    // queryC tells the spinner to start, but we don't want it to animate if user pulls down to refresh
        //because the refreshControl already has a spinning animation.
    [_spinner stopAnimating];
}

- (void)restaurantsAcquired:(NSNotification *)notification
{    
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
    [_restaurantTableView setScrollEnabled:TRUE];
}

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
        restaurant *restaurantObject = [_openNow objectAtIndex:indexPath.row];
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
        restaurant *restaurantObject = [_openNow objectAtIndex:indexPath.row];
        
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
        //We have to load the animation on a separate thread or it won't appear at all.
        [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
        
        // Get reference to the destination view controller
        placeDetailViewController *destinationVC = [segue destinationViewController];
        NSIndexPath *indexPath = [_restaurantTableView indexPathForSelectedRow];
        destinationVC.restaurantObject = [_openNow objectAtIndex:indexPath.row];
    }
    else if ([[segue identifier] isEqualToString:@"sort"])
    {
        sortViewController *sortVC = [segue destinationViewController];
        sortVC.arrayToSort = @"openNow";
    }
}

- (void) threadStartAnimating:(id)data
{
    [self startSpinner];
}

- (IBAction)homeButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end
