//
//  ViewController.m
//  hwy-jade
//
//  Created by hwy on 16/8/6.
//  Copyright © 2016年 hwy. All rights reserved.
//

#import "ViewController.h"
#import "WXApi.h"
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
    //return ;
    NSLog(@"初始化导航栏");
    navigationBar = [[UIView alloc]initWithFrame:CGRectMake(0, statusBarHeight, self.view.bounds.size.width, 50.0f)];
    backItem = [[UIButton alloc]initWithFrame:CGRectMake(10.0f,  15.0f , 20.0f, 30.0f)];
    [backItem setImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    [navigationBar addSubview:backItem];
    
    homeItem = [[UIButton alloc]initWithFrame:CGRectMake(30.0f,  15.0f , 40.0f, 30.0f)];
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
    
    //return ;
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
    
    //return;
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
    //return;
    
    
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError:%@", error);
    
}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //NSLog(@"yes :%@",[request allHTTPHeaderFields]);
    NSURL *url = [request URL];
    NSString *scheme = [url scheme];
    NSString *contoller = [url host];
    NSString *query = [url query];
    //处理自定义的协议
    if ([scheme isEqualToString:@"hwy"]) {
        NSLog(@"query is %@", query);
        NSArray *params = [query componentsSeparatedByString:@"&"];
        NSMutableDictionary *requestParams = [NSMutableDictionary dictionaryWithCapacity:10] ;
        id i;
        for (i in params) {
            NSLog(@"were %@", i);
            NSArray *tmp = [i componentsSeparatedByString:@"="];
            if ([tmp count] > 1) {

                [requestParams setValue:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:0]];
            }
        }
        
        //login  share pay scan
        if ([contoller isEqualToString:@"login"]) {
            //设置回调
            jsCallback = [requestParams objectForKey:@"callback"];
            //构造SendAuthReq结构体
            if ([@"weixin" isEqualToString: [requestParams objectForKey:@"act"]]) {
                SendAuthReq* req = [[SendAuthReq alloc ] init ];
                req.scope = @"snsapi_userinfo" ;
                req.state = @"123" ;
                //第三方向微信终端发送一个SendAuthReq消息结构
                [WXApi sendReq:req];
            }
            
            
        }
        
        return NO;
    }
    
    //判断是官网则不显示按钮
    if (contoller.length > 3 && ![contoller isEqualToString:officeHost ]) {
        [self showNaviBar];
    } else {
        [self hideNaviBar];
    }
    
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

-(void) onReq:(BaseReq*)req {
    
}

-(void) onResp:(BaseResp*)resp {
    
    NSLog(@"weixin back %@",[resp errStr]);
    if ([resp isKindOfClass: [PayResp class]]){
        //支付回调
        PayResp* response = (PayResp*)resp;
        //调用前端回调接口
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                break;
            default:
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
    
    //登陆回调
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp* tresp = (SendAuthResp*)resp ;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10] ;
    
        [params setObject:[NSNumber numberWithUnsignedInt:[tresp errCode]] forKey:@"errCode"];
        if ([tresp errStr]) {
            [params setObject:[tresp errStr] forKey:@"errStr"];
        }
        if ([tresp code]) {
            [params setObject:[tresp code] forKey:@"code"];
        }
        
        if ([jsCallback length] > 3) {
            //有回调
            NSData *data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
            NSString * jsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(jsString);
            NSString * callback = [NSString stringWithFormat:@"%@(%@)",jsCallback, jsString];
            [webview stringByEvaluatingJavaScriptFromString:callback];
            
        }
    }
}

@end
