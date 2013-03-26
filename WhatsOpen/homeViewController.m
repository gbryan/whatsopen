//
//  homeViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/25/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "homeViewController.h"

@interface homeViewController ()

@end

@implementation homeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mealButton setImage:[UIImage imageNamed:@"meal.png"] forState:UIControlStateNormal];
    [self.dessertButton setImage:[UIImage imageNamed:@"dessert.png"] forState:UIControlStateNormal];    
    [self.drinkButton setImage:[UIImage imageNamed:@"bar.png"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([[segue identifier] isEqualToString:@"meal"])
    {
        [UMAAppDelegate queryControllerShared].queryIntention = QUERY_INTENTION_MEAL;
        [[UMAAppDelegate queryControllerShared]refreshRestaurants];
    }
    else if ([[segue identifier] isEqualToString:@"dessert"])
    {
        [UMAAppDelegate queryControllerShared].queryIntention = QUERY_INTENTION_DESSERT;
        [[UMAAppDelegate queryControllerShared]refreshRestaurants];
    }
    else if ([[segue identifier] isEqualToString:@"drink"])
    {
        [UMAAppDelegate queryControllerShared].queryIntention = QUERY_INTENTION_DRINK;
        [[UMAAppDelegate queryControllerShared]refreshRestaurants];
    }
}

@end
