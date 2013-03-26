//
//  homeViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/25/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMAAppDelegate.h"

@interface homeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *mealButton;
@property (weak, nonatomic) IBOutlet UIButton *dessertButton;
@property (weak, nonatomic) IBOutlet UIButton *drinkButton;

@end
