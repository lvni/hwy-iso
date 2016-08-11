//
//  ViewController.m
//  hwy-jade
//
//  Created by hwy on 16/8/6.
//  Copyright © 2016年 hwy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取状态栏的高度
    
    
    officeHost=@HOST;
    
    // Do any additional setup after loading the view, typically from a nib.
    [self setStatusBar];
    [self initNaviBar];
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    statusBarHeight = rectStatus.size.height;
    
    //初始化webview大小
    webview = [[HWebView alloc] initWithFrame:CGRectMake(0.0f,statusBarHeight,self.view.bounds.size.width,self.view.bounds.size.height - statusBarHeight)];
    NSString *s = @PORTAL;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:s]];
    [self.view addSubview:webview];
    [webview setDelegate:self];
    [webview loadRequest:request];
    //[webview initView];
    
    
}

-(void) initNaviBar {
    //初始化状态栏
    return ;
    //NSLog(@"初始化导航栏");
    navigationBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    backItem = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 56, 54)];
    [backItem setImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    [backItem setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    navigationBar.backgroundColor = [UIColor redColor];
    //[navigationBar addSubview:backItem];
    navigationBar.hidden = YES;
    //[self.view addSubview:navigationBar];
    //UIBarButtonItem * leftItemBar = [[UIBarButtonItem alloc]initWithCustomView:navigationBar];
    //self.navigationItem.leftBarButtonItem = leftItemBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setStatusBar{
    //CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    //float statusBarHeight = rectStatus.size.height;
    //UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, statusBarHeight, self.view.bounds.size.width, statusBarHeight)];
    //[self.view addSubview:statusBar]; //占位
}

- (void )webViewDidStartLoad:(UIWebView  *)webView {
    NSString *curlHost = webview.request.URL.host;
    NSLog(@"加载web url %@", curlHost);
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *curlHost = webview.request.URL.host;
    if (curlHost.length > 3 && ![curlHost isEqualToString:officeHost ]) {
        //不是官方地址，需要添加返回按钮
        //navigationBar.hidden = NO;
        //调整web高度
        //[webview setFrame:CGRectMake(0.0f,80.0f,self.view.bounds.size.width,self.view.bounds.size.height)];
    }
    
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError:%@", error);
}


@end
