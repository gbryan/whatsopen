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

//to-do: remove if I use segue instead of manual
- (IBAction)flagButtonPressed:(id)sender {
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];    
}
@end
