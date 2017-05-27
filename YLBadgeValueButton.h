//
//  YLBadgeValueButton.h
//  IndicatorPan
//
//  Created by 吕英良 on 2017/5/25.
//  Copyright © 2017年 吕英良. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLBadgeValueButton : UIButton

/**
 未读数量
 */
@property (nonatomic, strong) NSString * value;

/**
 形变距离
 */
@property (nonatomic, assign) CGFloat distance;

/**
 消失动画数组
 */
@property (nonatomic, strong) NSMutableArray * animationImages;

/**
 清除控件
 */
- (void)killAll;

@end
