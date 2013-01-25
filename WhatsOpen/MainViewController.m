//
//  MainViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 1/15/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "MainViewController.h"
#import "listViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"SEGUE ID: %@",[segue identifier]);
    
    listViewController *vc = [segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"restaurants"]) {
        [vc setPlacesArray:[NSArray arrayWithObjects:@"cafe", @"restaurant", @"bakery", nil]];
        
    }
    else if ([[segue identifier] isEqualToString:@"banks"]) {
        [vc setPlacesArray:[NSArray arrayWithObjects:@"bank", nil]];
    }

    //shopping and groceries IDs push other VCs without needing to run a query yet
}

@end
