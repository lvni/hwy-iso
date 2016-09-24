//
//  AppDelegate.m
//  hwy-jade
//
//  Created by hwy on 16/8/6.
//  Copyright © 2016年 hwy. All rights reserved.
//

#import "AppDelegate.h"
#import "XGPush.h"
#import "XGSetting.h"

#define _IPHONE80_ 80000

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)registerPushForIOS8{
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    //[acceptAction release];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    //[inviteCategory release];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}
-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //注册微信
    //ViewController *rootVC = [[ViewController alloc] init];
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [WXApi registerApp:@"wxbbab02d24a62a8a2"];
    
    //注册腾讯信鸽推送
    
    [XGPush startApp:2200230560 appKey:@"IDP8J2916ZTK"];
    
    if (launchOptions != nil && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self handelPush:(NSDictionary*)[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] pushType:0];
    }
    [XGPush handleLaunching:launchOptions];
    //NSLog(@"[XGPush lvni]%@",launchOptions);
    
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(sysVer < 8){
        [self registerPush];
    }
    else{
        [self registerPushForIOS8];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(nonnull NSURL *)url {
    if ([url.host isEqualToString:@"safepay"]) {
        UIViewController * rootcv = self.window.rootViewController;
        if ([rootcv isKindOfClass:[ViewController class]]) {
            ViewController * vc = (ViewController *)rootcv;
            [vc handleAlipay:url ];
        }
        return YES;
    } else {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    if ([url.host isEqualToString:@"safepay"]) {
        UIViewController * rootcv = self.window.rootViewController;
        if ([rootcv isKindOfClass:[ViewController class]]) {
            ViewController * vc = (ViewController *)rootcv;
            [vc handleAlipay:url ];
        }
        return YES;
    } else {
        return [WXApi handleOpenURL:url delegate:self];
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    //notification是发送推送时传入的字典信息
    [XGPush localNotificationAtFrontEnd:notification userInfoKey:@"clockID" userInfoValue:@"myid"];
    
    //删除推送列表中的这一条
    [XGPush delLocalNotification:notification];
    //[XGPush delLocalNotification:@"clockID" userInfoValue:@"myid"];
    
    //清空推送列表
    //[XGPush clearLocalNotifications];
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_

//注册UserNotification成功的回调
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //用户已经允许接收以下类型的推送
    //UIUserNotificationType allowedTypes = [notificationSettings types];
    
}

//按钮点击事件回调
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    if([identifier isEqualToString:@"ACCEPT_IDENTIFIER"]){
        NSLog(@"ACCEPT_IDENTIFIER is clicked");
        
    }
    
    completionHandler();
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //NSString * deviceTokenStr = [XGPush registerDevice:deviceToken];
    NSString * deviceTokenStr = nil;
    void (^successBlock)(void) = ^(void){

    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush Demo]register errorBlock");
    };
    
    // 设置账号 测试用
    //[XGPush setAccount:@"hwy_dev"];
    
    //注册设备
    deviceTokenStr = [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];
    UIViewController * rootcv = self.window.rootViewController;
    if ([rootcv isKindOfClass:[ViewController class]]) {
        ViewController * vc = (ViewController *)rootcv;
        [vc registerPushToken: deviceTokenStr];
    }
    //如果不需要回调
    //[XGPush registerDevice:deviceToken];
    
    //打印获取的deviceToken的字符串
    NSLog(@"[XGPush Demo] deviceTokenStr is %@",deviceTokenStr);
}

//如果deviceToken获取不到会进入此事件
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@",err];
    
    NSLog(@"[XGPush Demo]%@",str);
    
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    //if(userInfo) {
        //[userInfo setValue:@"true" forKey:@"app_runing"];
    //}
    
    [self handelPush:userInfo pushType:1];
    //推送反馈(app运行时)
    [XGPush handleReceiveNotification:userInfo];
    
}


//控制器控制微信事件
-(void) onReq:(BaseReq*)req {
    UIViewController * rootcv = self.window.rootViewController;
    if ([rootcv isKindOfClass:[ViewController class]]) {
        ViewController * vc = (ViewController *)rootcv;
        [vc onReq: req ];
    }
}

-(void) onResp:(BaseResp*)resp {
    UIViewController * rootcv = self.window.rootViewController;
    if ([rootcv isKindOfClass:[ViewController class]]) {
        ViewController * vc = (ViewController *)rootcv;
        [vc onResp: resp ];
    }
}

//处理push
-(void) handelPush:(NSDictionary*)userInfo pushType:(int) type{
    UIViewController * rootcv = self.window.rootViewController;
    if ([rootcv isKindOfClass:[ViewController class]]) {
        ViewController * vc = (ViewController *)rootcv;
        [vc handelPushContent:userInfo pushType:type];
    }
}


@end
