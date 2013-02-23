//
//  listViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/25/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMAAppDelegate.h"
#import "queryController.h"

@class queryController;
@interface listViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    queryController *queryControl;
}
@property (nonatomic, weak) IBOutlet UINavigationItem *navBar;
@property (nonatomic, strong) IBOutlet UITableView *restaurantTableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
//to-do: should these really be retain?
@property (nonatomic, retain) NSMutableArray *openNow;
@property (nonatomic, retain) NSMutableArray *openLater;

@end