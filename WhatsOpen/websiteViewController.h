//
//  websiteViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/26/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "placeDetailViewController.h"
#import "restaurant.h"
@interface websiteViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) restaurant *restaurantObject;
- (IBAction)closeWebView:(id)sender;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@end
