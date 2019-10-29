//
//  ComponentBViewController.m
//  ComponentB
//
//  Created by aikucun on 2019/10/29.
//

#import "ComponentBViewController.h"
#import <IMXInterface/IMXComponentAProtocol.h>
#import <IMXRoute/IMXRoute.h>
#import <IMXModule/IMXModule.h>

@interface ComponentBViewController ()

@end

@implementation ComponentBViewController

IMX_ROUTE_REGISTER(@"sisi://componentB")

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.center = self.view.center;
    titleLabel.text = @"ComponentBViewController";
    titleLabel.textColor = [UIColor redColor];
    [self.view addSubview:titleLabel];

    id<IMXComponentAProtocol> componentAModule = [IMXModule moduleForProtocol:@protocol(IMXComponentAProtocol)];

    NSLog(@"获取业务组件 A 的名称%@", [componentAModule getComponentAName]);
}

@end
