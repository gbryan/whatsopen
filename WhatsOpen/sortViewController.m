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
    
    [self.servesAlcoholButton setBackgroundImage:[UIImage imageNamed:@"bg_color.png"]
                                        forState:UIControlStateSelected];
    [self.servesAlcoholButton setTitleColor:[UIColor whiteColor]
                                   forState:UIControlStateSelected];
    [self.acceptsCCButton setBackgroundImage:[UIImage imageNamed:@"bg_color.png"]
                                    forState:UIControlStateSelected];
    [self.acceptsCCButton setTitleColor:[UIColor whiteColor]
                                   forState:UIControlStateSelected];
    [self.freeParkingButton setBackgroundImage:[UIImage imageNamed:@"bg_color.png"]
                                      forState:UIControlStateSelected];
    [self.freeParkingButton setTitleColor:[UIColor whiteColor]
                                   forState:UIControlStateSelected];
    [self.takeoutButton setBackgroundImage:[UIImage imageNamed:@"bg_color.png"]
                                  forState:UIControlStateSelected];
    [self.takeoutButton setTitleColor:[UIColor whiteColor]
                                   forState:UIControlStateSelected];
    
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
    [self.acceptsCCButton setSelected:!self.acceptsCCButton.selected];
}

- (IBAction)servesAlcoholButtonPressed:(id)sender
{
    [self.servesAlcoholButton setSelected:!self.servesAlcoholButton.selected];
}

- (IBAction)takeoutButtonPressed:(id)sender
{
    [self.takeoutButton setSelected:!self.takeoutButton.selected];
}

- (IBAction)freeParkingButtonPressed:(id)sender
{
    [self.freeParkingButton setSelected:!self.freeParkingButton.selected];
}

- (IBAction)doneButtonPressed:(id)sender
{
    NSInteger selectedRow = [self.sortPicker selectedRowInComponent:0];
    
    // Determine whether any filter values have changed
    BOOL oldAcceptsCCValue = [UMAAppDelegate queryControllerShared].filterAcceptsCC;
    BOOL oldTakeoutValue = [UMAAppDelegate queryControllerShared].filterTakeout;
    BOOL oldFreeParkingValue = [UMAAppDelegate queryControllerShared].filterFreeParking;
    BOOL oldServesAlcoholValue = [UMAAppDelegate queryControllerShared].filterServesAlcohol;
    
    if ((oldAcceptsCCValue != self.acceptsCCButton.selected) ||
        (oldTakeoutValue != self.takeoutButton.selected) ||
        (oldFreeParkingValue != self.freeParkingButton.selected) ||
        (oldServesAlcoholValue != self.servesAlcoholButton.selected))
    {
        // One or more filter values has changed. Set new values.
        [UMAAppDelegate queryControllerShared].filterAcceptsCC = self.acceptsCCButton.selected;
        [UMAAppDelegate queryControllerShared].filterTakeout = self.takeoutButton.selected;
        [UMAAppDelegate queryControllerShared].filterFreeParking = self.freeParkingButton.selected;
        [UMAAppDelegate queryControllerShared].filterServesAlcohol = self.servesAlcoholButton.selected;
        
        // Set new sort value and re-sort array (we aren't checking whether or not the sort key has changed).
        [[UMAAppDelegate queryControllerShared]sortArrayNamed:self.arrayToSort
                                                        ByKey:[self.sortKeys objectAtIndex:selectedRow]];
        
        // Run the restaurant query with the new filter and sort criteria.
        [[UMAAppDelegate queryControllerShared]refreshRestaurants];
    }
    else
    {
        // Even if filter values haven't changed, we will re-sort by the specified sort key (without re-querying Factual).
            // We are not checking whether or not the key has actually changed from its old value.
        [[UMAAppDelegate queryControllerShared]sortArrayNamed:self.arrayToSort
                                                        ByKey:[self.sortKeys objectAtIndex:selectedRow]];
        
        // Tell the list VCs to reload the arrays from queryController and reload their table data.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"restaurantsAcquired"
                                                            object:nil];
    }
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end
