//
//  SYQRCodeViewController.m
//  SYQRCodeDemo
//
//  Created by ree.sun on 15-1-9.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import "SYQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SYQRCodeOverlayView.h"
#import "AVCaptureVideoPreviewLayer+Helper.h"
//#import "../ZXingObjC/ZXingObjC.h"

@interface SYQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *qrSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;
@property (nonatomic, strong) UIImageView *line;
@property (nonatomic, strong) NSTimer *lineTimer;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIActivityIndicatorView *vActivityIndicator;

@end

@implementation SYQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"扫描";
    
    _vActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 100) / 2.0, (SCREEN_HEIGHT - 164)  / 2.0, 100, 100)];
    _vActivityIndicator.hidesWhenStopped = YES;
    _vActivityIndicator.backgroundColor = [UIColor clearColor];
    [_vActivityIndicator startAnimating];
    [self.view addSubview:_vActivityIndicator];

    //权限受限
    if (![self canAccessAVCaptureDeviceForMediaType:AVMediaTypeVideo]) {
        [self showUnAuthorizedTips:YES];
    }
    
    
    
    //延迟加载，提高用户体验
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self displayScanView];
    });
}

- (void)displayScanView {
    //没权限显示权限受限
    if ([self canAccessAVCaptureDeviceForMediaType:AVMediaTypeVideo] && [self loadCaptureUI]) {
        [self setOverlayPickerView];
        [self startSYQRCodeReading];
    }
    else {
        [self showUnAuthorizedTips:YES];
    }
}

- (BOOL)canAccessAVCaptureDeviceForMediaType:(NSString *)mediaType {
    __block BOOL canAccess = NO;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                canAccess = granted;
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            canAccess = YES;
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            canAccess = NO;
            break;
        default:
            break;
    }
    
    return canAccess;
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"知道了"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showUnAuthorizedTips:(BOOL)flag {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.frame = CGRectMake(8, 64, self.view.frame.size.width - 16, 300);
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.numberOfLines = 0;
        _tipsLabel.font = [UIFont systemFontOfSize:16];
        _tipsLabel.textColor = [UIColor blackColor];
        _tipsLabel.userInteractionEnabled = YES;
        NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
        _tipsLabel.text = [NSString stringWithFormat:@"请在%@的\"设置-隐私-相机\"选项中，\r允许%@访问你的相机。",[UIDevice currentDevice].model,appName];
        [self.view addSubview:_tipsLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTipsTap)];
        [_tipsLabel addGestureRecognizer:tap];
    }
    
    _tipsLabel.hidden = !flag;
    [_vActivityIndicator stopAnimating];
}

//#warning 使用openURL前请添加scheme：prefs
- (void)_handleTipsTap {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kIOS8_OR_LATER ? UIApplicationOpenSettingsURLString : @"prefs:root"]];
}

- (BOOL)loadCaptureUI {
    _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (![_captureDevice hasTorch]) {
        [self showAlertWithTitle:@"提示" message:@"当前设备没有闪光灯"];
    }

    _qrVideoPreviewLayer = [AVCaptureVideoPreviewLayer captureVideoPreviewLayerWithFrame:self.view.bounds rectOfInterest:[self getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)] captureDevice:_captureDevice metadataObjectsDelegate:self];
    
    if (!_qrVideoPreviewLayer) {
        return NO;
    }
    _qrSession = _qrVideoPreviewLayer.session;
    
    return YES;
}

- (CGRect)getReaderViewBoundsWithSize:(CGSize)asize {
    return CGRectMake(kLineMinY / SCREEN_HEIGHT, ((SCREEN_WIDTH - asize.width) / 2.0) / SCREEN_WIDTH, asize.height / SCREEN_HEIGHT, asize.width / SCREEN_WIDTH);
}

- (void)setOverlayPickerView {
    __weak SYQRCodeViewController *weakSelf = self;
    
    SYQRCodeOverlayView *vOverlayer = [[SYQRCodeOverlayView alloc] initWithFrame:self.view.bounds basedLayer:_qrVideoPreviewLayer];
    vOverlayer.SYQRCodeOverlayViewBtnAction = ^(UIButton *btn){
        [weakSelf btnClick:btn];
    };
    [self.view addSubview:vOverlayer];
    
    //添加过渡动画，类似微信
    [self.view.layer insertSublayer:_qrVideoPreviewLayer atIndex:0];
    
    CAKeyframeAnimation *animationLayer = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animationLayer.duration = 0.1;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animationLayer.values = values;
    [_qrVideoPreviewLayer addAnimation:animationLayer forKey:nil];
}

