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
    UIView *grayOverlay;
}
@end

@implementation selectProblemViewController
@synthesize restaurantObject;
@synthesize problemExplanation;
@synthesize problemPicker;
@synthesize problemReference;
@synthesize navBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Get center point of view when it loads so we know where to put it back later when we move it
    originalViewCenter = self.view.center;
    
    NSLog(@"retaurant: %@", restaurantObject.name);

}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    factualCorrectionsController *controller = [[factualCorrectionsController alloc]init];
    return [[controller problemTypeRowLabels]count];
}

- (NSString* )pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    factualCorrectionsController *controller = [[factualCorrectionsController alloc]init];
    return [[controller problemTypeRowLabels]objectAtIndex:row];
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
    self.view.center = CGPointMake(originalViewCenter.x, originalViewCenter.y - 216);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //move view back down to original point
    self.view.center = CGPointMake(originalViewCenter.x, originalViewCenter.y);
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
    NSInteger selectedRow = [problemPicker selectedRowInComponent:0];
    factualCorrectionsController *controller = [[factualCorrectionsController alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(correctionSubmitted)
                                                 name:@"correctionSubmitted"
                                               object:nil];

    [controller flagRestaurantWithID:restaurantObject.factualID
                                                    problemType:selectedRow
                                                        comment:problemExplanation.text
                                                      reference:problemReference.text];
}

- (void)correctionSubmitted
{
    UIAlertView *submitted = [[UIAlertView alloc]
                              initWithTitle:@"Correction Submitted"
                              message:@"Thanks for taking the time to submit a correction! It may take a couple weeks before the correction is made."
                              delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
    [submitted show];
    [self dismissViewControllerAnimated:self completion:nil];
}

@end
