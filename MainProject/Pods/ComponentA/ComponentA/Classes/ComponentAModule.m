//
//  ComponentAModule.m
//  ComponentA
//
//  Created by aikucun on 2019/10/29.
//

#import "ComponentAModule.h"
#import <IMXModule/IMXModule.h>
#import <IMXInterface/IMXComponentAProtocol.h>

@interface ComponentAModule () <IMXComponentAProtocol>

@end

@implementation ComponentAModule

IMX_MODULE_REGISTER(IMXComponentAProtocol)

- (nullable NSString *)getComponentAName {
    return @"ComponentAModule";
}

@end
