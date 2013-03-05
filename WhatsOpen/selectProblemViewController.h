//
//  selectProblemViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/5/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "restaurant.h"
#import "submitToFactualViewController.h"
#import "flagViewController.h"

@interface selectProblemViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) restaurant *restaurantObject;
- (IBAction)closeButtonPressed:(id)sender;
@end
