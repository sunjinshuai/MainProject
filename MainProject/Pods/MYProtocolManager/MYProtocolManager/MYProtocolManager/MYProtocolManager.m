//
//  MYProtocolManager.m
//  MYProtocolManager
//
//  Created by Michael on 2017/6/29.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import "MYProtocolManager.h"

@interface MYProtocolManager ()

@property (nonatomic, strong) NSMutableDictionary *serviceProvideSource;
@end

@implementation MYProtocolManager

+ (MYProtocolManager *)sharedInstance
{
    static MYProtocolManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serviceProvideSource = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (void)registServiceProvide:(id)provide forProtocol:(Protocol*)protocol
{
    if (provide == nil || protocol == nil)
    return;
    [[self sharedInstance].serviceProvideSource setObject:provide forKey:NSStringFromProtocol(protocol)];
}

+ (id)serviceProvideForProtocol:(Protocol *)protocol
{
    return [[self sharedInstance].serviceProvideSource objectForKey:NSStringFromProtocol(protocol)];
}


@end
