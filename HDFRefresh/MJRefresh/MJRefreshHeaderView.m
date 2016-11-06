
//
//  MJRefreshHeaderView.m
//  MJRefresh
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013年 itcast. All rights reserved.
//  下拉刷新

#import "MJRefreshConst.h"
#import "MJRefreshHeaderView.h"
#import "UIView+MJExtension.h"
#import "UIScrollView+MJExtension.h"
#import "NSString+HDFAdditions.h"

@interface MJRefreshHeaderView()
// 最后的更新时间
@property (nonatomic, strong) NSDate *lastUpdateTime;
@property (nonatomic, weak) UILabel *lastUpdateTimeLabel;
@property (nonatomic,assign)BOOL isShowTimeLabel;
@end

@implementation MJRefreshHeaderView
#pragma mark - 控件初始化
/**
 *  时间标签
 */
- (UILabel *)lastUpdateTimeLabel
{
    if (!_lastUpdateTimeLabel) {
        // 1.创建控件
        UILabel *lastUpdateTimeLabel = [[UILabel alloc] init];
        lastUpdateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lastUpdateTimeLabel.font = [UIFont boldSystemFontOfSize:12];
        lastUpdateTimeLabel.textColor = MJRefreshLabelTextColor;
        lastUpdateTimeLabel.backgroundColor = [UIColor clearColor];
        lastUpdateTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lastUpdateTimeLabel = lastUpdateTimeLabel];
        
        // 2.加载时间
        if(self.dateKey){
            self.lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:self.dateKey];
        } else {
            self.lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:MJRefreshHeaderTimeKey];
        }
    }
    return _lastUpdateTimeLabel;
}

+ (instancetype)header
{
    return [[MJRefreshHeaderView alloc] init];
}
+ (instancetype)headerWithoutTimeLabel
{
    
    MJRefreshHeaderView *view= [[MJRefreshHeaderView alloc] init];
    view.isShowTimeLabel=NO;
    return view;
}
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.pullToRefreshText = MJRefreshHeaderPullToRefresh;
        self.releaseToRefreshText = MJRefreshHeaderReleaseToRefresh;
        self.refreshingText = MJRefreshHeaderRefreshing;
        self.isShowTimeLabel=YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat statusX = 0;
    CGFloat statusY = 0;
    CGFloat statusHeight = self.mj_height * 0.5;
    CGFloat statusWidth = self.mj_width;
    // 1.状态标签
    self.statusLabel.frame = CGRectMake(statusX, statusY, [self.refreshingText widthWithFont:[UIFont boldSystemFontOfSize:13] withLineHight:statusHeight], statusHeight);
    self.statusLabel.center = CGPointMake((self.mj_width- [@"..."widthWithFont:[UIFont boldSystemFontOfSize:13] withLineHight:statusHeight])/2, statusHeight/2);
    
    self.statusDotLabel.frame = CGRectMake(CGRectGetMaxX(self.statusLabel.frame), statusY, [@"..."widthWithFont:[UIFont boldSystemFontOfSize:13] withLineHight:statusHeight], statusHeight);
    
    // 2.时间标签
    CGFloat lastUpdateY = statusHeight;
    CGFloat lastUpdateX = 0;
    CGFloat lastUpdateHeight = statusHeight;
    CGFloat lastUpdateWidth = statusWidth;
    if(self.isShowTimeLabel)
    {
      self.lastUpdateTimeLabel.frame = CGRectMake(lastUpdateX, lastUpdateY, lastUpdateWidth, lastUpdateHeight);
    }else
    {
        self.lastUpdateTimeLabel.frame=CGRectZero;
    }
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 设置自己的位置和尺寸
    self.mj_y = - self.mj_height;
}

#pragma mark - 状态相关
#pragma mark 设置最后的更新时间
- (void)setLastUpdateTime:(NSDate *)lastUpdateTime
{
    _lastUpdateTime = lastUpdateTime;
    
    // 1.归档
    if(self.dateKey){
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:self.dateKey];
    }   else{
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:MJRefreshHeaderTimeKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 2.更新时间
    [self updateTimeLabel];
}

