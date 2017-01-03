### 简介
- 自ios8开始，推送方法略有改变，ios10更是使用UserNotification，导致推送回调方法不统一，要针对平台进行适配，方法零散；本工具就是为了解决推送碎片问题，将注册(deviceToken)与接收推送方法回调通过block统一返回；如果之前实现了推送等系列方法也不与该工具冲突；该工具采用的是后台抓取回调，因此要配置后台抓取，配置方法详见http://blog.csdn.net/xiao562994291/article/details/51911670
### 使用
```objc
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
```
