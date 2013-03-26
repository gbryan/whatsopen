//
//  openNowViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMAAppDelegate.h"
#import "placeDetailViewController.h"
#import "sortViewController.h"
//#import "homeViewController.h"

@interface openNowViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UINavigationItem *navBar;
@property (nonatomic, readonly) IBOutlet UITableView *restaurantTableView;
@property (nonatomic, readonly) IBOutlet UIActivityIndicatorView *spinner;
- (IBAction)sortButtonPressed:(id)sender;
- (IBAction)homeButtonPressed:(id)sender;
@end