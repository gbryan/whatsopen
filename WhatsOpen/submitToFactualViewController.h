//
//  submitToFactualViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/5/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "restaurant.h"

@interface submitToFactualViewController : UIViewController
@property (nonatomic, strong) restaurant *restaurantObject;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@end
