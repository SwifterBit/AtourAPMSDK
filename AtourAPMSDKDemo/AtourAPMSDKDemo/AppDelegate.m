//
//  AppDelegate.m
//  AtourAPMSDKDemo
//
//  Created by sue on 2020/12/8.
//

#import "AppDelegate.h"
#import <AtourAPMSDK/AtourAPMManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[AtourAPMManager sharedInstance] start];
    });
   
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[AtourAPMManager sharedInstance] stop];
}

-(void)applicationWillTerminate:(UIApplication *)application {
    [[AtourAPMManager sharedInstance] stop];
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