#pragma mark 更新时间字符串
- (void)updateTimeLabel
{
    if (!self.lastUpdateTime) return;
    
    // 1.获得年月日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:_lastUpdateTime];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    // 2.格式化日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([cmp1 day] == [cmp2 day]) { // 今天
        formatter.dateFormat = @"今天 HH:mm";
    } else if ([cmp1 year] == [cmp2 year]) { // 今年
        formatter.dateFormat = @"MM-dd HH:mm";
    } else {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    NSString *time = [formatter stringFromDate:self.lastUpdateTime];
    
    // 3.显示日期
    self.lastUpdateTimeLabel.text = [NSString stringWithFormat:@"最后更新：%@", time];
}

#pragma mark - 监听UIScrollView的contentOffset属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 不能跟用户交互就直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;

    if(self.isAdjustContentInsetForSectionHeader == YES){
    // 如果正在刷新，直接返回
        if (self.state == MJRefreshStateRefreshing || self.endingRefresh){
            
              CGFloat offset;
              UIEdgeInsets contentInset;

              offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
              offset = MIN(offset,self.bounds.size.height);
//                 NSLog(@"offset:%f",offset);

            contentInset = self.scrollView.contentInset;
            self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);

//                NSLog(@"contentInset:%@",NSStringFromUIEdgeInsets(self.scrollView.contentInset));

            }
            
            // 如果正在刷新，直接返回
            if (self.state == MJRefreshStateNormal){
                CGFloat offset;
                UIEdgeInsets contentInset;
                
                offset = 0;//MAX(self.scrollView.contentOffset.y * -1, 0.0f);
                
                //            offset = MIN(offset,self.bounds.size.height);
//                NSLog(@"offset:%f",offset);
                
                contentInset = self.scrollView.contentInset;
                self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
                
//                NSLog(@"contentInset:%@",NSStringFromUIEdgeInsets(self.scrollView.contentInset));
                
                
            }
    }

    // 如果正在刷新，直接返回
    if (self.state == MJRefreshStateRefreshing || self.endingRefresh) return;
    
    
   


    if ([MJRefreshContentOffset isEqualToString:keyPath]) {
        [self adjustStateWithContentOffset];
    }
}

/**
 *  调整状态
 */
- (void)adjustStateWithContentOffset
{
    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.mj_contentOffsetY;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    if (currentOffsetY >= happenOffsetY) return;
    
    if (self.scrollView.isDragging) {
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY - self.mj_height;
        
        if (self.state == MJRefreshStateNormal && currentOffsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = MJRefreshStatePulling;
        } else if (self.state == MJRefreshStatePulling && currentOffsetY >= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = MJRefreshStateNormal;
        }
    } else if (self.state == MJRefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        self.state = MJRefreshStateRefreshing;
    }
}

#pragma mark 设置状态
- (void)setState:(MJRefreshState)state
{
    // 1.一样的就直接返回
    if (self.state == state) return;
    
    // 2.保存旧状态
    MJRefreshState oldState = self.state;
    
    // 3.调用父类方法
    [super setState:state];
    
    // 4.根据状态执行不同的操作
	switch (state) {
		case MJRefreshStateNormal: // 下拉可以刷新
        {
            // 刷新完毕
            if (MJRefreshStateRefreshing == oldState) {
                self.arrowImage.transform = CGAffineTransformIdentity;
                // 保存刷新时间
                self.lastUpdateTime = [NSDate date];
                
                [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
#warning 这句代码修复了，top值不断累加的bug
                    if (self.scrollViewOriginalInset.top == 0) {
                        self.scrollView.mj_contentInsetTop = 0;
                    } else if (self.scrollViewOriginalInset.top == self.scrollView.mj_contentInsetTop) {
                        self.scrollView.mj_contentInsetTop -= self.mj_height;
                    } else {
                        self.scrollView.mj_contentInsetTop = self.scrollViewOriginalInset.top;
                    }
                }];
            } else {
                // 执行动画
                [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                    self.arrowImage.transform = CGAffineTransformIdentity;
                }];
            }
			break;
        }
            
		case MJRefreshStatePulling: // 松开可立即刷新
        {
            // 执行动画
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
            }];
			break;
        }
            
		case MJRefreshStateRefreshing: // 正在刷新中
        {
            // 执行动画
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                // 1.增加滚动区域
                CGFloat top = self.scrollViewOriginalInset.top + self.mj_height;
                self.scrollView.mj_contentInsetTop = top;
                
                // 2.设置滚动位置
                self.scrollView.mj_contentOffsetY = - top;
            }];
			break;
        }
            
        default:
            break;
	}
}
@end