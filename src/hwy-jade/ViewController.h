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
//#define DEBUG 1

#define HOST "app.hong5ye.com"
#define PORTAL "http://app.hong5ye.com/webapp/index.html"
#define PORTAL_DEBUG "http://app.hong5ye.com/test/webapp/index.html"

#define IOS8x ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

@interface ViewController : UIViewController<UIWebViewDelegate>
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
    NSTimer *timer;
    UIButton *cancel;
    
    NSTimer *loadingTimer;
    UIWebView *loading; 
    
    AVCaptureSession * session;//二维码输入输出的中间桥梁
    
    UIView * scanBox;
    UIButton* scanClose;
    UIView * scanArea;
    UILabel* scanTips;
    
    
    
}
-(void) onReq:(BaseReq*)req;
-(void) onResp:(BaseResp*)resp ;
@end

