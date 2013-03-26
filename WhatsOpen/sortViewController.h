//
//  sortViewController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/25/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "queryController.h"
#import "openNowViewController.h"
#import "openLaterViewController.h"
#import "hoursUnknownViewController.h"

@interface sortViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *sortPicker;
@property (strong, nonatomic) NSArray *sortOptionLabels;
@property (strong, nonatomic) NSArray *sortKeys;
@property (strong, nonatomic) NSString *arrayToSort;
@property (weak, nonatomic) IBOutlet UIButton *acceptsCCButton;
@property (weak, nonatomic) IBOutlet UIButton *servesAlcoholButton;
@property (weak, nonatomic) IBOutlet UIButton *takeoutButton;
@property (weak, nonatomic) IBOutlet UIButton *freeParkingButton;

- (IBAction)acceptsCCButtonPressed:(id)sender;
- (IBAction)servesAlcoholButtonPressed:(id)sender;
- (IBAction)takeoutButtonPressed:(id)sender;
- (IBAction)freeParkingButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
@end
