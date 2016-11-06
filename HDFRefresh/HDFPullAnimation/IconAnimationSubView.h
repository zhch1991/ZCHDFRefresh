//
//  IconAnimationSubView.h
//  DrawCircle
//
//  Created by zhangchu on 16/3/18.
//  Copyright © 2016年 Yeming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconAnimationSubView : UIImageView
@property (nonatomic, strong) CAShapeLayer *arcLayer;

+ (instancetype)sharedInstance;
- (instancetype)initWithFrame:(CGRect)frame isBackground:(BOOL)isBackGround;
- (void)start;
- (void)stop;
@end
