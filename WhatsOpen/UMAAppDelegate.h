//
//  UMAAppDelegate.h
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/28/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FactualSDK/FactualAPI.h>

@interface UMAAppDelegate : UIResponder <UIApplicationDelegate>
{
    FactualAPI* _apiObject;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) FactualAPI* apiObject;

+(FactualAPI*) getAPIObject;
+(UMAAppDelegate*) getDelegate;

@end
