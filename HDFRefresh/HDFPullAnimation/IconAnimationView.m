//
//  IconAnimationView.m
//  DrawCircle
//
//  Created by zhangchu on 16/3/18.
//  Copyright © 2016年 Yeming. All rights reserved.
//

#import "IconAnimationView.h"
#import "IconAnimationSubView.h"

@interface IconAnimationView()
{
    IconAnimationSubView *_upView;
    IconAnimationSubView *_blowView;
}
@end

@implementation IconAnimationView

- (instancetype)initIconAnimationViewWithFrame:(CGRect)frame
{
    if(self = [super init])
    {
    _blowView = [[IconAnimationSubView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) isBackground:YES];
    _blowView.backgroundColor = [UIColor clearColor];
    [self addSubview:_blowView];
    
    _upView = [[IconAnimationSubView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) isBackground:NO];
    _upView.backgroundColor = [UIColor clearColor];
    [self addSubview:_upView];
    
    self.frame = frame;
    }
    return self;
}

- (void)setInitColor:(UIColor *)color
{
    _upView.arcLayer.strokeColor = color.CGColor;
}


- (void)start
{
    [_upView start];
}

- (void)stop
{
    [_upView stop];
}

@end
