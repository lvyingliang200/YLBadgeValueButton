//
//  YLBadgeValueButton.m
//  IndicatorPan
//
//  Created by 吕英良 on 2017/5/25.
//  Copyright © 2017年 吕英良. All rights reserved.
//

#import "YLBadgeValueButton.h"

@interface YLBadgeValueButton ()

@property (nonatomic, strong) UIView * smallCircle;

@property (nonatomic, weak) CAShapeLayer * shapeL;

@end

@implementation YLBadgeValueButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUp];
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setUp];
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}


/**
 滑动手势
 @param pan 手势对象
 */
- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint tranP = [pan translationInView:self];
    
    //    transform并没有修改center，而只是修改frame
    //    self.transform = CGAffineTransformTranslate(self.transform, tranP.x, tranP.y);
    
    CGPoint center = self.center;
    center.x += tranP.x;
    center.y += tranP.y;
    self.center = center;
    [pan setTranslation:CGPointZero inView:self];
    
    CGFloat distance = [self distanceWithSmallCircle:self.smallCircle BigCircle:self];
    CGFloat smallR = self.bounds.size.width/2.0;
    smallR -= distance/10.0;
    self.smallCircle.bounds = CGRectMake(0, 0, smallR*2, smallR*2);
    self.smallCircle.layer.cornerRadius = smallR;
    UIBezierPath * path = [self pathWithSmallCircle:self.smallCircle BigCircle:self];
    //    无需给定尺寸，会根据给定的path自动生成形状
    if (self.smallCircle.hidden == NO) {
        self.shapeL.path = path.CGPath;
    }
    
    if (distance > self.distance) {
        //        让小圆隐藏，路径隐藏
        self.smallCircle.hidden = YES;
        [self.shapeL removeFromSuperlayer];
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        //        判断距离是否大于给定值
        if (distance <= self.distance) {
            [self.shapeL removeFromSuperlayer];
            self.center = self.smallCircle.center;
            self.smallCircle.hidden = NO;
        }else{
            [self destroyAniamtion];
            [self killAll];
        }
    }
}

/**
 初始化设置
 */
- (void)setUp
{
    _distance = 80.0;
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    self.layer.backgroundColor = [UIColor redColor].CGColor;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    
    UIView * smallCircle = [[UIView alloc] initWithFrame:self.frame];
    smallCircle.layer.cornerRadius = self.layer.cornerRadius;
    smallCircle.layer.backgroundColor = self.layer.backgroundColor;
    self.smallCircle = smallCircle;
}

/**
 布局上小圆
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.superview addSubview:self.smallCircle];
    [self.superview insertSubview:self.smallCircle belowSubview:self];
    if (_value != nil) {
        [self setTitle:_value forState:UIControlStateNormal];
    }
}
/**
 计算两圆之间的距离
 @param small 小圆对象
 @param big 大圆对象
 @return 两圆之间的距离
 */
- (CGFloat)distanceWithSmallCircle:(UIView *)small BigCircle:(UIView *)big
{
    CGFloat offsetX = big.center.x - small.center.x;
    CGFloat offsetY = big.center.y - small.center.y;
    
    return sqrt(offsetX * offsetX + offsetY * offsetY);
}

//    绘制路径
- (UIBezierPath *)pathWithSmallCircle:(UIView *)small BigCircle:(UIView *)big
{
    CGFloat x1 = small.center.x;
    CGFloat y1 = small.center.y;
    
    CGFloat x2 = big.center.x;
    CGFloat y2 = big.center.y;
    
    CGFloat d = [self distanceWithSmallCircle:small BigCircle:big];
    
    if (d <= 0) {
        return nil;
    }
    
    CGFloat cosθ = (y2 - y1)/d;
    CGFloat sinθ = (x2 - x1)/d;
    
    CGFloat r1 = small.bounds.size.width * 0.5;
    CGFloat r2 = big.bounds.size.width * 0.5;
    
    //    求点
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ, y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ, y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ, y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ, y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d * 0.5 * sinθ, pointA.y + d * 0.5 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + d * 0.5 * sinθ, pointB.y + d * 0.5 * cosθ);
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    //    曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    [path addLineToPoint:pointD];
    //    曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}

#pragma mark - 懒加载
- (NSMutableArray *)animationImages
{
    if (_animationImages == nil) {
        _animationImages = [NSMutableArray array];
        for (int i = 1; i < 9; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
            [_animationImages addObject:image];
        }
    }
    return _animationImages;
}
- (CAShapeLayer *)shapeL
{
    if (_shapeL == nil) {
        CAShapeLayer * shapeL = [CAShapeLayer layer];
        shapeL.fillColor = [UIColor redColor].CGColor;
        //    注意这里要设置的是layer
        [self.superview.layer insertSublayer:shapeL atIndex:0];
        _shapeL = shapeL;
    }
    return _shapeL;
}

/**
 消失动画
 */
- (void)destroyAniamtion
{
    //     播放一个动画消失
    UIImageView * imageV = [[UIImageView alloc] initWithFrame:self.frame];
    imageV.animationImages = self.animationImages;
    imageV.animationRepeatCount = 1;
    imageV.animationDuration = 0.5;
    [imageV startAnimating];
    [self.superview addSubview:imageV];
}

/**
 清除控件置空指针
 */
- (void)killAll
{
    [self removeFromSuperview];
    [self.smallCircle removeFromSuperview];
    self.smallCircle = nil;
    [self.shapeL removeFromSuperlayer];
    self.shapeL = nil;
}


/**
 取消高亮
 @param highlighted 是否高亮的bool值
 */
- (void)setHighlighted:(BOOL)highlighted
{
    
}

@end
