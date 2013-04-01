//
//  queryController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/22/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FactualSDK/FactualAPI.h>
#import "keys.h"
#import "locationServices.h"
#import "restaurant.h"
#import "UMAAppDelegate.h"

#define QUERY_INTENTION_MEAL @"Meals"
#define QUERY_INTENTION_DESSERT @"Desserts"
#define QUERY_INTENTION_DRINK @"Drinks"

@interface queryController : NSObject <FactualAPIDelegate>

@property (nonatomic, retain) FactualAPIRequest *apiRequest;
@property (nonatomic, retain) FactualQueryResult *queryResult;
@property (nonatomic, strong) NSArray *queryCategories;
@property (nonatomic, strong) NSMutableArray *openNow;
@property (nonatomic, strong) NSMutableArray *openLater;
@property (nonatomic, strong) NSMutableArray *hoursUnknown;
@property (nonatomic, strong) NSString *farthestPlaceString;
@property (nonatomic, strong) restaurant *detailRestaurant;
@property (nonatomic) BOOL noMoreResults;
@property (nonatomic) CLLocationCoordinate2D deviceLocation;
@property (nonatomic, strong) NSString *openNowSort;
@property (nonatomic, strong) NSString *openLaterSort;
@property (nonatomic, strong) NSString *hoursUnknownSort;
@property (nonatomic, strong) NSString *queryIntention;
@property (nonatomic) BOOL filterAcceptsCC;
@property (nonatomic) BOOL filterFreeParking;
@property (nonatomic) BOOL filterTakeout;
@property (nonatomic) BOOL filterServesAlcohol;

-(void)refreshRestaurants;
-(void)appendNewRestaurants;
-(void)getRestaurantDetail:(restaurant *)restaurantObject;
-(void)sortArrayNamed:(NSString *)array ByKey:(NSString *)sortKey;
@end
