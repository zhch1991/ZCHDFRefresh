//
//  IconAnimationView.h
//  DrawCircle
//
//  Created by zhangchu on 16/3/18.
//  Copyright © 2016年 Yeming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconAnimationView : UIView
- (instancetype)initIconAnimationViewWithFrame:(CGRect)frame;
- (void)setInitColor:(UIColor *)color;
- (void)start;
- (void)stop;
@end
