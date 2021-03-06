//
//  restaurant.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/22/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SORT_NAME @"name"
#define SORT_DISTANCE @"proximitySort"
#define SORT_RATING @"ratingSort"
#define SORT_PRICE_LEVEL @"priceLevel"
#define SORT_OPEN_NEXT @"openNextSort"
#define SORT_CLOSED_NEXT @"closingNextSort"
#define FILTER_PARKING_FREE @"parkingFree"
#define FILTER_CASH_ONLY @"cashOnly"
#define FILTER_SERVES_ALCOHOL @"servesAlcohol"
#define FILTER_TAKEOUT @"takeout"

@interface restaurant : NSObject

@property (strong, nonatomic) NSString *googleID;
@property (strong, nonatomic) NSString *factualID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *proximity;
@property (nonatomic) float proximitySort;
@property (strong, nonatomic) NSString *openHours;
@property (strong, nonatomic) NSString *ratingSort;
@property (strong, nonatomic) UIImage *ratingImage;
@property (assign, nonatomic) int priceLevel;
@property (strong, nonatomic) NSString *priceLevelDisplay;
@property (strong, nonatomic) UIImage *priceIcon;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *parkingFree;
@property (strong, nonatomic) NSString *cashOnly;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSArray *cuisine;
@property (strong, nonatomic) NSString *cuisineLabel;
//@property (strong, nonatomic) NSString *hasFullBar;
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
@property (assign, nonatomic) BOOL openingSoon;
@property (assign, nonatomic) BOOL closingSoon;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *locality; //=city in U.S.
@property (strong, nonatomic) NSString *region; //=state in U.S.
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *whichTab;
@property (strong, nonatomic) NSString *detailsDisplay;

@end
