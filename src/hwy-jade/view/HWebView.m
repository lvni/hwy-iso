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
   
  

}

// 保存数据到本地
- (BOOL) SetLocalData:(NSString *)dataFile dataObject:(NSMutableDictionary *)dataObject{
    // 设置路径,并保存
    NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *saveFile = [savePath stringByAppendingPathComponent:dataFile];[NSKeyedArchiver archiveRootObject:dataObject toFile:saveFile];
    return YES;
}
// 读取本地保存的数据
- (NSMutableDictionary *) GetLocalData:(NSString *)dataFile {
    // 按文件名来读取数据
    NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *saveFile = [savePath stringByAppendingPathComponent:dataFile];
    return [NSKeyedUnarchiver unarchiveObjectWithFile: saveFile];
}


@end


