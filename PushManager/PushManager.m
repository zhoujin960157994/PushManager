//
//  PushManager.m
//  PushOC
//
//  Created by wsong on 2017/1/3.
//  Copyright © 2017年 wsong. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#import <objc/runtime.h>
#import "PushManager.h"
// 引入你的app代理
#import "AppDelegate.h"

typedef void (^DeviceTokenBlock)(NSString *);
typedef void (^RegisterFailBlockType)(NSError *);

@interface PushManager () <UNUserNotificationCenterDelegate>

@property (nonatomic, copy) DeviceTokenBlock deviceTokenBlock;
@property (nonatomic, copy) RegisterFailBlockType registerFailBlock;
@property (nonatomic, copy) PushInfoBlockType receiveInForegroundBlock;
@property (nonatomic, copy) PushInfoBlockType receiveInBannerBlock;
@property (nonatomic, copy) PushInfoBlockType receiveInBackgroundBlock;

@end

@implementation PushManager

static id _instance = nil;

+ (instancetype)shared {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

+ (id)copyWithZone:(struct _NSZone *)zone{
    return  _instance;
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone{
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}

/** 使用receiveInBackgroundBlock，后台推送消息时 content-available 一定要为1 */
- (void)registerDeviceTokenBlock:(void (^)(NSString *deviceToken))deviceTokenBlock
               registerFailBlock:(void (^)(NSError *error))registerFailBlock
        receiveInForegroundBlock:(PushInfoBlockType)receiveInForegroundBlock
            receiveInBannerBlock:(PushInfoBlockType)receiveInBannerBlock
        receiveInBackgroundBlock:(PushInfoBlockType)receiveInBackgroundBlock {
    
    self.deviceTokenBlock = deviceTokenBlock;
    self.registerFailBlock = registerFailBlock;
    self.receiveInForegroundBlock = receiveInForegroundBlock;
    self.receiveInBannerBlock = receiveInBannerBlock;
    self.receiveInBackgroundBlock = receiveInBackgroundBlock;
    
    if (receiveInBackgroundBlock) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:
         UIApplicationBackgroundFetchIntervalMinimum];
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        center.delegate = self;
        [center requestAuthorizationWithOptions:
         (UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {}];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else if ([UIDevice currentDevice].systemVersion.floatValue >= 8) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    }    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    if (self.receiveInForegroundBlock) {
        self.receiveInForegroundBlock(notification.request.content.userInfo);
    }
    completionHandler(kNilOptions);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    if (self.receiveInBannerBlock) {
        self.receiveInBannerBlock(response.notification.request.content.userInfo);
    }
    completionHandler();
}

@end

@interface AppDelegate ()

@property (nonatomic, assign) BOOL deviceTokenSELNotImp;
@property (nonatomic, assign) BOOL RegisterFailSELNotImp;
@property (nonatomic, assign) BOOL ReveiveNotificationSELNotImp;

@end

// 改为你的app代理
@implementation AppDelegate (Push)

static BOOL deviceTokenSELIsImp = YES;
static BOOL registerFailSELIsImp = YES;
static BOOL reveiveNotificationSELIsImp = YES;

#define DEVICE_TOKEN_SEL @selector(app:didRegisterForRemoteNotificationsWithDeviceToken:)
#define REGISTER_FAIL_SEL @selector(app:didFailToRegisterForRemoteNotificationsWithError:)
#define REVEIVE_NOTIFICATION_SEL @selector(app:didReceiveRemoteNotification:fetchCompletionHandler:)
#define TYPES "v@:@@"

+ (void)exchangeSelectorSel1:(SEL)sel1 withSel2:(SEL)sel2 {
    method_exchangeImplementations(class_getInstanceMethod(self, sel1),
                                   class_getInstanceMethod(self, sel2));
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    if (@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) == sel) {
        class_addMethod(self, sel, [self instanceMethodForSelector:DEVICE_TOKEN_SEL], TYPES);
        deviceTokenSELIsImp = NO;
    } else if (@selector(application:didFailToRegisterForRemoteNotificationsWithError:) == sel) {
        class_addMethod(self, sel, [self instanceMethodForSelector:REGISTER_FAIL_SEL], TYPES);
        registerFailSELIsImp = NO;
    } else if (@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:) == sel) {
        class_addMethod(self, sel, [self instanceMethodForSelector:REVEIVE_NOTIFICATION_SEL], "v@:@@@");
        reveiveNotificationSELIsImp = NO;
    }
    
    return [super resolveInstanceMethod:sel];
}

+ (void)load {
    [self exchangeSelectorSel1:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)
                      withSel2:@selector(app:didRegisterForRemoteNotificationsWithDeviceToken:)];
    
    [self exchangeSelectorSel1:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)
                      withSel2:@selector(app:didFailToRegisterForRemoteNotificationsWithError:)];
    
    [self exchangeSelectorSel1:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)
                      withSel2:@selector(app:didReceiveRemoteNotification:fetchCompletionHandler:)];
}

- (void)app:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (reveiveNotificationSELIsImp) {
        [self app:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
    
    PushInfoBlockType pushInfoBlock = nil;
    
    switch (application.applicationState) {
        case UIApplicationStateActive:
            pushInfoBlock = [PushManager shared].receiveInForegroundBlock;
            break;
        case UIApplicationStateInactive:
            pushInfoBlock = [PushManager shared].receiveInBannerBlock;
            break;
        case UIApplicationStateBackground:
            pushInfoBlock = [PushManager shared].receiveInBackgroundBlock;
            break;
    }
    
    if (pushInfoBlock) {
        pushInfoBlock(userInfo);
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)app:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (registerFailSELIsImp) {
        [self app:application didFailToRegisterForRemoteNotificationsWithError:error];
    }
    
    if ([PushManager shared].registerFailBlock) {
        [PushManager shared].registerFailBlock(error);
    }
}

- (void)app:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (deviceTokenSELIsImp) {
        [self app:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }
    
    if ([PushManager shared].deviceTokenBlock) {
        [PushManager shared].deviceTokenBlock([[deviceToken.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]);
    }
}

@end
