//
//  PushManager.h
//  PushOC
//
//  Created by wsong on 2017/1/3.
//  Copyright © 2017年 wsong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PushInfoBlockType)(NSDictionary *info);

@interface PushManager : NSObject

+ (instancetype)shared;

- (void)registerDeviceTokenBlock:(void (^)(NSString *deviceToken))deviceTokenBlock
               registerFailBlock:(void (^)(NSError *error))registerFailBlock
        receiveInForegroundBlock:(PushInfoBlockType)receiveInForegroundBlock
            receiveInBannerBlock:(PushInfoBlockType)receiveInBannerBlock
        receiveInBackgroundBlock:(PushInfoBlockType)receiveInBackgroundBlock;

@end
