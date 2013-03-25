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

    //Set the nav bar title to the restaurant name
    UIFont *titleFont = [UIFont boldSystemFontOfSize:18.0];
    CGRect frame = CGRectMake(0, 0, [restaurantObject.name sizeWithFont:titleFont].width, 44);
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = titleFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = restaurantObject.name;
    self.navBar.titleView = titleLabel;

    self.detailsTextView.text = restaurantObject.detailsDisplay;
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
