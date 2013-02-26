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
}

@end

@implementation placeDetailViewController
@synthesize restaurantObject;
@synthesize distanceLabel;
@synthesize deviceLat;
@synthesize deviceLng;
@synthesize loadingIndicator;
@synthesize addressLabel;
@synthesize ratingIcon;
@synthesize priceIcon;
@synthesize phoneIcon;
@synthesize phoneTextView;
@synthesize restaurantImage;
@synthesize openNowOrLater;
@synthesize mapContainer;
@synthesize websiteButton;


- (void)viewWillAppear:(BOOL)animated
{
    
    NSLog(@"restaurnat passed: %@", restaurantObject);
    
    [self.loadingIndicator startAnimating];
    
    _locationService = [[locationServices alloc]init];
    _queryControl = [[queryController alloc]init];
    
    [_queryControl getRestaurantDetail:restaurantObject];
    [self startListeningForCompletedQuery];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    websiteButton.hidden = TRUE;
    NSLog(@"website: %@", restaurantObject.website);
    if ([restaurantObject.website length] > 0)
    {
        websiteButton.hidden = FALSE;
    }
    distanceLabel.text = restaurantObject.proximity;
    addressLabel.text = restaurantObject.address;
    phoneTextView.text = restaurantObject.phone;
    phoneTextView.font = [UIFont systemFontOfSize:20.0];

    //to-do: finish this and display some placeholder icon if no img is available for this restaurant
    NSURL *restaurantImageURL = [NSURL URLWithString:restaurantObject.imageURLString];
    NSData *restaurantImageData = [NSData dataWithContentsOfURL:restaurantImageURL];
    UIImage *restaurantImg = [UIImage imageWithData:restaurantImageData];
    restaurantImage.image = restaurantImg;
    
    
    //figure out what to display for open status
    if (restaurantObject.isOpenNow == TRUE)
    {
        openNowOrLater.text = @"Open Now";
        openNowOrLater.textColor = [UIColor greenColor];
        openNowOrLater.font = [UIFont boldSystemFontOfSize:14];
        
        //to-do: make it possible to tap this textView to push modal view of full listing of hours
    }
    else
    {
        openNowOrLater.text = restaurantObject.openNextDisplay;
        openNowOrLater.textColor = [UIColor blueColor];
//        [openNowOrLater sizeToFit];
        
        //to-do: make it possible to tap this textView to push modal view of full listing of hours
    }
    
    
    //Select the appropriate image to show for price
    switch (restaurantObject.priceLevel) {
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            break;
        case 5:
            break;
        default:
            break;
    }

    //Select the appropriate image with correct number of stars
    if (![restaurantObject.rating isEqualToString:@""])
    {
        if ([restaurantObject.rating isEqualToString:@"1.0"])
        {
            
        }
        else if ([restaurantObject.rating isEqualToString:@"1.5"])
        {
            
        }
        else if ([restaurantObject.rating isEqualToString:@"2.0"])
        {
            
        }
        else if ([restaurantObject.rating isEqualToString:@"2.5"])
        {
            
        }
        else if ([restaurantObject.rating isEqualToString:@"3.0"])
        {
            
        }
        else if ([restaurantObject.rating isEqualToString:@"3.5"])
        {
            
        }
        else if ([restaurantObject.rating isEqualToString:@"4.0"])
        {
            
        }
        else if ([restaurantObject.rating isEqualToString:@"4.5"])
        {
            
        }
        else if ([restaurantObject.rating isEqualToString:@"5.0"])
        {
            
        }
        else
        {
            //load image for not yet rated
        }
    }
    
    //to-do: stop animating loading indicator when Google map finishes loading
    [self.loadingIndicator stopAnimating];
}

