//
//  hoursUnknownViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/1/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//




//to-do: make sure that I have placeholders for the missing information so that these don't look stupid. Provide way for users to add missing info on Factual
#import "hoursUnknownViewController.h"

@interface hoursUnknownViewController ()
{
    NSMutableArray *_hoursUnknown;
    BOOL isInitialLoad;
    BOOL internationalQuery;
    BOOL _lastResultWasNull;
    BOOL _isListening;
}
@end

@implementation hoursUnknownViewController
@synthesize restaurantTableView=_restaurantTableView;
@synthesize spinner=_spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isInitialLoad = TRUE;
    _lastResultWasNull = FALSE;
    _isListening = FALSE;
    
    //Set title
    UILabel *navBarTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,40,320,40)];
    navBarTitle.textAlignment = NSTextAlignmentLeft;
    navBarTitle.text = @"Restaurants with Unknown Hours";
    navBarTitle.backgroundColor = [UIColor clearColor];
    navBarTitle.font = [UIFont fontWithName:@"Georgia-Bold" size:16.5];
    navBarTitle.textColor = [UIColor whiteColor];
    _navBar.titleView = navBarTitle;
    
    //display spinner to indicate to the user that the query is still running
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(160, 200);
    _spinner.hidesWhenStopped = YES;
    _spinner.color = [UIColor blackColor];
    [self.view addSubview:_spinner];
    
    //set up pull to refresh
    UIRefreshControl *pullToRefresh = [[UIRefreshControl alloc]init];
    [pullToRefresh addTarget:self action:@selector(refreshRestaurantList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = pullToRefresh;

    _hoursUnknown = [[NSMutableArray alloc]
                     initWithArray:[UMAAppDelegate queryControllerShared].hoursUnknown];
    [_restaurantTableView reloadData];

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

- (void)loadRestaurantList
{
    //This runs when the view first loads (get initial list of results) and when user scrolls to bottom of list to request more restaurants (they are appended to bottom of list).
    if (_isListening == FALSE)
    {
        [self startListeningForCompletedQuery];
    }
    
    if (_lastResultWasNull == FALSE)
    {
        [_spinner startAnimating];
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
    [_spinner startAnimating];
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
    _hoursUnknown = [[NSMutableArray alloc]
                initWithArray:[UMAAppDelegate queryControllerShared].hoursUnknown];
    
    NSLog(@"Restaurants acquired:  hoursUnknown: %i", [_hoursUnknown count]);
    
    //Since reloadSections withRowAnimation will crash the app if there are < 1 array items, we run reloadData the first time and then subsequent times ensure that there is at least 1 restaurant in the array before reloadingSections.
    
    //to-do: am I using this anymore? if not, remove on all 3 tableview controllers
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
//    return @"Restaurants with Unknown Hours";
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_hoursUnknown.count < 1 && isInitialLoad == FALSE) return 1;
    else return _hoursUnknown.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hoursUnknownCell"];

    if (_hoursUnknown.count > 0)
    {
        restaurant *restaurantObject = [_hoursUnknown objectAtIndex:indexPath.row];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        nameLabel.text = restaurantObject.name;
        nameLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:15.5];
        nameLabel.numberOfLines = 2;
        nameLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *cuisine = (UILabel *)[cell viewWithTag:2];
        cuisine.text = restaurantObject.cuisineLabel;
        
        UILabel *address = (UILabel *)[cell viewWithTag:3];
        address.text = restaurantObject.address;
        
        UIImageView *ratingView = (UIImageView *)[cell viewWithTag:4];
        ratingView.image = restaurantObject.ratingImage;
        
        UILabel *distance = (UILabel *)[cell viewWithTag:5];
        distance.text = restaurantObject.proximity;
        
        UILabel *price = (UILabel *)[cell viewWithTag:6];
        price.text = restaurantObject.priceLevelDisplay;
        
        //Make cell dark blue when selecting it
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0];
        cell.selectedBackgroundView = selectionColor;
    }

    else
    {
        cell.textLabel.text = @"None nearby are missing hours info :)";
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

//Thanks to Henri Normak for this: http://stackoverflow.com/questions/6023683/add-rows-to-uitableview-when-scrolled-to-bottom
//This loads more restaurants if user scrolls to the end of the existing results.
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (currentOffset >= maximumOffset) {
        NSLog(@"adding more restaurants to the list");
        _spinner.center = CGPointMake(160, currentOffset+100);
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
    destinationVC.restaurantObject = [_hoursUnknown objectAtIndex:indexPath.row];
}
@end
