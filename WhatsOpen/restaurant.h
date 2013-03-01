//
//  restaurant.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/22/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface restaurant : NSObject

//to-do: see if I end up using all of these properties
@property (strong, nonatomic) NSString *googleID;
@property (strong, nonatomic) NSString *factualID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *proximity;
@property (strong, nonatomic) NSArray *openHours;
@property (strong, nonatomic) NSString *rating;
@property (assign, nonatomic) int priceLevel;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *parking;
@property (strong, nonatomic) NSString *attire;
@property (strong, nonatomic) NSString *cashOnly;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSArray *cuisine;
@property (strong, nonatomic) NSString *hasFullBar;
@property (strong, nonatomic) NSString *reservations;
@property (strong, nonatomic) NSString *outdoorSeating;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *open24Hours;
@property (strong, nonatomic) NSString *servesAlcohol;
@property (strong, nonatomic) NSString *wheelchair;
@property (strong, nonatomic) NSString *takeout;
@property (strong, nonatomic) NSDate *openNextSort;
@property (strong, nonatomic) NSString *openNextDisplay;
@property (strong, nonatomic) NSDate *closingNextSort;
@property (strong, nonatomic) NSString *closingNextDisplay;
@property (assign, nonatomic) BOOL isOpenNow;
@property (strong, nonatomic) UIImage *image;
//@property (strong, nonatomic) NSString *requestId;

@end