/*
- (void)loadGoogleMap:(NSString *)lat lng:(NSString *)lng {
    
    NSString *icon = @"http://png.findicons.com/files/icons/2083/go_green_web/64/open_sign.png";
    NSString *zoomLevel = @"16";
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?size=320x180&markers=icon:%@%@%@,%@&sensor=false&zoom=%@&key=%@", icon, @"%7C",lat, lng, zoomLevel, GOOGLE_API_KEY];
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"the url: %@",urlString);
    [self.googleMap loadRequest:[NSURLRequest requestWithURL:url]];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(didLoad == TRUE) {
        [loadingIndicator stopAnimating];
        loadingIndicator.hidden = TRUE;
    }
    else {
        didLoad = TRUE;
    }
    NSLog(@"finished loading!!!!");
}
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDistanceLabel:nil];
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
}

/*
- (void)queryGooglePlaces:(NSString *)placeReferenceString {
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@", placeReferenceString, GOOGLE_API_KEY];
    
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    placeDetailsDictionary = [json objectForKey:@"result"];
    
    //    NSLog(@"place details: %@", placeDetailsDictionary);
    
    NSString *ratingLabelText = [[NSString alloc]init];
    
    if ([placeRating integerValue] == 0) {
        ratingLabelText = @"Rating: Not yet rated";
    }
    else {
        ratingLabelText = [NSString stringWithFormat:@"Rating: %.1f/5", [placeRating floatValue]];
    }
    
    NSInteger priceLevelInt = [[placeDetailsDictionary objectForKey:@"price_level"]integerValue];
    NSString *priceLevelString = [[NSString alloc]init];
    
    switch(priceLevelInt) {
        case 1:
            priceLevelString = @"$";
            break;
        case 2:
            priceLevelString = @"$$";
            break;
        case 3:
            priceLevelString = @"$$$";
            break;
        case 4:
            priceLevelString = @"$$$$";
            break;
        case 5:
            priceLevelString = @"$$$$$";
            break;
        default:
            priceLevelString = nil;
    }
    
    NSString *priceLabelText = [[NSString alloc]init];
    
    //check this
    if(priceLevelString == nil) {
        priceLabelText = @"No pricing information available.";
    }
    else {
        priceLabelText = [NSString stringWithFormat:@"Price Level: %@", priceLevelString];
    }
    
    placeNameLabel.text = [placeDetailsDictionary objectForKey:@"name"];
    placeNameLabel.font = [UIFont boldSystemFontOfSize:25];
    placeNameLabel.textAlignment = NSTextAlignmentCenter;
    ratingLabel.text = ratingLabelText;
    priceLabel.text = priceLabelText;
    phoneLabel.text = [placeDetailsDictionary objectForKey:@"formatted_phone_number"];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [placeDetailsDictionary objectForKey:@"formatted_phone_number"]]];
    //phoneLabel.text = url;
    distanceLabel.text = proximity;
    
    placeNameLabel.hidden = FALSE;
    ratingLabel.hidden = FALSE;
    priceLabel.hidden = FALSE;
    phoneLabel.hidden = FALSE;
    distanceLabel.hidden = FALSE;
    viewDirections.hidden = FALSE;
    
    if(didLoad == TRUE) {
        [loadingIndicator stopAnimating];
        loadingIndicator.hidden = TRUE;
    }
    else {
        didLoad = TRUE;
    }
}
*/
//- (IBAction)viewDirections:(id)sender {
//
//    NSString *placeLatLngString = [NSString stringWithFormat:@"%@,%@", restaurantObject.latitude, restaurantObject.longitude];
//    
//    //to-do: it would be best to get up-to-date device location now
//    NSString *deviceLatLngString = [NSString stringWithFormat:@"%@,%@", deviceLat, deviceLng];
//    
//    NSURL *openGoogleMapsURL = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&directionsmode=walking&zoom=17", deviceLatLngString, placeLatLngString]];
//    NSURL *openAppleMapsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%@&daddr=%@",deviceLatLngString, placeLatLngString]];
//    
//    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
//        [[UIApplication sharedApplication] openURL:openGoogleMapsURL];
//    }
//    else {
//        [[UIApplication sharedApplication] openURL:openAppleMapsURL];
//    }
//}

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
                                             selector:@selector(restaurantDetailsAcquired:)
                                                 name:@"restaurantDetailsAcquired"
                                               object:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"webView"])
    {
        websiteViewController *webVC = [segue destinationViewController];
        webVC.restaurantObject = self.restaurantObject;
    }
}

@end
