//
//  MYProtocolManager.h
//  MYProtocolManager
//
//  Created by Michael on 2017/6/29.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYProtocolManager : NSObject

+ (void)registServiceProvide:(id)provide forProtocol:(Protocol*)protocol;

+ (id)serviceProvideForProtocol:(Protocol *)protocol;

@end
