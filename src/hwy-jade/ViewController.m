//
//  ViewController.m
//  hwy-jade
//
//  Created by hwy on 16/8/6.
//  Copyright © 2016年 hwy. All rights reserved.
//
#define SCREEN_FRAME [UIScreen mainScreen].bounds
#define kTipsAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]
#import "ViewController.h"
#import "WXApi.h"
#import "Const.h"
#import "SYQRCodeViewController/SYQRCodeViewController.h"
#import <AlipaySDK/AlipaySDK.h>

static CGFloat const width = 200.0;
@interface ViewController ()
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) NSUInteger loadCount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取状态栏的高度
    
    isDevRegister = NO;
    officeHost=@HOST;
    
    // Do any additional setup after loading the view, typically from a nib.
    [self initNaviBar];
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    statusBarHeight = rectStatus.size.height;
    
    //初始化webview大小
    webview = [[HWebView alloc] initWithFrame:CGRectMake(0.0f,statusBarHeight,self.view.bounds.size.width,self.view.bounds.size.height - statusBarHeight)];
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 5)];
    _progressView.progressTintColor = [UIColor colorWithRed:179 / 255.0 green:0 blue:17/255.0 alpha:1];
    NSString *s = @PORTAL;
    [webview addSubview:_progressView];
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:s]];
    //NSString *cookie = [webview readCurrentCookie:s];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:s]];
    [self setCookie:officeHost];
    //[request addValue:cookie forHTTPHeaderField:@"Cookie"];
    [webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:webview];
    [webview setDelegate:self];
    webview.scrollView.bounces = NO;
    [webview loadRequest:request];
    //[webview initView];
    [self setUpWebviewEvent];
    [self setUpShare];
    [self setUpLoading];
}

-(void)setUpWebviewEvent {
    UILongPressGestureRecognizer* longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressed.delegate = self;
    [webview addGestureRecognizer:longPressed];
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

- (void)observeValueForKeyPath:(NSString* )keyPath ofObject:(id)object change:(NSDictionary* )change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        self.progressView.progress = webview.estimatedProgress;
    }
    if (object == webview && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}
- (void)setLoadCount:(NSUInteger)loadCount {
    _loadCount = loadCount;
    
    if (loadCount == 0) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    }else {
        self.progressView.hidden = NO;
        CGFloat oldP = self.progressView.progress;
        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
        if (newP > 0.95) {
            newP = 0.95;
        }
        [self.progressView setProgress:newP animated:YES];
        
    }
}


-(void) showLoading{
    //显示loading样式，如果500ms没有加在完成的话
    if (loadingTimer == nil) {
        loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(loadingShow:) userInfo:nil repeats:NO];
    } else {
        [loadingTimer invalidate];
        [loadingTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.8]];
    }
}

-(void)hideloading {
    [loadingTimer invalidate];
    loading.hidden = YES;
}

- (void)loadingShow:(NSTimer*) timer{
    loading.hidden = NO;
}

/**
 * 无网下的错误提示
 **/
- (void)showNetError: (NSString*)url {
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"error" ofType:@"html"];
    NSError *error;
    
    NSString *textFileContents = [NSString stringWithContentsOfFile:filePath
                                encoding:NSUTF8StringEncoding error: & error];
    //NSString *firlUri = [NSString stringWithFormat:@"%@?url=%@", filePath, url];
    if(textFileContents){
        [webview loadHTMLString:textFileContents baseURL:url];
    }
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

- (void )webViewDidStartLoad:(IMYWebView  *)webView {
    //preHost = webview.request.URL.host;
    preHost = webview.currentRequest.URL.host;
    
}

- (void) webViewDidFinishLoad:(IMYWebView *)webView
{
    //return;
    [self hideloading];
    NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [myCookie cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie]; // 保存
    }
    
    if (isDevRegister == NO && deviceTokenStr != nil) {
        //通知h5，注册当前设备
        jsCallback = @"AppCall.deviceRegister";
        NSString *param = [NSString stringWithFormat:@"{token:'%@'}", deviceTokenStr];
        [self webviewCallback: param];
        isDevRegister = YES;
    }
    
    //有些js回调因为app刚启动，页面尚未加载，所以设置暂存在全局变量
    //TO-DO 可以优化成更通用优雅的方式,支持多次js调用
    if (jsParams != nil) {
        jsCallback = @"AppCall.pushBack";
        [self webviewCallback: jsParams];
        jsParams = nil;
    }
}

- (void) webView:(IMYWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError:%@", error);
    [self hideloading];
    //[self showNetError:webview.currentRequest.URL.absoluteString];
    
}


/**
 * 拦截url请求，处理自定义协议 hwy://
 **/
