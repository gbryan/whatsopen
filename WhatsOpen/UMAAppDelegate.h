//
//  UMAAppDelegate.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/28/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FactualSDK/FactualAPI.h>
#import "keys.h"
#import "queryController.h"
#import "listViewController.h"

@class queryController;
@class listViewController;
@interface UMAAppDelegate : UIResponder <UIApplicationDelegate>
{
    FactualAPI *_apiObject;
    queryController *_queryControl;
    listViewController *_listView;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) FactualAPI *apiObject;
@property (nonatomic, readonly) queryController *queryControl;
@property (nonatomic, readonly) listViewController *listView;

+(FactualAPI *) getAPIObject;
+(UMAAppDelegate *) getDelegate;
+(queryController *) getQueryController;
+(listViewController *) getListController;
@end
