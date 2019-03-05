//
//  MYViewController.m
//  MYUtils
//
//  Created by sunjinshuai on 2019/2/12.
//  Copyright © 2019年 com.51fanxing. All rights reserved.
//

#import "MYViewController.h"

#define ITGViewControllerImage(fileName)\
[UIImage imageWithContentsOfFile:[[[NSBundle bundleForClass:[ITGViewController class]] pathForResource:@"Base" ofType:@"bundle"] stringByAppendingPathComponent:fileName]]

@interface MYViewController ()

@property (nonatomic, assign) BOOL hideNavigationBar;
@property (nonatomic, strong) UIColor *navigationBarColor;

@end

@implementation MYViewController

- (BOOL)hideNavigationBar {
    return NO;
}

- (BOOL)enableScreenEdgePanGesture {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    [self setupAppearance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupAppearance];
}

- (void)setupAppearance {
//    BOOL isWhiteColor = CGColorEqualToColor([self navigationBarColor].CGColor,
//                                            [UIColor whiteColor].CGColor);
//    if (isWhiteColor) {
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17],
//                                                                          NSForegroundColorAttributeName : ITG_MAIN_TEXT_COLOR}];
//        [self.navigationController.navigationBar setTintColor:ITG_MAIN_TEXT_COLOR];
//    } else {
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17],
//                                                                          NSForegroundColorAttributeName : [UIColor whiteColor]}];
//        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor   = [UIColor whiteColor];
//    BOOL isWhiteColor = CGColorEqualToColor([self navigationBarColor].CGColor,
//                                            [UIColor whiteColor].CGColor);
//    UIImage *backImage = nil;
//    if ([self presented]) {
//        backImage = (isWhiteColor ?
//                     ITGViewControllerImage(@"ITGKit_Navi_back_black_down") :
//                     ITGViewControllerImage(@"ITGKit_Navi_back_white_down"));
//        
//    } else {
//        if (self.navigationController.childViewControllers.count > 1) {
//            backImage = (isWhiteColor ?
//                         ITGViewControllerImage(@"ITGKit_Navi_back_black") :
//                         ITGViewControllerImage(@"ITGKit_Navi_back_white"));
//        }
//    }
//    if (backImage) {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//                                                 initWithImage:[backImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
//                                                 style:UIBarButtonItemStylePlain
//                                                 target:self
//                                                 action:@selector(leftBarButtonItemAction)];
//    }
}

- (void)leftBarButtonItemAction {
    if (self.navigationBackAction) {
        self.navigationBackAction();
    } else {
        if (self.presented) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    BOOL isWhiteColor = CGColorEqualToColor([self navigationBarColor].CGColor,
                                            [UIColor whiteColor].CGColor);
    if (isWhiteColor) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleLightContent;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
