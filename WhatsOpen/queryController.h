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

@interface queryController : NSObject <FactualAPIDelegate>

//to-do: should these really be "retain"?
@property (nonatomic, retain) FactualQueryResult *queryResult;
@property (nonatomic, strong) NSArray *queryCategories;
@property (nonatomic, strong) NSMutableArray *openNow;
@property (nonatomic, strong) NSMutableArray *openLater;
@property (nonatomic, strong) NSMutableArray *hoursUnknown;
@property (nonatomic, strong) NSString *farthestPlaceString;
@property (nonatomic, strong) restaurant *detailRestaurant;
//@property (nonatomic) BOOL lastResultWasNull;
@property (nonatomic) BOOL noMoreResults;

-(void)refreshRestaurants;
-(void)appendNewRestaurants;
-(void)getRestaurantDetail:(restaurant *)restaurantObject;
+(void)flagRestaurant:(restaurant *)restaurantObject withComment:(NSString *)comment reference:(NSString *)reference;
@end
