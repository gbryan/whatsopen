//
//  openLaterViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/1/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "openLaterViewController.h"

@interface openLaterViewController ()
{
    NSMutableArray *_openLater;
    BOOL isInitialLoad;
    BOOL internationalQuery;
    BOOL _lastResultWasNull;
    BOOL _isListening;
}
@end

@implementation openLaterViewController
@synthesize restaurantTableView=_restaurantTableView;
@synthesize spinner=_spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];

//    _queryController = [[queryController alloc]init];
    isInitialLoad = TRUE;
    _lastResultWasNull = FALSE;
    _isListening = FALSE;
    
    //Set title
    UILabel *navBarTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,40,320,40)];
    navBarTitle.textAlignment = NSTextAlignmentLeft;
    navBarTitle.text = @"Open Later Today";
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
    
//    //set tint color of section headers
//    [[UITableViewHeaderFooterView appearance]setTintColor:[UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0]];
    
    //set up pull to refresh
    UIRefreshControl *pullToRefresh = [[UIRefreshControl alloc]init];
    [pullToRefresh addTarget:self action:@selector(refreshRestaurantList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = pullToRefresh;

    //to-do: I commented this out bc restaurants will already be loaded from when app first loads on openNow and query is issued.
//    [_spinner startAnimating];
//    [self startListeningForCompletedQuery];
    //    [self loadRestaurantList];
    
    _openLater = [[NSMutableArray alloc]
                  initWithArray:[UMAAppDelegate queryControllerShared].openLater];
    [_restaurantTableView reloadData];


}

- (void)startListeningForCompletedQuery
{
    NSLog(@"LISTENING!!!!");
    
    _isListening = TRUE;
    
    //listViewController will listen for queryController to give notification that it has finished the query
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restaurantsAcquired:)
                                                 name:@"restaurantsAcquired"
                                               object:nil];
}

- (void)loadRestaurantList
{
    //This runs when the view first loads (get initial list of results) and when user scrolls to bottom of list to request more restaurants (they are appended to bottom of list).
    if (_lastResultWasNull == FALSE)
    {
        [_spinner startAnimating];
        
        if (_isListening == FALSE)
        {
            [self startListeningForCompletedQuery];
        }

        [[UMAAppDelegate queryControllerShared] appendNewRestaurants];
    }
}

- (void)refreshRestaurantList
{
    //This runs only when user pulls down to refresh. It clears out existing arrays and gets all new results.
    if (_isListening == FALSE)
    {
        [self startListeningForCompletedQuery];
    }
    [[UMAAppDelegate queryControllerShared] refreshRestaurants];
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
        //display Factual attribution (if required)
    }
    
    _lastResultWasNull = [[UMAAppDelegate queryControllerShared] lastResultWasNull];
    _openLater = [[NSMutableArray alloc]
                  initWithArray:[UMAAppDelegate queryControllerShared].openLater];
    
    NSLog(@"Restaurants acquired:  openLater: %i", [_openLater count]);
    
    if (isInitialLoad == TRUE)
    {
        isInitialLoad = FALSE;
    }
    
    [_restaurantTableView reloadData];
    [_spinner stopAnimating];
    [self.refreshControl endRefreshing];
    
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"Open Later Today";
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_openLater.count < 1 && isInitialLoad == FALSE) return 1;
    else return _openLater.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"openLaterCell"];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    nameLabel.text = nil;
    UILabel *cuisine = (UILabel *)[cell viewWithTag:2];
    cuisine.text = nil;
    UILabel *openNext = (UILabel *)[cell viewWithTag:3];
    openNext.text = nil;
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

    if (_openLater.count > 0)
    {
        restaurant *restaurantObject = [_openLater objectAtIndex:indexPath.row];
        
//        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        nameLabel.text = restaurantObject.name;
        nameLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:15.5];
        nameLabel.numberOfLines = 2;
        nameLabel.backgroundColor = [UIColor clearColor];
        
//        UILabel *cuisine = (UILabel *)[cell viewWithTag:2];
        cuisine.text = restaurantObject.cuisineLabel;
        
//        UILabel *openNext = (UILabel *)[cell viewWithTag:3];
        openNext.text = restaurantObject.openNextDisplay;
        
//        UIImageView *ratingView = (UIImageView *)[cell viewWithTag:4];
        ratingView.image = restaurantObject.ratingImage;
        
//        UILabel *distance = (UILabel *)[cell viewWithTag:5];
        distance.text = restaurantObject.proximity;
        
//        UILabel *price = (UILabel *)[cell viewWithTag:6];
        price.text = restaurantObject.priceLevelDisplay;
        
//        //Make cell dark blue when selecting it
//        UIView *selectionColor = [[UIView alloc] init];
//        selectionColor.backgroundColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0];
//        cell.selectedBackgroundView = selectionColor;
    }
    else
    {
        cell.textLabel.text = @"No nearby restaurants are open later today :(";
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

//Thanks to Henri Normak for this: http://stackoverflow.com/questions/6023683/add-rows-to-uitableview-when-scrolled-to-bottom
//This loads more restaurants if user scrolls to the end of the existing results.
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    NSLog(@"current: %i    max:%i", currentOffset, maximumOffset);
    //to-do: this has issues with < 5 cells filled
    if (currentOffset >= (maximumOffset + 40))
    {
        NSLog(@"adding more restaurants to the list");
        _spinner.center = CGPointMake(160, currentOffset+150);
        [self loadRestaurantList];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row %2 == 0)
    {
        UIColor *lightBlue = [UIColor colorWithRed:0.05 green:0.1 blue:0.15 alpha:0.15];
        cell.backgroundColor = lightBlue;
    }
    
    //Use green background to indicate that the restaurant is opening soon
    if (_openLater.count > 0)
    {
        restaurant *restaurantObject = [_openLater objectAtIndex:indexPath.row];
        if (restaurantObject.openingSoon == TRUE)
        {
            cell.backgroundColor = [UIColor colorWithRed:.05 green:1 blue:.05 alpha:.1];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
        }
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
    // Get reference to the destination view controller
    placeDetailViewController *destinationVC = [segue destinationViewController];
    NSIndexPath *indexPath = [_restaurantTableView indexPathForSelectedRow];
    destinationVC.restaurantObject = [_openLater objectAtIndex:indexPath.row];
}

@end
