//
//  MJRefreshBaseView.m
//  MJRefresh
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJRefreshBaseView.h"
#import "MJRefreshConst.h"
#import "UIView+MJExtension.h"
#import "UIScrollView+MJExtension.h"
#import <objc/message.h>
#import "IconAnimationView.h"

@interface  MJRefreshBaseView()
{
    __weak UILabel *_statusDotLabel;
    __weak UILabel *_statusLabel;
    __weak UIImageView *_arrowImage;
    __weak IconAnimationView *_activityView;
    BOOL _endingRefresh;
    NSTimer *_timer;
    NSInteger _dotNum;
}
@end

@implementation MJRefreshBaseView
#pragma mark - 控件初始化
/**
 *  状态标签
 */
- (UILabel *)statusLabel
{
    if (!_statusLabel) {
        UILabel *statusLabel = [[UILabel alloc] init];
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel.font = [UIFont boldSystemFontOfSize:13];
        statusLabel.textColor = MJRefreshLabelTextColor;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_statusLabel = statusLabel];
    }
    return _statusLabel;
}

/**
 *  仨点
 */
-(UILabel *)statusDotLabel
{
    if(!_statusDotLabel)
    {
        UILabel *statusDotLabel = [[UILabel alloc] init];
        statusDotLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusDotLabel.font = [UIFont boldSystemFontOfSize:13];
        statusDotLabel.textColor = MJRefreshLabelTextColor;
        statusDotLabel.backgroundColor = [UIColor clearColor];
        statusDotLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_statusDotLabel = statusDotLabel];
    }
    return _statusDotLabel;
}

/**
 *  箭头图片
 */
- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:MJRefreshSrcName(@"arrow.png")]];
        arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_arrowImage = arrowImage];
    }
    
    if (self.userInteractionEnabled == NO) {
        [_arrowImage removeFromSuperview];
        _arrowImage = nil;
    }
    return _arrowImage;
}

- (IconAnimationView *)activityView
{
    if (!_activityView) {
        IconAnimationView * activityView = [[IconAnimationView alloc] initIconAnimationViewWithFrame:CGRectMake(0, 0, 35, 28)];
        activityView.bounds = self.arrowImage.bounds;
        activityView.autoresizingMask = self.arrowImage.autoresizingMask;
        _activityView = activityView;
        [self addSubview:_activityView];
    }
    return _activityView;
}

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = MJRefreshViewHeight;
    if (self = [super initWithFrame:frame]) {
        // 1.自己的属性
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        // 2.设置默认状态
        self.state = MJRefreshStateNormal;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.箭头
    CGFloat arrowX = self.mj_width * 0.5 - 100;
    self.arrowImage.center = CGPointMake(arrowX, self.mj_height * 0.5);
    
    // 2.指示器
    self.activityView.frame = CGRectMake(self.arrowImage.frame.origin.x - 10, self.arrowImage.frame.origin.y + 7, self.arrowImage.frame.size.width, self.arrowImage.frame.size.height);
}




- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:MJRefreshContentOffset context:nil];
    
    if (newSuperview) { // 新的父控件
        [newSuperview addObserver:self forKeyPath:MJRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        // 设置宽度
        self.mj_width = newSuperview.mj_width;
        // 设置位置
        self.mj_x = 0;
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        // 记录UIScrollView最开始的contentInset
        _scrollViewOriginalInset = _scrollView.contentInset;
    }
}

#pragma mark - 显示到屏幕上
- (void)drawRect:(CGRect)rect
{
    if (self.state == MJRefreshStateWillRefreshing) {
        self.state = MJRefreshStateRefreshing;
    }
}

#pragma mark - 刷新相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
    return MJRefreshStateRefreshing == self.state;
}

#pragma mark 开始刷新
- (void)beginRefreshing
{
    if (self.state == MJRefreshStateRefreshing) {
        // 回调
        if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
            msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
        }
        
        if (self.beginRefreshingCallback) {
            self.beginRefreshingCallback();
        }
    } else {
        if (self.window) {
            self.state = MJRefreshStateRefreshing;
        } else {
    #warning 不能调用set方法
            _state = MJRefreshStateWillRefreshing;
            
#warning 为了保证在viewWillAppear等方法中也能刷新
            [self setNeedsDisplay];
        }
    }
}

