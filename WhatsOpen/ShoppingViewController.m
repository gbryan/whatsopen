//
//  ShoppingViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 1/15/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "ShoppingViewController.h"
#import "listViewController.h"

@interface ShoppingViewController ()

@end

@implementation ShoppingViewController

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
    
    listViewController *vc = [segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"clothing"]) {
        [vc setPlacesArray:[NSArray arrayWithObjects:@"clothing_store", @"department_store", @"shopping_mall", nil]];
    }
    else if ([[segue identifier] isEqualToString:@"electronics"]) {
        [vc setPlacesArray:[NSArray arrayWithObjects:@"electronics_store", nil]];
    }
    else if ([[segue identifier] isEqualToString:@"electronics"]) {
        [vc setPlacesArray:[NSArray arrayWithObjects:@"electronics_store", nil]];
    }
    else if ([[segue identifier] isEqualToString:@"furniture"]) {
        [vc setPlacesArray:[NSArray arrayWithObjects:@"furniture_store", nil]];
    }
    else if ([[segue identifier] isEqualToString:@"hardware"]) {
        [vc setPlacesArray:[NSArray arrayWithObjects:@"hardware_store", nil]];
    }
    else if ([[segue identifier] isEqualToString:@"home_goods"]) {
        [vc setPlacesArray:[NSArray arrayWithObjects:@"home_goods_store", nil]];
    }
    else if ([[segue identifier] isEqualToString:@"jewelry"]) {
        [vc setPlacesArray:[NSArray arrayWithObjects:@"jewelry", nil]];
    }
    else if ([[segue identifier] isEqualToString:@"shoes"]) {
        [vc setPlacesArray:[NSArray arrayWithObjects:@"shoe_store", nil]];
    }
    //need to fill in all other types of shopping
}


@end
