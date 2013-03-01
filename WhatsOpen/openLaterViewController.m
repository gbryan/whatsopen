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
    queryController *_queryController;
    BOOL isInitialLoad;
    BOOL internationalQuery;
}
@end

@implementation openLaterViewController
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
    [pullToRefresh addTarget:self action:@selector(loadRestaurantList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = pullToRefresh;
    
    [self startListeningForCompletedQuery];
    [self loadRestaurantList];


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
    NSLog(@"querying for restaurants");
    [_queryController getRestaurants];
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
    
    _openLater = [[NSMutableArray alloc]
                  initWithArray:_queryController.openLater];
    
    NSLog(@"Restaurants acquired:  openLater: %i", [_openLater count]);
    
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
        //to-do: not sure if I need something like this: [NSIndexSet indexSetWithIndex:0]
        [_restaurantTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Open Later Today";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_openLater count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeCell"];

    restaurant *restaurantObject = [_openLater objectAtIndex:indexPath.row];
    cell.textLabel.text = restaurantObject.name;
    //        cell.detailTextLabel.text = [[_openLater objectAtIndex:indexPath.row] objectForKey:@"proximity"];
    cell.detailTextLabel.text = restaurantObject.openNextDisplay;
    
    //remove halo effect in background color
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0];
    cell.selectedBackgroundView = selectionColor;
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
    NSLog(@"segue id:", [segue identifier]);
    // Get reference to the destination view controller
    placeDetailViewController *destinationVC = [segue destinationViewController];
    NSIndexPath *indexPath = [_restaurantTableView indexPathForSelectedRow];
    destinationVC.restaurantObject = [_openLater objectAtIndex:indexPath.row];
}

@end
