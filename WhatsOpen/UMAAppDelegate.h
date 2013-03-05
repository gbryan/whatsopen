//
//  UMAAppDelegate.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/28/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FactualSDK/FactualAPI.h>
#import "queryController.h"
#import "keys.h"

@class queryController;
@interface UMAAppDelegate : UIResponder <UIApplicationDelegate>
{
    FactualAPI *_apiObject;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) FactualAPI *apiObject;
@property (nonatomic, readonly) queryController *queryControllerShared;

+(FactualAPI *) getAPIObject;
+(UMAAppDelegate *) getDelegate;
+(queryController *)queryControllerShared;
@end
