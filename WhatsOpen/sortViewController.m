//
//  sortViewController.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/25/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import "sortViewController.h"

@interface sortViewController ()

@end

@implementation sortViewController

@synthesize sortOptionLabels;
@synthesize sortPicker;
@synthesize arrayToSort;
@synthesize sortKeys;
@synthesize freeParkingButton;
@synthesize acceptsCCButton;
@synthesize servesAlcoholButton;
@synthesize takeoutButton;

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Highlight buttons if they were previously selected by user.
    [self.servesAlcoholButton setSelected:[UMAAppDelegate queryControllerShared].filterServesAlcohol];
    [self.acceptsCCButton setSelected:[UMAAppDelegate queryControllerShared].filterAcceptsCC];
    [self.freeParkingButton setSelected:[UMAAppDelegate queryControllerShared].filterFreeParking];
    [self.takeoutButton setSelected:[UMAAppDelegate queryControllerShared].filterTakeout];
    
    [self.servesAlcoholButton setBackgroundImage:[UIImage imageNamed:@"bar.png"] forState:UIControlStateSelected];
    [self.acceptsCCButton setBackgroundImage:[UIImage imageNamed:@"bar.png"] forState:UIControlStateSelected];
    [self.freeParkingButton setBackgroundImage:[UIImage imageNamed:@"bar.png"] forState:UIControlStateSelected];
    [self.takeoutButton setBackgroundImage:[UIImage imageNamed:@"bar.png"] forState:UIControlStateSelected];
    
    if ([self.arrayToSort isEqualToString:@"openNow"])
    {
        self.sortOptionLabels = [[NSArray alloc]initWithObjects:
                            @"Name",
                            @"Distance",
                            @"Rating",
                            @"Closing Soonest",
                            @"Price Level", nil];
        self.sortKeys = [[NSArray alloc]initWithObjects:
                            SORT_NAME,
                            SORT_DISTANCE,
                            SORT_RATING,
                            SORT_CLOSED_NEXT,
                            SORT_PRICE_LEVEL, nil];
    }
    else if ([self.arrayToSort isEqualToString:@"openLater"])
    {
        self.sortOptionLabels = [[NSArray alloc]initWithObjects:
                            @"Name",
                            @"Distance",
                            @"Rating",
                            @"Opening Soonest",
                            @"Price Level", nil];
        self.sortKeys = [[NSArray alloc]initWithObjects:
                            SORT_NAME,
                            SORT_DISTANCE,
                            SORT_RATING,
                            SORT_OPEN_NEXT,
                            SORT_PRICE_LEVEL, nil];
    }
    else if ([self.arrayToSort isEqualToString:@"hoursUnknown"])
    {
        self.sortOptionLabels = [[NSArray alloc]initWithObjects:
                            @"Name",
                            @"Distance",
                            @"Rating",
                            @"Price Level", nil];
        self.sortKeys = [[NSArray alloc]initWithObjects:
                            SORT_NAME,
                            SORT_DISTANCE,
                            SORT_RATING,
                            SORT_PRICE_LEVEL, nil];
    }
    else
    {
        NSLog(@"sortVC: invalid array name specified for arrayToSort");
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.sortOptionLabels.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.sortOptionLabels objectAtIndex:row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)acceptsCCButtonPressed:(id)sender
{
    NSLog(@"before: %d %d", self.acceptsCCButton.selected, [UMAAppDelegate queryControllerShared].filterAcceptsCC);
    [self.acceptsCCButton setSelected:!self.acceptsCCButton.selected];
    NSLog(@"after: %d %d", self.acceptsCCButton.selected, [UMAAppDelegate queryControllerShared].filterAcceptsCC);
}

- (IBAction)servesAlcoholButtonPressed:(id)sender
{
    [self.servesAlcoholButton setSelected:!self.servesAlcoholButton.selected];
    [UMAAppDelegate queryControllerShared].filterServesAlcohol = !self.servesAlcoholButton.selected;
}

- (IBAction)takeoutButtonPressed:(id)sender
{
    [self.takeoutButton setSelected:!self.takeoutButton.selected];
    [UMAAppDelegate queryControllerShared].filterTakeout = !self.takeoutButton.selected;
}

- (IBAction)freeParkingButtonPressed:(id)sender
{
    [self.freeParkingButton setSelected:!self.freeParkingButton.selected];
    [UMAAppDelegate queryControllerShared].filterFreeParking = !self.freeParkingButton.selected;
}

- (IBAction)doneButtonPressed:(id)sender
{
    NSInteger selectedRow = [self.sortPicker selectedRowInComponent:0];

    //to-do: check if filter criteria changed
        //if so, run query with new filter criteria, and make sure it sorts by new sort criteria (if they changed - but we don't need to check if they changed; just change them anyway)
    
    //set sort criteria in queryC
    if ([arrayToSort isEqualToString:@"openNow"])
    {
        [UMAAppDelegate queryControllerShared].openNowSort = [self.sortKeys objectAtIndex:selectedRow];
    }
    else if ([arrayToSort isEqualToString:@"openLater"])
    {
        [UMAAppDelegate queryControllerShared].openLaterSort = [self.sortKeys objectAtIndex:selectedRow];
    }
    else if ([arrayToSort isEqualToString:@"hoursUnknown"])
    {
        [UMAAppDelegate queryControllerShared].hoursUnknownSort = [self.sortKeys objectAtIndex:selectedRow];
    }
    //set filter criteria in queryC
    //run query in queryC if filter values changed from initial state (if only sort changed, just re-sort the arrays without issuing new query)
    [UMAAppDelegate queryControllerShared].filterAcceptsCC = self.acceptsCCButton.selected;
    
    [[UMAAppDelegate queryControllerShared]sortArrayNamed:self.arrayToSort
                                                    ByKey:[self.sortKeys objectAtIndex:selectedRow]];
    
    //This tells the list VCs to reload the arrays from queryController and reload their table data.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantsAcquired"
                                                        object:nil];
    [self dismissViewControllerAnimated:TRUE completion:nil];
}
@end
