//
//  IconAnimationSubView.m
//  DrawCircle
//
//  Created by zhangchu on 16/3/18.
//  Copyright © 2016年 Yeming. All rights reserved.
//

#import "IconAnimationSubView.h"


static NSString  *kAnimationKey = @"key";

@interface IconAnimationSubView()
{
    CAShapeLayer *arcLayer;
    BOOL _isIntroduceVC;
    NSInteger numberOfHeight;
    BOOL _isIos5;
    BOOL _isAnimation;
    BOOL _isPressButton;
    BOOL _isBackground;
    BOOL _isStop;
    NSInteger _i;
//    CAShapeLayer *_arcLayer;
    UIBezierPath *_heartLine;
}

-(void)p_drawIcon;
-(void)p_drawIconAnimation:(CALayer*)layer;
@end

@implementation IconAnimationSubView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame isBackground:(BOOL)isBackGround
{
    if(self = [super init])
    {
        self.frame = frame;
        _isBackground = isBackGround;
        _isStop = NO;
        [self p_drawIcon];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static IconAnimationSubView * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IconAnimationSubView alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public methods
- (void)start
{
    if(!_isBackground)
    {
        _i = 1;
        _isStop = NO;
        [self p_drawIconAnimation:_arcLayer];
    }
}

- (void)stop
{
    if(!_isBackground)
    {
        _isStop = YES;
    }
}

#pragma mark - private methods
-(void)p_drawIcon
{
    _heartLine=[UIBezierPath bezierPath];
    CGFloat animationHeight = self.frame.size.height - self.frame.size.height/20.0f;
    CGFloat animationWeight = self.frame.size.width;
    CGFloat spaceWidth = animationWeight/20.0f;
    CGFloat littleRadius = spaceWidth;
    //上面的两个半圆 半径为整个frame的四分之一
    CGFloat radius = (animationWeight-spaceWidth*2.0f)/4;
    //左侧圆心 位于左侧边距＋半径宽度
    CGPoint leftCenter = CGPointMake(spaceWidth+radius, spaceWidth+radius);
    
    //画圆
    [_heartLine addArcWithCenter:CGPointMake(spaceWidth*5, animationHeight - spaceWidth*3.5) radius:spaceWidth*1.5 startAngle:1.25*M_PI endAngle:-0.75*M_PI clockwise:NO];
    
    //[heartLine moveToPoint:CGPointMake(spaceWidth + radius + radius * cos(M_PI/8), animationHeight)];
    [_heartLine addQuadCurveToPoint:CGPointMake(spaceWidth, spaceWidth+radius) controlPoint:CGPointMake(spaceWidth, animationWeight*0.4)];
    
    //左侧半圆
    [_heartLine addArcWithCenter:leftCenter radius:radius startAngle:M_PI endAngle:-M_PI/8 clockwise:YES];
    
    CGPoint crossPoint = _heartLine.currentPoint;
    littleRadius = spaceWidth + 2*radius - crossPoint.x;
    //下方小圆 右侧
    [_heartLine addQuadCurveToPoint:CGPointMake(crossPoint.x , spaceWidth+ radius + spaceWidth*1.6) controlPoint:CGPointMake(crossPoint.x + 6*littleRadius, spaceWidth + radius + spaceWidth*1.2)];
    //下方小圆 左侧
    [_heartLine addQuadCurveToPoint:crossPoint controlPoint:CGPointMake(crossPoint.x - 6*littleRadius, spaceWidth + radius + spaceWidth*1.2)];
    
    //右侧圆心
    CGPoint rightCenter = CGPointMake(spaceWidth+radius*3 - 2*littleRadius, spaceWidth+radius);
    //右侧半圆
    [_heartLine addArcWithCenter:rightCenter radius:radius startAngle:-M_PI/8*7 endAngle:0 clockwise:YES];
    
    //曲线连接到新的底部顶点 为了弧线的效果，控制点，坐标x为总宽度减spaceWidth，刚好可以相切，平滑过度 y可以根据需要进行调整，y越大，所画出来的线越接近内切圆弧
    [_heartLine addQuadCurveToPoint:CGPointMake(crossPoint.x, animationHeight) controlPoint:CGPointMake(animationWeight - spaceWidth - 2*littleRadius, animationWeight*0.55)];
    
    _arcLayer=[CAShapeLayer layer];
    _arcLayer.path=_heartLine.CGPath;
    _arcLayer.fillColor=[UIColor clearColor].CGColor;
    
    _arcLayer.lineWidth=spaceWidth * 1.5;
    _arcLayer.frame=self.bounds;
    [self.layer addSublayer:_arcLayer];

#if 0
    //医生版主题色
    _arcLayer.strokeColor = [UIColor colorWithRed:189/255.0 green:0.0 blue:20/255.0 alpha:1].CGColor;
#else
    //患者版主题色
    _arcLayer.strokeColor =  HexColor(0x46a0f0).CGColor;
#endif
}

-(void)p_drawIconAnimation:(CALayer*)layer
{
    _i++;
    
    CABasicAnimation *bas;

    _arcLayer.strokeColor = [UIColor lightGrayColor].CGColor;

    if([_arcLayer animationForKey:kAnimationKey])
    {
        return;
    }
    
    if(_i % 2 == 0)
    {
        
        bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    }
    else
    {
        bas=[CABasicAnimation animationWithKeyPath:@"strokeStart"];
    }
    bas.duration=2;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    bas.fillMode=kCAFillModeForwards;
    
    [_arcLayer addAnimation:bas forKey:kAnimationKey];
}

#pragma mark - delegates
#pragma mark -- NSObject
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(!_isStop)
    {
        [self p_drawIconAnimation:_arcLayer];
    }
}


@end
