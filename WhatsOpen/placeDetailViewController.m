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

- (void)viewDidLoad
{
    NSLog(@"restaurant passed: %@", restaurantObject);
    NSLog(@"opennext: %@      closeNext: %@", restaurantObject.openNextDisplay, restaurantObject.closingNextDisplay);
    NSLog(@"open now? %i", restaurantObject.isOpenNow);
    
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

//to-do: hide all these until 1) location is acquired, 2) detail query is completed, and 3) Google map loads
    
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
     to-do: visit website icon attribution: "Uses icons from Project Icons by Mihaiciuc Bogdan." The text Mihaiciuc Bogdan should link to http://bogo-d.deviantart.com
     to-do: if I add icons other than his, I need to provide attribution
     */
    restaurantImage.image = restaurantObject.image;
    
    //Open status display
    if (restaurantObject.isOpenNow == TRUE)
    {
        openNowOrLater.text = @"OPEN NOW";
        openNowOrLater.textColor = [UIColor colorWithRed:.314 green:.604 blue:.067 alpha:1];
        //to-do: make it possible to tap this textView (or something) to push modal view of full listing of hours
    }
    else
    {
        openNowOrLater.text = restaurantObject.openNextDisplay;
        openNowOrLater.textColor = darkBlue;
        
        //to-do: make it possible to tap this textView to push modal view of full listing of hours
    }
    
    //Select the appropriate image to show for price
    NSString *priceLevelString = [[NSString alloc]init];
    switch (restaurantObject.priceLevel) {
        case 1:
            priceLevelString = @"dollar.png";
            break;
        case 2:
            priceLevelString = @"dollar2.png";
            break;
        case 3:
            priceLevelString = @"dollar3.png";
            break;
        case 4:
            priceLevelString = @"dollar4.png";
            break;
        case 5:
            priceLevelString = @"dollar5.png";
            break;
        default:
            //to-do: image for no pricing info available
            priceLevelString = @"";
            break;
    }
    priceIcon.image = [UIImage imageNamed:priceLevelString];

    //Select the appropriate image with correct number of stars
    if (![restaurantObject.rating isEqualToString:@""])
    {
        if ([restaurantObject.rating isEqualToString:@"0.0"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating0.png"];
        }
        else if ([restaurantObject.rating isEqualToString:@"0.5"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating0point5.png"];
        }
        else if ([restaurantObject.rating isEqualToString:@"1.0"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating1.png"];
        }
        else if ([restaurantObject.rating isEqualToString:@"1.5"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating1point5.png"];
        }
        else if ([restaurantObject.rating isEqualToString:@"2.0"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating2.png"];
        }
        else if ([restaurantObject.rating isEqualToString:@"2.5"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating2point5.png"];
        }
        else if ([restaurantObject.rating isEqualToString:@"3.0"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating3.png"];
        }
        else if ([restaurantObject.rating isEqualToString:@"3.5"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating3point5.png"];
        }
        else if ([restaurantObject.rating isEqualToString:@"4.0"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating4.png"];
        }
        else if ([restaurantObject.rating isEqualToString:@"4.5"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating4point5.png"];
        }
        else if ([restaurantObject.rating isEqualToString:@"5.0"])
        {
            ratingIcon.image = [UIImage imageNamed:@"rating5.png"];
        }
        else
        {
            //to-do: load image for not yet rated
        }
    }
    
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

    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //to-do: check when to display these based on whether current restaurant has a website, phone number, hours, etc.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactInfo"];
    
    NSString *hoursDetail = [[NSString alloc]init];
    if (restaurantObject.isOpenNow == TRUE) hoursDetail = restaurantObject.closingNextDisplay;
    if (restaurantObject.isOpenNow == FALSE) hoursDetail = restaurantObject.openNextDisplay;
    
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
            //to-do: show nextOpen if closed or nextClose if open??
            //to-do: find icon to represent hours
            break;
    }
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0];
    cell.selectedBackgroundView = selectionColor;
    return cell;
}

- (void)viewDirections
{
    _deviceLocation = [_locationService getCurrentLocation];
    
    //to-do: it would be preferable to pass the address city, state instead of coords
    NSString *placeLatLngString = [NSString stringWithFormat:@"%@,%@", restaurantObject.latitude, restaurantObject.longitude];
    NSString *deviceLatLngString = [NSString stringWithFormat:@"%f,%f", _deviceLocation.latitude, _deviceLocation.longitude];

    NSURL *openGoogleMapsURL = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&directionsmode=walking&zoom=17", deviceLatLngString, placeLatLngString]];
    NSURL *openAppleMapsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%@&daddr=%@",deviceLatLngString, placeLatLngString]];

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
            [self viewDirections];
            break;
        case 2:
            //website
            [self pushWebModalViewController];
            break;
        case 3:
            [self viewHours];
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

-(void)viewHours
{
    //to-do: write this to display modal view with neatly organized hours for the whole week
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

-(void)pushWebModalViewController
{
    websiteViewController *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
    webVC.restaurantObject = self.restaurantObject;
    [self presentViewController:webVC animated:TRUE completion:nil];
}
@end
