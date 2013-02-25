//
//  queryController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 2/22/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FactualSDK/FactualAPI.h>
#import <FactualSDK/FactualQuery.h>
#import "keys.h"
#import "locationServices.h"
#import "restaurant.h"
#import "listViewController.h"
#import "UMAAppDelegate.h"

@class locationServices;
@interface queryController : NSObject <FactualAPIDelegate>
{
    FactualAPIRequest *_activeRequest;
    locationServices *_locationService;
}

//to-do: should these really be "retain"?
@property (nonatomic, retain) FactualQueryResult *queryResult;
@property (nonatomic, strong) NSArray *queryCategories;
@property (nonatomic, strong) NSMutableArray *openNow;
@property (nonatomic, strong) NSMutableArray *openLater;
@property (nonatomic, strong) NSString *farthestPlaceString;

//to-do: am I still manipulating these such that they need to be mutable arrays?
-(void)getRestaurants;
-(NSMutableArray *)getOpenNow;
-(NSMutableArray *)getOpenLater;
@end
