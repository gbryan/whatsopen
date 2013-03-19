//
//  hoursViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/1/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "placeDetailViewController.h"
#import "restaurant.h"

@interface hoursViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *hoursTextView;
@property (strong, nonatomic) restaurant* restaurantObject;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
- (IBAction)closeHoursView:(id)sender;
- (IBAction)flagButtonPressed:(id)sender;
@end
