//
//  ViewController.m
//  MainProject
//
//  Created by Michael on 2017/6/30.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import "ViewController.h"
#import <IMXRoute/IMXRoute.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"组件化 demo";
}

- (IBAction)componentA:(UIButton *)sender {
    [IMXRoute handleURL:[NSURL URLWithString:@"sisi://componentA"]];
}

- (IBAction)componentB:(UIButton *)sender {

    [IMXRoute handleURL:[NSURL URLWithString:@"sisi://componentB"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
