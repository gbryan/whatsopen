//
//  moreDetailsViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/5/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "moreDetailsViewController.h"

@interface moreDetailsViewController ()

@end

@implementation moreDetailsViewController
@synthesize restaurantObject;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)flagButtonPressed:(id)sender
{
    selectProblemViewController *selectProblemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"selectProblem"];
    selectProblemVC.restaurantObject = self.restaurantObject;
    [self presentViewController:selectProblemVC animated:TRUE completion:nil];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];    
}
@end
