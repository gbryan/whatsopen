//
//  placeDetail.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import "placeDetailViewController.h"

@interface placeDetailViewController () {
    locationServices *_locationService;
    queryController *_queryControl;
    CLLocationCoordinate2D _deviceLocation;
}

@end

@implementation placeDetailViewController
@synthesize restaurantObject;
@synthesize distanceLabel;
@synthesize deviceLat;
@synthesize deviceLng;
@synthesize loadingIndicator;
@synthesize ratingIcon;
@synthesize priceIcon;
@synthesize restaurantImage;
@synthesize openNowOrLater;
@synthesize contactInfoTableView;
@synthesize topView;

- (void)viewDidLoad
{
    //Set up background colors and rounded corners
    self.view.layer.backgroundColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0].CGColor;
    self.topView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [[self.topView layer] setCornerRadius:5.0];
    [[self.topView layer] setMasksToBounds:TRUE];
    [[self.contactInfoTableView layer] setCornerRadius:5.0];
    [[self.contactInfoTableView layer] setMasksToBounds:TRUE];
    [[self.googleMapView layer] setCornerRadius:5.0];
    [[self.googleMapView layer] setMasksToBounds:TRUE];
    
    
    NSLog(@"restaurant Factual id %@: %@", restaurantObject.name, restaurantObject.factualID);
    NSLog(@"details: %@", restaurantObject.detailsDisplay);
    
    
    [self startListeningForCompletedQuery];
    _locationService = [[locationServices alloc]init];
    _queryControl = [[queryController alloc]init];
    [_queryControl getRestaurantDetail:restaurantObject];
    
    //Set the nav bar title to the restaurant name
    UIFont *titleFont = [UIFont boldSystemFontOfSize:18.0];
    CGRect frame = CGRectMake(0, 0, [restaurantObject.name sizeWithFont:titleFont].width, 44);
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = titleFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = restaurantObject.name;
    self.navBar.titleView = titleLabel;
    
    //Load Google Map
    mapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
    mapVC.restaurantCoordinates = CLLocationCoordinate2DMake([restaurantObject.latitude floatValue], [restaurantObject.longitude floatValue]);
    mapVC.markerTitle = restaurantObject.name;
    mapVC.markerSnippet = restaurantObject.cuisineLabel;
    [self.googleMapView addSubview:mapVC.view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopSpinner"
                                                        object:nil];
}

//this is called by restaurantDetailsAcquired so that the page show info reflecting the updated restaurantObject from the detail query
- (void)loadDisplay
{
    UIFont *labelsFont = [UIFont fontWithName:@"Georgia-Bold" size:17];
    UIColor *darkBlue = [UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0];
    distanceLabel.font = labelsFont;
    openNowOrLater.font = labelsFont;
    distanceLabel.text = restaurantObject.proximity;

    /*
     to-do: add image attribution: https://developers.google.com/places/documentation/photos
 */
    restaurantImage.image = restaurantObject.image;
    
    //Open status display
    if (restaurantObject.isOpenNow == TRUE)
    {
        openNowOrLater.text = @"OPEN NOW";
        openNowOrLater.textColor = [UIColor colorWithRed:.314 green:.604 blue:.067 alpha:1];
    }
    else
    {
        openNowOrLater.text = restaurantObject.openNextDisplay;
        openNowOrLater.textColor = darkBlue;
    }
    
    priceIcon.image = restaurantObject.priceIcon;

    ratingIcon.image = restaurantObject.ratingImage;
    
    //to-do: stop animating loading indicator when Google map finishes loading
    [self.loadingIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setDistanceLabel:nil];
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
}

- (void)restaurantDetailsAcquired
{
    //once queryC finishes filling in details for restaurant object, get that updated restaurant object
    restaurantObject = [_queryControl detailRestaurant];
    
    [self loadDisplay];
    [self.loadingIndicator stopAnimating];
}

- (void)startListeningForCompletedQuery
{
    NSLog(@"LISTENING!!!!");
    
    [self.loadingIndicator startAnimating];
    
    //placeDetailViewController will listen for queryController to give notification that it has finished the query
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restaurantDetailsAcquired)
                                                 name:@"restaurantDetailsAcquired"
                                               object:nil];
}

