//
//  UMAAppDelegate.m
//  WhatsOpen
//
//  Created by Bryan Gaston on 12/28/12.
//  Copyright (c) 2012 UNC-CH. All rights reserved.
//

#import "UMAAppDelegate.h"
#import "keys.h"

@implementation UMAAppDelegate

@synthesize apiObject=_apiObject;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //set navigation bar tint to black
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.0 green:0.1 blue:0.45 alpha:1.0]];
    
    _apiObject = [[FactualAPI alloc] initWithAPIKey:FACTUAL_KEY secret:FACTUAL_SECRET];
    
    // Override point for customization after application launch.
    return YES;
}

+(FactualAPI*) getAPIObject {
    UIApplication* app = [UIApplication sharedApplication];
    return ((UMAAppDelegate*)app.delegate).apiObject;
}

//to-do: I added this but don't know if it's necessary
+(UMAAppDelegate*) getDelegate {
    UIApplication* app = [UIApplication sharedApplication];
    return ((UMAAppDelegate*)app.delegate);
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
