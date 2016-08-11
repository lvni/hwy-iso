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
    NSLog(@"初始化导航栏");
    navigationBar = [[UIView alloc]initWithFrame:CGRectMake(0, statusBarHeight, self.view.bounds.size.width, 50.0f)];
    backItem = [[UIButton alloc]initWithFrame:CGRectMake(10.0f,  15.0f , 20.0f, 32.0f)];
    [backItem setImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    [backItem setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [navigationBar addSubview:backItem];
    
    homeItem = [[UIButton alloc]initWithFrame:CGRectMake(40.0f,  15.0f , 40.0f, 32.0f)];
    [homeItem setTitle:@"首页" forState:UIControlStateNormal];
    [homeItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [navigationBar addSubview:homeItem];
    navigationBar.backgroundColor = [UIColor whiteColor];
    navigationBar.hidden = YES;
    [self.view addSubview:navigationBar];
    
    [backItem addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchDown];
    [homeItem addTarget:self action:@selector(homeClick:) forControlEvents:UIControlEventTouchDown];
}
- (void)backClick:(UIButton *)sender {
    NSLog(@"点击返回了");
    [webview goBack];
}

- (void)homeClick:(UIButton *)sender {
    NSString *s = @PORTAL;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:s]];
    [webview loadRequest:request];
    
}

-(void) hideNaviBar {
    navigationBar.hidden = YES;
    //webview 高度调整
    [self restWebViewHeight];
}

-(void) showNaviBar {
    navigationBar.hidden = NO;
    //webview 高度调整
    [self restWebViewHeight];
}

-(void) restWebViewHeight {
    float marginTop = statusBarHeight;
    if (navigationBar.hidden == NO) {
        marginTop = navigationBar.bounds.size.height;
    }
    [webview setFrame:CGRectMake(0, marginTop, self.view.bounds.size.width, self.view.bounds.size.height - marginTop)];
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
    preHost = webview.request.URL.host;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *curlHost = webview.request.URL.host;
    if ([preHost isEqualToString:curlHost]) {
        //链接没有变化
        return ;
    }
    if (curlHost.length > 3 && ![curlHost isEqualToString:officeHost ]) {
        [self showNaviBar];
    } else {
        [self hideNaviBar];
    }
    
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError:%@", error);
}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //NSLog(@"yes :%@",[request allHTTPHeaderFields]);
    return YES;
}

//初始化，设置ua
+ (void)initialize {
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    UIWebView* tmpwebview = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [tmpwebview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newUagent = [NSString stringWithFormat:@"%@ hwy/%@",secretAgent, version];
    NSDictionary *dictionnary = [[NSDictionary alloc]initWithObjectsAndKeys:newUagent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}



@end