-(BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
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
        jsCallback = [requestParams objectForKey:@"callback"];
        //login  share pay scan
        if ([contoller isEqualToString:@"login"] && [@"weixin" isEqualToString:[requestParams objectForKey:@"act"]]) {
            [self checkWx];
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
            
            [self checkWx];
            if (jsonObject ==nil && jsCallback != nil) {
                NSString *jsExec = [NSString stringWithFormat:@"%@(%@)",jsCallback,@"{errCode:-1}"];
                [webView stringByEvaluatingJavaScriptFromString:jsExec];
                return NO;
            }
            PayReq *request = [[PayReq alloc] init];
            request.partnerId = [jsonObject objectForKey:@"partnerid"];
            request.prepayId= [jsonObject objectForKey:@"prepayid"];
            //request.package = @"Sign=WXPay";
            request.package =[jsonObject objectForKey:@"package"];
            request.nonceStr= [jsonObject objectForKey:@"noncestr"];
            request.timeStamp = [[jsonObject objectForKey:@"timestamp"] intValue];
            request.sign= [jsonObject objectForKey:@"sign"];
            [WXApi sendReq:request];
        }
        
        if ([contoller isEqualToString:@"pay"] && [@"alipay" isEqualToString:[requestParams objectForKey:@"act"]]) {
            // NOTE: 调用支付结果开始支付
            NSString* orderString = [requestParams objectForKey:@"orderStr"];
            NSString *appScheme = @"hwy";
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                [self alipayCallback:jsCallback result:resultDic];
                
            }];
        }
        
        if ([contoller isEqualToString:@"share"]) {
            //分享
            [self checkWx];
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
        
        //二维码扫描
        if ([contoller isEqualToString:@"scan"]) {
            NSLog(@"二维码扫描");
            [self setUpScan];
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

- (void)checkWx {
    if (![WXApi isWXAppInstalled]) {
        //没有安装微信
        kTipsAlert(@"没有安装微信");
    }
}

-(void) timerFiredtoCloseShare:(NSTimer *)timer {
    [self hideShareBox];
}

//设置二维码扫描
-(void)setUpScan {
    __weak ViewController *weakSelf = self;
    SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
    

    
    qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            NSString *retStr = [NSString stringWithFormat:@"{errCode:0,content:'%@'}", qrString];
            [self webviewCallback:retStr];
        }];
        
    };
    qrcodevc.SYQRCodeFailBlock = ^(SYQRCodeViewController *aqrvc) {
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [self webviewCallback:@"{errCode:-1}"];
        }];
        
    };
    qrcodevc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrvc) {
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [self webviewCallback:@"{errCode:1}"];
        }];
    };
    
    //[weakSelf presentModalViewController:qrcodevc animated:YES];
    [self presentViewController:qrcodevc animated:YES completion:nil];
}

-(void) webviewCallback:(NSString*)back {
    if (jsCallback) {
        NSString *callBackScript =[NSString stringWithFormat:@"%@ && %@(%@)",jsCallback, jsCallback, back];
        [webview stringByEvaluatingJavaScriptFromString:callBackScript];
        jsCallback = nil;
    }
}


//初始化，设置ua
+ (void)initialize {
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    UIWebView* tmpwebview = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [tmpwebview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString* buildNo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *newUagent = [NSString stringWithFormat:@"%@ hwy/%@ (%@) channel(100000)",secretAgent, version,buildNo];
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
    
    shareWxFriend.tag = VIEW_TAG_SHARE_FRIEND;
    shareWxFriend.userInteractionEnabled = true;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareWxClick:)];
    [shareWxFriend addGestureRecognizer:singleTap];
    
    shareWxCircle.tag = VIEW_TAG_SHARE_TIMELINE;
    shareWxCircle.userInteractionEnabled = true;
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareWxClick:)];
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

-(void) shareWxClick:(UITapGestureRecognizer *) sender {
    
    WXMediaMessage *message = [[WXMediaMessage alloc] init];
    
    int wxScene = 0;
    if (sender.view.tag == VIEW_TAG_SHARE_TIMELINE) {
        //朋友圈
        wxScene = WXSceneTimeline;
        message.title = [shareContent objectForKey:@"desc"];
        //message.description = [shareContent objectForKey:@"desc"];
    } else {
        //发给朋友
        wxScene = WXSceneSession;
        message.title = [shareContent objectForKey:@"title"];
        message.description = [shareContent objectForKey:@"desc"];
        
    }
    
    NSURL *imgurl = [NSURL URLWithString:[shareContent objectForKey:@"img"]];
    NSError *error ;
    UIImage *image ;
    NSData *imgData = [NSData dataWithContentsOfURL:imgurl options:NSDataReadingMappedIfSafe error:&error];
    if (error != nil) {
        //下载图片出错，使用本地图片
        NSLog(@"获取图片出错 %@", imgurl.absoluteString);
        image = [UIImage imageNamed:@"AppIcon"];
    } else {
        NSLog(@"获取图片成功 %@ ,width", imgurl.absoluteString);
        UIImage *tmp = [UIImage imageWithData:imgData];
        image = [UIImage imageWithData:[self imageWithImage:tmp scaledToSize:CGSizeMake(300, 300)]];
    }
    
    
    [message setThumbImage:image];

    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = [shareContent objectForKey:@"link"];
    
    message.mediaObject = webpageObject;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = wxScene;
    
    [self hideShareBox];
    [WXApi sendReq:req];
}


