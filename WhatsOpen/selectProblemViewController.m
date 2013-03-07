//
//  selectProblemViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/5/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "selectProblemViewController.h"

@interface selectProblemViewController ()
{
    CGPoint originalViewCenter;
}
@end

@implementation selectProblemViewController
@synthesize restaurantObject;
@synthesize problemExplanation;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    originalViewCenter = self.view.center;

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Dismiss keyboard when user touches anywhere outside of text field
    [self.problemExplanation resignFirstResponder];
    [self.problemReference resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //Dismiss keyboard when user presses done/return key on keyboard
    [textField resignFirstResponder];
    return FALSE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //move view up so that keyboard doesn't hide it
    self.view.center = CGPointMake(originalViewCenter.x, originalViewCenter.y - 250);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //move view back down to original point (but account for navbar with 44)
    self.view.center = CGPointMake(originalViewCenter.x, originalViewCenter.y - 44);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
        //to-do: implement this
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


- (IBAction)submitButtonPressed:(id)sender
{
    //to-do: call queryController to submit flag request
}
@end