#pragma mark 结束刷新
- (void)endRefreshing
{
    [_timer invalidate];
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.state = MJRefreshStateNormal;
    });
}

#pragma mark - 设置状态
- (void)setPullToRefreshText:(NSString *)pullToRefreshText
{
    _pullToRefreshText = [pullToRefreshText copy];
    [self settingLabelText];
}
- (void)setReleaseToRefreshText:(NSString *)releaseToRefreshText
{
    _releaseToRefreshText = [releaseToRefreshText copy];
    [self settingLabelText];
}
- (void)setRefreshingText:(NSString *)refreshingText
{
    _refreshingText = [refreshingText copy];
    [self settingLabelText];
}
- (void)settingLabelText
{
	switch (self.state) {
		case MJRefreshStateNormal:
            // 设置文字
            self.statusLabel.text = self.pullToRefreshText;
			self.statusDotLabel.text = @"";
            break;
		case MJRefreshStatePulling:
            // 设置文字
            self.statusLabel.text = self.releaseToRefreshText;
			self.statusDotLabel.text = @"";
            break;
        case MJRefreshStateRefreshing:
            // 设置文字
            self.statusLabel.text = self.refreshingText;
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(setDotLabelText) userInfo:nil repeats:YES];
			break;
        default:
            break;
	}
}

- (void)setDotLabelText
{
    _dotNum++;
    if(_dotNum == 4)
    {
        _dotNum = 0;
    }
    switch (_dotNum) {
        case 0:
            self.statusDotLabel.text = @"";
            break;
        case 1:
            self.statusDotLabel.text = @".";
            break;
        case 2:
            self.statusDotLabel.text = @"..";
            break;
        case 3:
            self.statusDotLabel.text = @"...";
            break;
    }
    
}

- (void)setState:(MJRefreshState)state
{
    // 0.存储当前的contentInset
    if (self.state != MJRefreshStateRefreshing) {
        _scrollViewOriginalInset = self.scrollView.contentInset;
    }
    
    // 1.一样的就直接返回(暂时不返回)
    if (self.state == state) return;
    
    // 2.旧状态
    MJRefreshState oldState = self.state;
    
    // 3.存储状态
    _state = state;
    
    // 4.根据状态执行不同的操作
    switch (state) {
		case MJRefreshStateNormal: // 普通状态
        {
            if (oldState == MJRefreshStateRefreshing) {
                // 正在结束刷新
                _endingRefresh = YES;
                
                [UIView animateWithDuration:MJRefreshSlowAnimationDuration * 0.6 animations:^{
//                    self.activityView.alpha = 0.0;
                  [self.activityView stop];
                } completion:^(BOOL finished) {
                    // 停止转圈圈
                    [self.activityView stop];
                    
                    // 恢复alpha
//                    self.activityView.alpha = 1.0;
                }];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJRefreshSlowAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 等头部回去
                    // 显示箭头
                    [self.activityView setInitColor:HexColor(0x46a0f0)];
                    self.arrowImage.hidden = NO;
                    self.activityView.hidden = YES;
                    // 停止转圈圈
                    [self.activityView stop];
                    
                    // 设置文字
                    [self settingLabelText];
                    
                    // 结束刷新完毕
                    _endingRefresh = NO;
                });
                // 直接返回
                return;
            } else {
                // 显示箭头
                [self.activityView setInitColor:HexColor(0x46a0f0)];
                self.arrowImage.hidden = NO;
                self.activityView.hidden = YES;
                // 停止转圈圈
                [self.activityView stop];
            }
			break;
        }
            
        case MJRefreshStatePulling:
            self.activityView.hidden = YES;
            [self.activityView setInitColor:HexColor(0x46a0f0)];
            break;
            
		case MJRefreshStateRefreshing:
        {
            // 开始转圈圈
            self.activityView.hidden = NO;
            [self.activityView setInitColor:HexColor(0x46a0f0)];
            [self.activityView stop];
			[self.activityView start];
            // 隐藏箭头
			self.arrowImage.hidden = YES;
            
            // 回调
            if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
                msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
            }
            
            if (self.beginRefreshingCallback) {
                self.beginRefreshingCallback();
            }
			break;
        }
        default:
            break;
	}
    
    // 5.设置文字
    [self settingLabelText];
}
@end