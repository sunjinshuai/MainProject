//
//  ComponentAViewController.m
//  ComponentA
//
//  Created by aikucun on 2019/10/29.
//

#import "ComponentAViewController.h"
#import <IMXInterface/IMXComponentBProtocol.h>
#import <IMXRoute/IMXRoute.h>
#import <IMXModule/IMXModule.h>

@interface ComponentAViewController ()

@end

@implementation ComponentAViewController

IMX_ROUTE_REGISTER(@"sisi://componentA")

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.center = self.view.center;
    titleLabel.text = @"ComponentAViewController";
    titleLabel.textColor = [UIColor redColor];
    [self.view addSubview:titleLabel];

    id<IMXComponentBProtocol> componentBModule = [IMXModule moduleForProtocol:@protocol(IMXComponentBProtocol)];

    NSLog(@"获取业务组件 B 的名称%@", [componentBModule getComponentBName]);
}

@end
