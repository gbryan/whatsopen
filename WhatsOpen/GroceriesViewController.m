//
//  GroceriesViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 1/15/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "GroceriesViewController.h"

@interface GroceriesViewController ()

@end

@implementation GroceriesViewController

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
    if ([[segue identifier] isEqualToString:@"groceries"]) {
        
    }
}
@end
