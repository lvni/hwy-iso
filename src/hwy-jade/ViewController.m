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
    [self setUpLoading];
}

//设置loading
-(void) setUpLoading {
    float loatindFormSize = 108.0f;
    float x = (self.view.bounds.size.width - loatindFormSize) / 2;
    float y =(self.view.bounds.size.height - loatindFormSize) / 2;

    loading = [[UIWebView alloc] initWithFrame:CGRectMake( x, y, loatindFormSize, loatindFormSize)];
    loading.backgroundColor = [UIColor clearColor];
    [loading setOpaque:NO];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"loading" ofType:@"html"];
    loading.hidden = YES;
    loading.userInteractionEnabled = NO;//用户不可交互
    [loading loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    [self.view addSubview:loading];
    
    

}
-(void) showLoading{
    //显示loading样式，如果500ms没有加在完成的话
    if (loadingTimer == nil) {
        loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadingShow:) userInfo:nil repeats:NO];
    } else {
        [loadingTimer invalidate];
        [loadingTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

-(void)hideloading {
    [loadingTimer invalidate];
    loading.hidden = YES;
}

- (void)loadingShow:(NSTimer*) timer{
    loading.hidden = NO;
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
    [self hideloading];
    
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError:%@", error);
    [self hideloading];
    
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
        id jsonObject = nil;
        if ([requestParams objectForKey:@"params"]) {
            NSData *paramsData = [[requestParams objectForKey:@"params"] dataUsingEncoding:NSUTF8StringEncoding]; //NSASCIIStringEncoding
            NSError *error = nil;
            jsonObject = [NSJSONSerialization JSONObjectWithData:paramsData options:(NSJSONReadingAllowFragments) error:&error];
        }
        
        
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
            
            if ([@"close" isEqualToString:[requestParams objectForKey:@"act"]]) {
                [self hideShareBox];
            } else {
                
                if (shareBar.hidden == NO) {
                    [self hideShareBox];
                } else {
                    [self showShareBox];
                }
                
            }
            
            
            if (shareBar.hidden == NO) {
                //设置超时 10s 消失
                if (timer != nil) {
                    //清除
                    [timer invalidate];
                    [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];
                } else {
                    timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timerFiredtoCloseShare:) userInfo:nil repeats:NO];
                }
                
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
    
    [self showLoading];
    return YES;
}

-(void) timerFiredtoCloseShare:(NSTimer *)timer {
    [self hideShareBox];
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
    
    //分享回调
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp* response = (SendMessageToWXResp*)resp;
        NSString * jsString = [NSString stringWithFormat:@"{errCode:%d}",response.errCode];
        NSString * callback = [NSString stringWithFormat:@"%@(%@)",jsCallback, jsString];
        [webview stringByEvaluatingJavaScriptFromString:callback];
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
    float cancelBoxSize = 40.0f;
    shareBar = [[UIView alloc] initWithFrame:CGRectMake(0, bodyHeight - sharBarSize - cancelBoxSize, bodyWidth, sharBarSize)];
    shareBar.backgroundColor = [UIColor whiteColor];
    
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
    
    
    shareWxFriend.userInteractionEnabled = true;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareWxFriendClick:)];
    [shareWxFriend addGestureRecognizer:singleTap];
    
    shareWxCircle.userInteractionEnabled = true;
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareWxCircleClick:)];
    [shareWxCircle addGestureRecognizer:singleTap2];
    
    //取消box
    cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, bodyHeight - cancelBoxSize, bodyWidth, cancelBoxSize)];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancel.backgroundColor = [UIColor whiteColor];
    cancel.hidden = YES;
    [cancel addTarget:self action:@selector(shareCancelClick:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:cancel];
    
}

-(void)shareCancelClick:(UIButton*)sender {
    [self hideShareBox];
}
-(void)hideShareBox {
    shareBar.hidden = YES;
    cancel.hidden = YES;
}

-(void)showShareBox {
    shareBar.hidden = NO;
    cancel.hidden = NO;
}

-(void) shareWxFriendClick:(UITapGestureRecognizer *) sender {
    WXMediaMessage *message = [[WXMediaMessage alloc] init];
    message.title = [shareContent objectForKey:@"title"];
    message.description = [shareContent objectForKey:@"desc"];

    NSURL *imgurl = [NSURL URLWithString:[shareContent objectForKey:@"img"]];
    NSError *error ;
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgurl options:NSDataReadingUncached error:&error]];
    if (error != nil) {
        //下载图片出错，使用本地图片
        image = [UIImage imageNamed:@"AppIcon"];
    }
    [message setThumbImage:image];

    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = [shareContent objectForKey:@"link"];
    
    message.mediaObject = webpageObject;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [self hideShareBox];
    [WXApi sendReq:req];
}


-(void) shareWxCircleClick:(UITapGestureRecognizer *) sender {
    WXMediaMessage *message = [[WXMediaMessage alloc] init];
    message.title = [shareContent objectForKey:@"desc"];
    //message.description = [shareContent objectForKey:@"desc"];
    /**
    NSURL *imgurl = [NSURL URLWithString:[shareContent objectForKey:@"img"]];
    NSError *error ;
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgurl options:NSDataReadingUncached error:&error]];
    if (error != nil) {
        //下载图片出错，使用本地图片
        image = [UIImage imageNamed:@"AppIcon"];
    }
    [message setThumbImage:image];
    **/
    loading.hidden = NO;
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = [shareContent objectForKey:@"link"];
    
    message.mediaObject = webpageObject;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    [self hideShareBox];
    [self hideloading];
    [WXApi sendReq:req];
}

@end