- (void)gotoImagePickerController {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)turnOnTorch:(BOOL)on {
    [_captureDevice lockForConfiguration:nil];
    if (on) {
        [_captureDevice setTorchMode:AVCaptureTorchModeOn];
    }
    else {
        [_captureDevice setTorchMode: AVCaptureTorchModeOff];
    }
    
    [_captureDevice unlockForConfiguration];
}


#pragma mark - Button Event

- (void)btnClick:(UIButton *)sender {
    //Album 读取
    if (sender.tag == BTN_TAG) {
        [self gotoImagePickerController];
    }
    else if(sender.tag == BTN_TAG + 1) {
        //Touch
        if (sender.selected) {
            [self turnOnTorch:NO];
        }
        else {
            [self turnOnTorch:YES];
        }
        
        sender.selected = !sender.selected;
    } else if (sender.tag == CLOSE_TAG) {
        //返回关闭
        [self stopSYQRCodeReading];
        if (self.SYQRCodeCancleBlock) {
            self.SYQRCodeCancleBlock(self);
        }
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

#pragma mark -UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *loadImage= [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSLog(@"%@", loadImage);
    
    NSString *des = @"";
    
    if (true) {
        // if you only iOS >= 8.0 you can use system(this) method
        CIContext *context = [CIContext contextWithOptions:nil];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        CIImage *image = [CIImage imageWithCGImage:loadImage.CGImage];
        NSArray *features = [detector featuresInImage:image];
        
        if (features.count > 0) {
            CIQRCodeFeature *feature = [features firstObject];
            
            if (feature.messageString.length > 0) {
                des = [des stringByAppendingString:feature.messageString];
            }
        }
    }
    else {

    }
    
    if (des.length > 0) {
        NSLog(@"contents =%@",des);
        if (self.SYQRCodeSuncessBlock) {
            self.SYQRCodeSuncessBlock(self, des);
        }
    }
    else {
        [self showAlertWithTitle:nil message:@"解析失败"];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    BOOL fail = YES;
    //扫描结果
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *responseObj = metadataObjects[0];
        //        //org.iso.QRCode
        //        if ([responseObj.type containsString:@"QRCode"]) {
        //
        //        }
        if (responseObj) {
            NSString *strResponse = responseObj.stringValue;
            
            if (strResponse && ![strResponse isEqualToString:@""] && strResponse.length > 0) {
                NSLog(@"qrcodestring==%@",strResponse);
                
                fail = NO;

                AudioServicesPlaySystemSound(1360);
                
                if (self.SYQRCodeSuncessBlock) {
                    self.SYQRCodeSuncessBlock(self, strResponse);
                }
            }
        }
    }
    
    if (fail) {
        if (self.SYQRCodeFailBlock) {
            self.SYQRCodeFailBlock(self);
        }
    }
    [self stopSYQRCodeReading];
}

#pragma mark - startSYQRCodeReading

- (void)startSYQRCodeReading {
    [_vActivityIndicator stopAnimating];

    if (!_line) {
        //画中间的基准线
        _line = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 300) / 2.0, kLineMinY, 300, 12 * 300 / 320.0)];
        [_line setImage:[UIImage imageNamed:@"QRCodeLine"]];
        [_qrVideoPreviewLayer addSublayer:_line.layer];
    }

    _lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 20 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    [_qrSession startRunning];
    
    NSLog(@"start reading");
}

- (void)stopSYQRCodeReading {
    if (_lineTimer) {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
    
    if (_qrSession) {
        [_qrSession stopRunning];
        _qrSession = nil;
    }
    
    NSLog(@"stop reading");
}

- (void)cancleSYQRCodeReading {
    [self stopSYQRCodeReading];
    
    if (self.SYQRCodeCancleBlock) {
        self.SYQRCodeCancleBlock(self);
    }
    NSLog(@"cancle reading");
}

#pragma mark - animationLine

- (void)animationLine {
    __block CGRect frame = _line.frame;
    
    static BOOL flag = YES;
    
    if (flag) {
        frame.origin.y = kLineMinY;
        flag = NO;
        
        [UIView animateWithDuration:1.0 / 20 animations:^{
            
            frame.origin.y += 5;
            _line.frame = frame;
            
        } completion:nil];
    }
    else {
        if (_line.frame.origin.y >= kLineMinY) {
            if (_line.frame.origin.y >= kLineMaxY - 12) {
                frame.origin.y = kLineMinY;
                _line.frame = frame;
                
                flag = YES;
            }
            else {
                [UIView animateWithDuration:1.0 / 20 animations:^{
                    frame.origin.y += 5;
                    _line.frame = frame;
                } completion:nil];
            }
        }
        else {
            flag = !flag;
        }
    }
    
    //NSLog(@"_line.frame.origin.y==%f",_line.frame.origin.y);
}


- (void)dealloc {
    NSLog(@"SYQRCodeViewController dealloc");
    [self stopSYQRCodeReading];
}

@end
