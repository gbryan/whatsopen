//
//  moreDetailsViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/5/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "restaurant.h"
#import "selectProblemViewController.h"

@interface moreDetailsViewController : UIViewController

@property (nonatomic, strong) restaurant *restaurantObject;
- (IBAction)flagButtonPressed:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;
@end
