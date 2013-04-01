//
//  openLaterViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/1/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMAAppDelegate.h"
#import "placeDetailViewController.h"
#import "sortViewController.h"

@interface openLaterViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UINavigationItem *navBar;
@property (nonatomic, readonly) IBOutlet UITableView *restaurantTableView;
@property (nonatomic, readonly) IBOutlet UIActivityIndicatorView *spinner;
- (IBAction)homeButtonPressed:(id)sender;

@end
