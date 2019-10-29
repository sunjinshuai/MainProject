//
//  ComponentBModule.m
//  ComponentB
//
//  Created by aikucun on 2019/10/29.
//

#import "ComponentBModule.h"
#import <IMXModule/IMXModule.h>
#import <IMXInterface/IMXComponentBProtocol.h>

@interface ComponentBModule () <IMXComponentBProtocol>

@end

@implementation ComponentBModule

IMX_MODULE_REGISTER(IMXComponentBProtocol)

- (nullable NSString *)getComponentBName {
    return @"ComponentBModule";
}

@end
