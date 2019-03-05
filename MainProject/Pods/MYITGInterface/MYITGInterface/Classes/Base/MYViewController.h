//
//  MYViewController.h
//  MYUtils
//
//  Created by sunjinshuai on 2019/2/12.
//  Copyright © 2019年 com.51fanxing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MYViewController : UIViewController

/*
 *  @brief 是否需要隐藏导航栏
 *  默认为NO
 *  如需使用, 须Override
 */
- (BOOL)hideNavigationBar;

/*
 *  @brief 导航栏颜色
 *  默认为 ITG_MAIN_THEME_COLOR
 *  如需使用, 须Override
 */
- (UIColor *)navigationBarColor;

/*
 *  @brief 支持侧滑
 *  默认为 YES
 *  如需使用, 须Override
 */
- (BOOL)enableScreenEdgePanGesture;

/*
 *  @brief 是否为Presented控制器
 *  如该控制器是Presented, 须将该值设为YES
 *  默认为NO
 */
@property (nonatomic, assign, readwrite) BOOL presented;

/*
 *  @brief 导航栏关闭按钮执行的事件
 *  默认事件为关闭此控制器
 */
@property (nonatomic, copy, readwrite)   void (^navigationBackAction)(void);

@end

NS_ASSUME_NONNULL_END
