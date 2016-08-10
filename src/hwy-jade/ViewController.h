//
//  ViewController.h
//  hwy-jade
//
//  Created by hwy on 16/8/6.
//  Copyright © 2016年 hwy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "view/HWebView.h"

//#define DEBUG 0

#ifdef DEBUG
#define HOST "app.hong5ye.com"
#define PORTAL "http://app.hong5ye.com/webapp/index.html";
#else
#define PORTAL "http://app.hong5ye.com/webapp/index.html";
#define HOST "app.hong5ye.com"
#endif

@interface ViewController : UIViewController<UIWebViewDelegate>
{
    
    //返回和关闭按钮
    UIButton * backItem; //返回按钮
    UIButton * homeItem; //首页按钮
    
    UIView * navigationBar ; // 导航栏
    HWebView *webview;
    NSString *officeHost;
    float statusBarHeight;
    
}

@end

