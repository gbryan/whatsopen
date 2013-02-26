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

@class queryController;
@class listViewController;
@interface UMAAppDelegate : UIResponder <UIApplicationDelegate>
{
    FactualAPI *_apiObject;
//    listViewController *_listView;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) FactualAPI *apiObject;

+(FactualAPI *) getAPIObject;
+(UMAAppDelegate *) getDelegate;
@end
