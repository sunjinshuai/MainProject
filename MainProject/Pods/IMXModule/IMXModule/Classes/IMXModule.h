//
//  IMXModule.h
//  Module
//
//  Created by Dennis on 2018/7/18.
//  Copyright © 2018年 iTutorGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMXModuleBaseProtocol.h"

#define IMX_MODULE_REGISTER(ProtocolName) \
+ (void)load { \
    [IMXModule registerModuleClass:[self class] \
                          protocol:@protocol(ProtocolName)]; \
} \

NS_ASSUME_NONNULL_BEGIN

@interface IMXModule : NSObject

/**
 *  @brief  Register Module By Class
 *  @params cls      Class Name
 *  @params protocol Protocol Name
 */
+ (void)registerModuleClass:(Class)cls protocol:(Protocol *)protocol;

// ------------ Register Module Helper ------------

/**
 *  @brief  Register Module By Module Instance
 *  @params module   Module Instance
 *  @params protocol @(Protocol Name)
 */
+ (void)registerModule:(id<IMXModuleBaseProtocol>)module protocol:(Protocol *)protocol;

/**
 *  @brief  Register     Module By Module Instance
 *  @params className    Class Name
 *  @params protocolName Protocol Name
 */
+ (void)registerModuleClassName:(NSString *)className protocolName:(NSString *)protocolName;

/**
 *  @brief  Get Module By Protocol
 *  @params protocol Protocol Name
 *  @return Module Instance
 */
+ (id)moduleForProtocol:(Protocol *)protocol;

NS_ASSUME_NONNULL_END

@end

/**
 *  Execute all module's implementation for ITGModuleBaseProtocol
 */
@interface IMXModule (BaseProtocol)

+ (void)login;

+ (void)logout;

@end
