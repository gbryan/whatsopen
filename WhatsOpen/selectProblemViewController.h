//
//  selectProblemViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/5/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "restaurant.h"
#import "factualCorrectionsController.h"
#import <QuartzCore/QuartzCore.h>

@interface selectProblemViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) restaurant *restaurantObject;
- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *problemExplanation;
@property (weak, nonatomic) IBOutlet UITextField *problemReference;
@property (weak, nonatomic) IBOutlet UIPickerView *problemPicker;
@property (weak, nonatomic) IBOutlet UIToolbar *navBar;

@end
