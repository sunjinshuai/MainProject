//
//  IMXModule.h
//  Module
//
//  Created by Dennis on 2018/7/18.
//  Copyright © 2018年 iTutorGroup. All rights reserved.
//

#import "IMXModule.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface IMXModule ()

@property (nonatomic, strong) NSMapTable<NSString *, id> *moduleMapTable;

@end

@implementation IMXModule

+ (IMXModule *)shared {
    static IMXModule *moduleManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        moduleManager = [[self alloc] init];
    });
    return moduleManager;
}

+ (void)registerModuleClass:(Class)cls protocol:(Protocol *)protocol {
    [self registerModule:[cls new] protocol:protocol];
}

+ (void)registerModuleClassName:(NSString *)className protocolName:(NSString *)protocolName {
    [self registerModule:[NSClassFromString(className) new]
                protocol:NSProtocolFromString(protocolName)];
}

+ (void)registerModule:(id<IMXModuleBaseProtocol>)module protocol:(Protocol *)protocol {
    NSParameterAssert(module);
    NSParameterAssert(protocol);
    @synchronized ([IMXModule shared].moduleMapTable) {
        if ([module conformsToProtocol:protocol] == NO) {
            NSAssert(NO, @"Module: %@ don't conformsToProtocol: %@", module, protocol);
            return;
        }
        NSString *protocolName = NSStringFromProtocol(protocol);
        if (protocolName.length == 0) {
            NSAssert(NO, @"Protocol's name is null: %@", protocolName);
            return;
        }
        if ([[IMXModule shared].moduleMapTable.keyEnumerator.allObjects containsObject:protocolName]) {
            NSAssert(NO, @"Module: %@ is already registered", module);
            return;
        }
        if ([module conformsToProtocol:@protocol(IMXModuleBaseProtocol)] == NO) {
            // 如果没有实现ITGModuleBaseProtocol, 只作警告处理 
            NSLog(@"Warning: Module: %@ don't conformsToProtocol: ITGModuleBaseProtocol", module);
        }
        [[IMXModule shared].moduleMapTable setObject:module forKey:protocolName];
    }
}

+ (id)moduleForProtocol:(Protocol *)protocol {
    NSParameterAssert(protocol);
    @synchronized ([IMXModule shared].moduleMapTable) {
        NSString *protocolName = NSStringFromProtocol(protocol);
        if (protocolName.length == 0) {
            NSAssert(NO, @"Protocol's name is null: %@", protocol);
            return nil;
        }
        if ([[IMXModule shared].moduleMapTable.keyEnumerator.allObjects containsObject:protocolName] == NO) {
            NSLog(@"protocol :%@ don't implement by any module", protocol);
            return nil;
        } else {
            return [[IMXModule shared].moduleMapTable objectForKey:protocolName];
        }
    }
}

- (NSMapTable<NSString *, id> *)moduleMapTable {
    if (!_moduleMapTable) {
        _moduleMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _moduleMapTable;
}

@end

#pragma BaseProtocol
@implementation IMXModule (BaseProtocol)

+ (void)login {
    @synchronized([IMXModule shared].moduleMapTable) {
        [[IMXModule shared].moduleMapTable.objectEnumerator.allObjects enumerateObjectsUsingBlock:^(id<IMXModuleBaseProtocol> _Nonnull module,
                                                                                                    NSUInteger idx,
                                                                                                    BOOL * _Nonnull stop) {
            if ([module respondsToSelector:@selector(applicationDidLogin)]) {
                [module applicationDidLogin];
            }
        }];
    }
}

+ (void)logout {
    @synchronized([IMXModule shared].moduleMapTable) {
        [[IMXModule shared].moduleMapTable.objectEnumerator.allObjects enumerateObjectsUsingBlock:^(id<IMXModuleBaseProtocol> _Nonnull module,
                                                                                                    NSUInteger idx,
                                                                                                    BOOL * _Nonnull stop) {
            if ([module respondsToSelector:@selector(applicationDidLogout)]) {
                [module applicationDidLogout];
            }
        }];
    }
}

@end
