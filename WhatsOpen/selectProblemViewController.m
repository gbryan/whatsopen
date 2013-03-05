//
//  selectProblemViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/5/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "selectProblemViewController.h"

@interface selectProblemViewController ()

@end

@implementation selectProblemViewController
@synthesize restaurantObject;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 7;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            //closed businesses should not be flagged as nonexistent, but rather users should submit that the place's status=0 (closed).
            return @"Out of Business";
            break;
        case 1:
            return @"Duplicate Entry";
            break;
        case 2:
            //problem=inappropriate if it is inappropriate for the entity to be included within the dataset it is currently included in
            return @"Classified Wrong";
            break;
        case 3:
            //problem=nonexistent if it is a person, place, or thing that does not exist.  For example, a fictitious place
            return @"Fictitious Restaurant";
            break;
        case 4:
            return @"Spam";
            break;
        case 5:
            //problem=inaccurate if some attribute of the data is inaccurate, and you do not have the accurate data to correct it with
            return @"Inaccurate Information";
            break;
        case 6:
            return @"Other";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}
@end
