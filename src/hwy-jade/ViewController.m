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
    webview.scrollView.bounces = NO;
    [webview loadRequest:request];
    //[webview initView];
    
    [self setUpShare];
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
        
        NSLog(@"scheme call %@", [url absoluteString]);
        NSArray *params = [query componentsSeparatedByString:@"&"];
        NSMutableDictionary *requestParams = [NSMutableDictionary dictionaryWithCapacity:10] ;
        id i;
        for (i in params) {
            NSArray *tmp = [i componentsSeparatedByString:@"="];
            NSString *key = [[tmp firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[tmp lastObject] stringByRemovingPercentEncoding];
            [requestParams setObject:value forKey:key];
        }
        
        
        NSData *paramsData = [[requestParams objectForKey:@"params"] dataUsingEncoding:NSUTF8StringEncoding]; //NSASCIIStringEncoding
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:paramsData options:(NSJSONReadingAllowFragments) error:&error];
        
        //login  share pay scan
        if ([contoller isEqualToString:@"login"] && [@"weixin" isEqualToString:[requestParams objectForKey:@"act"]]) {
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
        if ([contoller isEqualToString:@"pay"] && [@"weixin" isEqualToString:[requestParams objectForKey:@"act"]]) {
            //微信支付
            
            jsCallback = [requestParams objectForKey:@"callback"];
            if (jsonObject ==nil && jsCallback != nil) {
                NSString *jsExec = [NSString stringWithFormat:@"%@(%@)",jsCallback,@"{errCode:-1}"];
                [webView stringByEvaluatingJavaScriptFromString:jsExec];
                return NO;
            }
            PayReq *request = [[PayReq alloc] init];
            request.partnerId = [jsonObject objectForKey:@"partnerid"];
            request.prepayId= [jsonObject objectForKey:@"prepayid"];
            request.package = @"Sign=WXPay";
            request.nonceStr= [jsonObject objectForKey:@"noncestr"];
            request.timeStamp = [[jsonObject objectForKey:@"timestamp"] intValue];
            request.sign= [jsonObject objectForKey:@"sign"];
            [WXApi sendReq:request];
        }
        
        if ([contoller isEqualToString:@"share"]) {
            //分享
            shareContent = jsonObject;
            shareBar.hidden = NO;
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
        //有回调

        NSString * jsString = [NSString stringWithFormat:@"{errCode:%d}",response.errCode];
        NSString * callback = [NSString stringWithFormat:@"%@(%@)",jsCallback, jsString];
        [webview stringByEvaluatingJavaScriptFromString:callback];
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
            NSString * callback = [NSString stringWithFormat:@"%@(%@)",jsCallback, jsString];
            [webview stringByEvaluatingJavaScriptFromString:callback];
            
        }
    }
}

/**
 * 设置分享
 **/

-(void) setUpShare {
    float bodyWidth = self.view.bounds.size.width;
    float bodyHeight = self.view.bounds.size.height;
    float buttonSize = 64.0f;
    float sharBarSize  = 80.0f;
    float cancelBoxSize = sharBarSize - buttonSize;
    shareBar = [[UIView alloc] initWithFrame:CGRectMake(0, bodyHeight - sharBarSize, bodyWidth, sharBarSize)];
    shareBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    
    float firstStart = ((bodyWidth / 2 )  - (buttonSize / 2)) / 2;
    float bntPos = (sharBarSize - buttonSize) / 2;
    
    shareWxFriend = [[UIImageView alloc] initWithFrame:CGRectMake(firstStart, bntPos , buttonSize, buttonSize)];
    [shareWxFriend setImage:[UIImage imageNamed:@"WxFriend"]];
    shareWxFriend.backgroundColor = [UIColor clearColor];
    [shareBar addSubview:shareWxFriend];
    
    shareWxCircle = [[UIImageView alloc] initWithFrame:CGRectMake(firstStart + (bodyWidth / 2 ), bntPos , buttonSize, buttonSize)];
    [shareWxCircle setImage:[UIImage imageNamed:@"WxCircle"]];
    shareWxCircle.backgroundColor = [UIColor clearColor];
    [shareBar addSubview:shareWxCircle];
    shareBar.hidden = YES;
    [self.view addSubview:shareBar];
}

@end
