//
//  flagViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/5/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

/*
to-do:
 - once user finishes entering info and saves/sends, need to thank her/him and dismiss all VCs on top of placeDetailVC
 
 */

#import "flagViewController.h"

@interface flagViewController ()

@end

@implementation flagViewController
@synthesize restaurantObject;
@synthesize testLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    testLabel.text = restaurantObject.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
