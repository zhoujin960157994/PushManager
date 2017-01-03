//
//  AppDelegate.m
//  PushOC
//
//  Created by wsong on 2017/1/3.
//  Copyright © 2017年 wsong. All rights reserved.
//

#import "AppDelegate.h"
#import "PushManager.h"
#import "GeTuiSdk.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 第三方就随便使用了
    [GeTuiSdk startSdkWithAppId:@"XhpxdnCk5G7gjhnmCjhQJ4" appKey:@"GZBN9reeXK9CHyFDLkjat1" appSecret:@"cz8XRebHWpAABPc9pi3aH3" delegate:nil];
    
    [[PushManager shared] registerDeviceTokenBlock:^(NSString *deviceToken) {
        NSLog(@"deviceToken: %@", deviceToken);
        [GeTuiSdk registerDeviceToken:deviceToken];
        
    } registerFailBlock:^(NSError *error) {
        NSLog(@"%@", error);
    } receiveInForegroundBlock:^(NSDictionary *info) {
        NSLog(@"前台");
    } receiveInBannerBlock:^(NSDictionary *info) {
        NSLog(@"横幅");
        // receiveInBackgroundBlock，后台推送消息时 content-available 一定要为1
    } receiveInBackgroundBlock:^(NSDictionary *info) {
        NSLog(@"后台");
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
