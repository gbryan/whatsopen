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
@property (strong, nonatomic) NSString *priceLevel;
@property (strong, nonatomic) NSString *phoneNumber;

@end