#pragma mark - table view delegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 5;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Disable cells if there is there is no info for that cell.
        //Example: If there is no phone #, gray out the "Call Restaurant" cell and disable user interaction.
    switch (indexPath.row)
    {
        case 0:
            if (restaurantObject.phone.length < 1)
            {
                cell.alpha = 0.2;
                cell.userInteractionEnabled = FALSE;
            }
            break;
        case 1:
            if (restaurantObject.address.length < 1)
            {
                cell.alpha = 0.2;
                cell.userInteractionEnabled = FALSE;
            }
            break;
        case 2:
            if (restaurantObject.website.length < 1)
            {
                cell.alpha = 0.2;
                cell.userInteractionEnabled = FALSE;
            }
            break;
        case 3:
            if (restaurantObject.openHours.length < 1)
            {
                cell.alpha = 0.2;
                cell.userInteractionEnabled = FALSE;
            }
            break;
        case 4:
            if (restaurantObject.detailsDisplay.length < 1)
            {
                cell.alpha = 0.2;
                cell.userInteractionEnabled = FALSE;
            }
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //to-do: check when to display these based on whether current restaurant has a website, phone number, hours, etc.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactInfo"];
    
    NSString *hoursDetail = [[NSString alloc]init];
    if (restaurantObject.isOpenNow == TRUE) hoursDetail = restaurantObject.closingNextDisplay;
    if (restaurantObject.isOpenNow == FALSE) hoursDetail = restaurantObject.openNextDisplay;
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0];
    cell.selectedBackgroundView = selectionColor;
    
    switch (indexPath.row)
    {        
        case 0:
            cell.textLabel.text = @"Call Restaurant";
            cell.imageView.image = [UIImage imageNamed:@"iPhone.png"];
            break;
        case 1:
            cell.textLabel.text = @"Directions";
            cell.detailTextLabel.text = restaurantObject.address;
            cell.imageView.image = [UIImage imageNamed:@"signpost.png"];
            break;
        case 2:
            cell.textLabel.text = @"Website";
            cell.imageView.image = [UIImage imageNamed:@"webicon.png"];
            break;
        case 3:
            cell.textLabel.text = @"Hours";
            cell.detailTextLabel.text = hoursDetail;
            cell.imageView.image = [UIImage imageNamed:@"clock.png"];
            break;
        case 4:
            cell.textLabel.text = @"More Details";
            cell.imageView.image = [UIImage imageNamed:@"moredetails.png"];
            break;
            
            //to-do: add menu if I can get access to Locu and have time
    }
    return cell;
}

- (void)viewDirectionsButtonPressed
{
    //to-do: get location
    [_locationService addObserver:self forKeyPath: @"deviceLocation"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [_locationService getLocation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"deviceLocation"])
    {
        NSLog(@"placeDetailVC: location value changed");
        
        [_locationService removeObserver:self forKeyPath:@"deviceLocation"];
        _deviceLocation = _locationService.deviceLocation;
        
        [self openDirections];
    }
}

- (void)openDirections
{
    NSString *restaurantLatLngString = [NSString stringWithFormat:@"%@,%@", restaurantObject.latitude, restaurantObject.longitude];
    NSString *deviceLatLngString = [NSString stringWithFormat:@"%f,%f", _deviceLocation.latitude, _deviceLocation.longitude];
//    NSString *restaurantAddress = [restaurantObject.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *openGoogleMapsURL = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&directionsmode=walking&zoom=17", deviceLatLngString, restaurantLatLngString]];
    NSURL *openAppleMapsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%@&daddr=%@",deviceLatLngString, restaurantLatLngString]];
    
    //try to open in Google Maps app but open in Apple maps if user doesn't have GM installed
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:openGoogleMapsURL];
    }
    else {
        [[UIApplication sharedApplication] openURL:openAppleMapsURL];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            //phone            
            [self callRestaurant];
            break;
        case 1:
            //directions
            [self viewDirectionsButtonPressed];
            break;
        case 2:
            //website
            [self viewWebsite];
            break;
        case 3:
            [self viewHours];
            break;
        case 4:
            [self viewMoreDetails];
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

-(void)viewHours
{
    hoursViewController *hoursVC = [self.storyboard instantiateViewControllerWithIdentifier:@"hoursView"];
    hoursVC.restaurantObject = self.restaurantObject;
    [self presentViewController:hoursVC animated:TRUE completion:nil];
}

-(void)callRestaurant
{
    NSString *phoneNumber = [NSString stringWithFormat:@"telprompt:%@", restaurantObject.phone];
    NSURL *URL = [NSURL URLWithString:phoneNumber];
    [[UIApplication sharedApplication] openURL:URL];
}

-(void)viewWebsite
{
    // Thanks to Oliver Letterer for the browser: https://github.com/samvermette/SVWebViewController
	NSURL *URL = [NSURL URLWithString:self.restaurantObject.website];
	SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
	webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    webViewController.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsOpenInChrome | SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink;
    [self presentViewController:webViewController animated:YES completion:nil];
}

-(void)viewMoreDetails
{
    moreDetailsViewController *moreDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"moreDetails"];
    moreDetailsVC.restaurantObject = self.restaurantObject;
    [self presentViewController:moreDetailsVC animated:TRUE completion:nil];
}

- (IBAction)flagButtonPressed:(id)sender
{
    selectProblemViewController *selectProblemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"selectProblem"];
    selectProblemVC.restaurantObject = self.restaurantObject;
    [self presentViewController:selectProblemVC animated:TRUE completion:nil];
}
@end