//对发送的微信的图片压缩
- (NSData *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(newImage, 0.8);
}

//将文件copy到tmp目录
- (NSURL *)fileURLForBuggyWKWebView8:(NSURL *)fileURL {
    NSError *error = nil;
    if (!fileURL.fileURL || ![fileURL checkResourceIsReachableAndReturnError:&error]) {
        return nil;
    }
    // Create "/temp/www" directory
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"www"];
    [fileManager createDirectoryAtURL:temDirURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    NSURL *dstURL = [temDirURL URLByAppendingPathComponent:fileURL.lastPathComponent];
    // Now copy given file to the temp directory
    [fileManager removeItemAtURL:dstURL error:&error];
    [fileManager copyItemAtURL:fileURL toURL:dstURL error:&error];
    // Files in "/temp/www" load flawlesly :)
    return dstURL;
}

-(void) alipayCallback:(NSString* )callback
                result:(NSDictionary*)resultDic {
    if (!callback) {
        callback = @"AppCall.aliPayBack";
    }
    [resultDic setValue:@"alipay" forKey:@"type"];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsCallback = callback;
    [self webviewCallback:myString];
}
//支付宝回调
-(Boolean)handleAlipay:(NSURL*)url {
    // 支付跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
        [self alipayCallback:jsCallback result:resultDic];
    }];
    
    // 授权跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
        // 解析 auth code
        NSString *result = resultDic[@"result"];
        NSString *authCode = nil;
        if (result.length>0) {
            NSArray *resultArr = [result componentsSeparatedByString:@"&"];
            for (NSString *subResult in resultArr) {
                if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                    authCode = [subResult substringFromIndex:10];
                    break;
                }
            }
        }
        NSLog(@"授权结果 authCode = %@", authCode?:@"");
    }];
    return YES;
}

-(void) setCookie:(NSString*)host {
    // 寻找URL为HOST的相关cookie，不用担心，步骤2已经自动为cookie设置好了相关的URL信息
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:host]]; // 这里的HOST是你web服务器的域名地址
    // 设置header，通过遍历cookies来一个一个的设置header
    for (NSHTTPCookie *cookie in cookies){
        
        // cookiesWithResponseHeaderFields方法，需要为URL设置一个cookie为NSDictionary类型的header，注意NSDictionary里面的forKey需要是@"Set-Cookie"
        NSArray *headeringCookie = [NSHTTPCookie cookiesWithResponseHeaderFields:
                                    [NSDictionary dictionaryWithObject:
                                     [[NSString alloc] initWithFormat:@"%@=%@",[cookie name],[cookie value]]
                                                                forKey:@"Set-Cookie"]
                                                                          forURL:[NSURL URLWithString:host]];
        
        // 通过setCookies方法，完成设置，这样只要一访问URL为HOST的网页时，会自动附带上设置好的header
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:headeringCookie
                                                           forURL:[NSURL URLWithString:host]
                                                  mainDocumentURL:nil];
    }
}
/**
 * 获取push注册的token，并传给H5
 **/
-(void)registerPushToken:(NSString*)token {
    NSLog(@"register device to h5 [%@]", token);
    deviceTokenStr = token;
}

/**
 * 收到推送并点击
 **/
-(void)handelPushContent:(NSDictionary *)resultDic pushType:(int) type{
   
    jsCallback = @"AppCall.pushBack";
    NSMutableDictionary __block *wipeOutListDict = [resultDic mutableCopy];
    [wipeOutListDict setValue:[NSNumber numberWithInteger:type] forKey:@"in_app"];
    NSString *jsonString = [self DataTOjsonString:wipeOutListDict];
    NSLog(@"push info %@", jsonString);
    if (type == 1) {
        //app正在运行，则直接调用webiew的方法
        [self webviewCallback:jsonString];
    } else {
        //点击通知栏启动app，则等网页加载完再执行
         //[self webviewCallback:jsonString];
        //kTipsAlert(jsonString);
        jsParams = jsonString;
    }
}

- (void)longPressed:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognizer locationInView:webview];
    
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [webview stringByEvaluatingJavaScriptFromString:imgURL];
    
    if (urlToSave.length == 0) {
        return;
    }
    
    [self showImageOptionsWithUrl:urlToSave];
}

- (void)showImageOptionsWithUrl:(NSString *)imageUrl
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    [sheet addButtonWithTitle:@"保存图片"];

    [sheet showFromRect:CGRectMake(0, self.view.bounds.size.height - 250, self.view.bounds.size.width, 250) inView:webview animated:YES];
    
}
- (void)saveImageToDiskWithUrl:(NSString *)imageUrl
{
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue new]];
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    
    NSURLSessionDownloadTask  *task = [session downloadTaskWithRequest:imgRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return ;
        }
        
        NSData * imageData = [NSData dataWithContentsOfURL:location];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImage * image = [UIImage imageWithData:imageData];
            
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        });
    }];
    
    [task resume];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
   
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
@end
