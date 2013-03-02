//
//  hoursViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/1/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "hoursViewController.h"

@interface hoursViewController ()

@end

@implementation hoursViewController
@synthesize restaurantObject;
@synthesize hoursTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    if ([restaurantObject.openHours length] > 0) hoursTextView.text = restaurantObject.openHours;
    else
    {
        hoursTextView.text = [NSString stringWithFormat:@"No hours are available for %@.", restaurantObject.name];
        hoursTextView.font = [UIFont boldSystemFontOfSize:16];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeHoursView:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end
