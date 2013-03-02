//
//  websiteViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/26/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "websiteViewController.h"

@implementation websiteViewController
{
    NSMutableData *_receivedData;
    NSMutableData *_responseData;
    NSURLRequest *_restaurantWebsiteRequest;
}
@synthesize restaurantObject;

-(void)viewDidLoad
{
    //Set the nav bar title to the restaurant name
    UIFont *titleFont = [UIFont boldSystemFontOfSize:18.0];
    CGRect frame = CGRectMake(0, 0, [restaurantObject.name sizeWithFont:titleFont].width, 44);
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = titleFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = restaurantObject.name;
    self.navBar.titleView = titleLabel;
    NSLog(@"name: %@", restaurantObject.name);
    
    //Load the restaurant's website if there isn't a problem with the URL or the server
    NSURL *restaurantURL = [NSURL URLWithString:restaurantObject.website];
    if (restaurantURL != nil)
    {
        _restaurantWebsiteRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:restaurantObject.website]];
        NSHTTPURLResponse* response = nil;
        NSError* error = nil;
        [NSURLConnection sendSynchronousRequest:_restaurantWebsiteRequest returningResponse:&response error:&error];
        NSLog(@"statusCode = %d", [response statusCode]);
        
        if ([response statusCode] != 200)
        {
            [self.webView loadHTMLString:@"<span style='font-size:100px;'>This website is down.</span>" baseURL:nil];
        }
        else
        {
            [self.webView loadRequest:_restaurantWebsiteRequest];
        }        
    }
    else
    {
        [self.webView loadHTMLString:@"<span style='font-size:100px;'>This website does not exist.</span>" baseURL:nil];
    }
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.webView loadHTMLString:@"There was a problem loading this website." baseURL:nil];
}
/*
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode != 200)
        {
            [connection cancel];
            NSLog(@"didReceiveResponse statusCode with %i", statusCode);
            [self.webView loadHTMLString:@"This website is down." baseURL:nil];
        }
        else
        {
            [self.webView loadRequest:_restaurantWebsiteRequest];
        }
    }
}
*/
- (IBAction)closeWebView:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}
@end
