//
//  UMAAppDelegate.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/28/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import "UMAAppDelegate.h"

@implementation UMAAppDelegate
{
    NSInteger _numTimesAppWasActive;
}
@synthesize apiObject = _apiObject;
@synthesize queryControllerShared = _queryControllerShared;
@synthesize locationServiceShared = _locationServiceShared;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _numTimesAppWasActive = 1;
    
    //set navigation bar and toolbar tint to dark blue
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0]];
    [[UIToolbar appearance] setTintColor:[UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0]];
    
    _apiObject = [[FactualAPI alloc] initWithAPIKey:FACTUAL_KEY secret:FACTUAL_SECRET];
    _queryControllerShared = [[queryController alloc]init];
    _locationServiceShared = [[locationServices alloc]init];
    
    // Override point for customization after application launch.
    return YES;
}

+(FactualAPI *) getAPIObject
{
    UIApplication* app = [UIApplication sharedApplication];
    return ((UMAAppDelegate*)app.delegate).apiObject;
}

+(UMAAppDelegate *) getDelegate
{
    UIApplication* app = [UIApplication sharedApplication];
    return ((UMAAppDelegate*)app.delegate);
}

+(queryController *)queryControllerShared
{    
    UIApplication* app = [UIApplication sharedApplication];
    return ((UMAAppDelegate *)app.delegate).queryControllerShared;
}

+(locationServices *)locationServiceShared
{
    UIApplication* app = [UIApplication sharedApplication];
    return ((UMAAppDelegate *)app.delegate).locationServiceShared;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //to-do: this runs twice, producing duplicate results upon first ever app load (when user allows location first time)
    //to-do: make spinner animate when refreshing upon becoming active again
    //Reload restaurants list (do not run if this is initial app load)
    if (_numTimesAppWasActive > 1)
    {
        NSLog(@"refreshRestaurants called from app delegate");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startSpinner"
                                                            object:nil];
        [[self queryControllerShared]refreshRestaurants];
    }
    
    _numTimesAppWasActive++;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
