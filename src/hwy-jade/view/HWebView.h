//
//  HWebView.h
//  洪五爷珠宝
//
//  Created by hwy on 16/8/8.
//  Copyright © 2016年 hwy. All rights reserved.
//

#ifndef HWebView_h
#define HWebView_h
#import <UIKit/UIKit.h>
#import "../IMYWebView/IMYWebView.h"


@interface HWebView : IMYWebView

@property (nonatomic, weak) UIButton * backItem;
@property (nonatomic,weak) UIView * headView;
@property int _headerHeight;
- (void) initView;
- (void) showNaviBar;
-(void) setUa ;

@end

#endif /* HWebView_h */
