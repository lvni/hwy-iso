//
//  ViewController.h
//  hwy-jade
//
//  Created by hwy on 16/8/6.
//  Copyright © 2016年 hwy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "view/HWebView.h"
#import "include/models/Utils.h"
#import "WXApi.h"
#import <AVFoundation/AVFoundation.h>
#define DEBUG 0

#ifdef DEBUG
#define PORTAL "http://192.168.1.161/webapp/index.html"
#define HOST "192.168.1.161"
#else
#define HOST "app.hong5ye.com"
#define PORTAL "http://app.hong5ye.com/webapp/index.html"
#endif

@interface ViewController : UIViewController<UIWebViewDelegate, AVCaptureMetadataOutputObjectsDelegate>
{
    
    //返回和关闭按钮
    UIButton * backItem; //返回按钮
    UIButton * homeItem; //首页按钮
    
    UIImageView * shareWxFriend; //分享微信朋友
    UIImageView * shareWxCircle; //分享微信朋友圈
    
    UIView * navigationBar ; // 导航栏
    UIView * shareBar ; //分享栏
    
    HWebView *webview;
    NSString *officeHost;
    NSString *preHost;
    NSString *jsCallback ;
    float statusBarHeight;
    NSDictionary *shareContent;
    
    
    
}
-(void) onReq:(BaseReq*)req;
-(void) onResp:(BaseResp*)resp ;
@end

