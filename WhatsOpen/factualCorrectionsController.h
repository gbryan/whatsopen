//
//  factualCorrectionsController.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 3/9/13.
//  Copyright (c) 2013 UNC-CH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FactualSDK/FactualAPI.h>
#import "keys.h"
#import "locationServices.h"
#import "restaurant.h"
#import "UMAAppDelegate.h"

@interface factualCorrectionsController : NSObject <FactualAPIDelegate>
@property (retain, nonatomic) FactualAPIRequest *apiRequest;
@property (nonatomic, retain) FactualQueryResult *queryResult;
@property (nonatomic, strong) NSArray* problemTypeRowLabels;

-(void)flagRestaurantWithID:(NSString* )factualID problemType:(NSInteger)problemType comment:(NSString* )comment reference:(NSString* )reference;
@end
