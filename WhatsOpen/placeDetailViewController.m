//
//  placeDetail.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import "placeDetailViewController.h"

@interface placeDetailViewController () {
    NSMutableDictionary *placeDetailsDictionary;
    BOOL didLoad;
}

@end

@implementation placeDetailViewController
@synthesize placeReference;
@synthesize provider;
@synthesize placeRating;
@synthesize priceLabel;
@synthesize ratingLabel;
@synthesize phoneLabel;
@synthesize placeNameLabel;
@synthesize distanceLabel;
@synthesize deviceLat;
@synthesize deviceLng;
@synthesize loadingIndicator;
@synthesize proximity;
@synthesize placeLat;
@synthesize placeLng;
@synthesize viewDirections;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    placeNameLabel.hidden = TRUE;
    ratingLabel.hidden = TRUE;
    priceLabel.hidden = TRUE;
    phoneLabel.hidden = TRUE;
    distanceLabel.hidden = TRUE;
    viewDirections.hidden = TRUE;
    [loadingIndicator startAnimating];
    
    if ([provider isEqualToString:@"google"])
    {
        [self queryGooglePlaces:placeReference];
        [self loadGoogleMap:placeLat lng:placeLng];
    }
    else
    {
        //query Factual
    }
    

}

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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPlaceNameLabel:nil];
    [self setRatingLabel:nil];
    [self setPriceLabel:nil];
    [self setPhoneLabel:nil];
    [self setDistanceLabel:nil];
    [self setLoadingIndicator:nil];
    [self setGoogleMap:nil];
    [self setViewDirections:nil];
    [super viewDidUnload];
}

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

- (IBAction)viewDirections:(id)sender {
    
    NSString *placeLatLngString = [NSString stringWithFormat:@"%@,%@", placeLat, placeLng];
    NSString *deviceLatLngString = [NSString stringWithFormat:@"%@,%@", deviceLat, deviceLng];
    
    NSURL *openGoogleMapsURL = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&directionsmode=walking&zoom=17", deviceLatLngString, placeLatLngString]];
    NSURL *openAppleMapsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%@&daddr=%@",deviceLatLngString, placeLatLngString]];
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:openGoogleMapsURL];
    }
    else {
        [[UIApplication sharedApplication] openURL:openAppleMapsURL];
    }
}
@end
