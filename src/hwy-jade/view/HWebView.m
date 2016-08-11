//
//  HWebView.m
//  洪五爷珠宝
//
//  Created by hwy on 16/8/8.
//  Copyright © 2016年 hwy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWebView.h"

@interface HWebView ()


@end

@implementation HWebView

- (void) initView {
    self._headerHeight = 50;
    //UIView * backView = [UIView alloc] initWithFrame:<#(CGRect)#>;
    /**
   _headView = [[UIView alloc]init];
   _headView.backgroundColor = [UIColor clearColor];
   _headView.frame = CGRectMake(0, 0, self.bounds.size.width, self._headerHeight);
    self.scrollView.contentInset= UIEdgeInsetsMake(self._headerHeight,0,0,0);
    [self.scrollView addSubview:_headView];
    [_headView setTag:1];
    [self addSubview:_headView];
    self.scrollView.contentOffset= CGPointMake(0, 0 - self._headerHeight);
    //self.scrollView.contentOffset= CGPointMake(0, -30);
    //self.scrollView.contentInset= UIEdgeInsetsMake(self._headerHeight,0,0,0);
     **/
    
}
-(void) showNaviBar {
    
    //self.scrollView.contentOffset= CGPointMake(0, 0 - self._headerHeight);
    //[_headView setHidden:YES];
    
}

-(void) setUa {
   
    NSString* secretAgent = [self stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newUagent = [NSString stringWithFormat:@"%@ hwy/3.5.2",secretAgent];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:newUagent, @"User-Agent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];

}


@end


