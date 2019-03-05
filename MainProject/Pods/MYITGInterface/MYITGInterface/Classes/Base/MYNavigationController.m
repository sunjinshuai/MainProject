//
//  MYNavigationController.m
//  MYUtils
//
//  Created by sunjinshuai on 2019/2/12.
//  Copyright © 2019年 com.51fanxing. All rights reserved.
//

#import "MYNavigationController.h"
#import "MYViewController.h"
#import <UIBarButtonItem+Addition.h>

@interface MYNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation MYNavigationController

+ (void)initialize {
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count >= 1) {
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithTarget:self
                                                                                            action:@selector(didTapBackButton)
                                                                                             image:@"hk_navigation_back"];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    self.interactivePopGestureRecognizer.enabled = NO;
    [super pushViewController:viewController animated:animated];
}

- (void)didTapBackButton {
    [self popViewControllerAnimated:YES];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    BOOL hideNavigationBar = NO;
    if ([viewController isKindOfClass:[MYViewController class]]) {
        hideNavigationBar = [(MYViewController *)viewController hideNavigationBar];
    }
    [navigationController setNavigationBarHidden:hideNavigationBar
                                        animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if ([self.viewControllers count] == 1) {
            self.interactivePopGestureRecognizer.enabled = NO;
        } else {
            self.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count <= 1) {
        return NO;
    }
    if ([self.visibleViewController isKindOfClass:[MYViewController class]]) {
        return [(MYViewController *)self.visibleViewController enableScreenEdgePanGesture];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldBeRequiredToFailByGestureRecognizer: (UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]];
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = self;
    }
}

#pragma mark - View Controller Rotation

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.visibleViewController.supportedInterfaceOrientations) {
        return self.topViewController.supportedInterfaceOrientations;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];
}

@end
