//
//  IMXModuleBaseProtocol.h
//  Module
//
//  Created by Dennis on 2018/7/18.
//  Copyright © 2018年 iTutorGroup. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol IMXModuleBaseProtocol <NSObject>

@optional

// TODO
/**
 *  Application Invoke
 */
//- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
//
//- (void)applicationWillResignActive:(UIApplication *)application;
//
//- (void)applicationDidEnterBackground:(UIApplication *)application;
//
//- (void)applicationWillEnterForeground:(UIApplication *)application;
//
//- (void)applicationDidBecomeActive:(UIApplication *)application;
//
//- (void)applicationWillTerminate:(UIApplication *)application;
// ...

/** TODO
 *  Application Life
 */

// 当前用户成功登录
- (void)applicationDidLogin;

// 当前用户成功登出
- (void)applicationDidLogout;

// And so on...

@end
