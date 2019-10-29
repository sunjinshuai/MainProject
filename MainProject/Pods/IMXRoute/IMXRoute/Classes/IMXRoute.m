//
//  IMXRoute.h
//  Route
//
//  Created by Dennis on 2018/7/18.
//  Copyright © 2018年 iTutorGroup. All rights reserved.
//

#import "IMXRoute.h"
#import <objc/runtime.h>
#import <objc/message.h>

static const char *IMXRouteParamsKey = "IMXRouteParams";

@implementation UIViewController (IMXRoute)

- (UIViewController *)_presentingViewController {
    UIViewController *interface = [self presentingViewController];
    if (interface != nil) {
        if ([interface isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBar = (UITabBarController *)interface;
            interface = tabBar.selectedViewController;
        }
        if ([interface isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navi = (UINavigationController *)interface;
            interface = navi.topViewController;
        }
    }
    return interface;
}

- (void)appendRouteParams:(NSDictionary<NSString *, NSString *> *)routeParams {
    NSMutableDictionary<NSString *, NSString *> *originParams = [[NSMutableDictionary alloc]
                                                                 initWithDictionary:self.routeParams];
    [originParams addEntriesFromDictionary:routeParams];
    self.routeParams = originParams;
}

- (void)removeRouteParamsWithKeys:(NSArray<NSString *> *)keys {
    NSMutableDictionary<NSString *, NSString *> *originParams = [[NSMutableDictionary alloc]
                                                                 initWithDictionary:self.routeParams];
    [originParams removeObjectsForKeys:keys];
    self.routeParams = originParams;
}

- (NSDictionary<NSString *, NSString *> *)routeParams {
    return objc_getAssociatedObject(self, &IMXRouteParamsKey) ? : @{};
}

- (void)setRouteParams:(NSDictionary<NSString *, NSString *> *)routeParams {
    objc_setAssociatedObject(self, &IMXRouteParamsKey, routeParams, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation NSString (IMXRoute)

- (NSString *)removeSpaceCharacterSets {
    NSMutableString *m_string = [[NSMutableString alloc] initWithString:self];
    NSArray<NSString *> *characterSets = @[@" ", @"\n", @"\r\n", @"\r", @"\t"];
    for (NSString *characterSet in characterSets) {
        [m_string stringByReplacingOccurrencesOfString:characterSet
                                            withString:@""];
    }
    return m_string;
}

@end

@implementation NSURL (IMXRoute)

- (IMXRouteType)routeType {
    NSString *scheme = [self.scheme lowercaseString];
    if ([scheme isEqualToString:IMXROUTE_SCHEME_HTTPS] ||
        [scheme isEqualToString:IMXROUTE_SCHEME_HTTP]) {
        return IMXRouteTypeWeb;
    } else if ([scheme isEqualToString:IMXROUTE_SCHEME_NATIVE]) {
        return IMXRouteTypeNative;
    } else {
        return IMXRouteTypeOther;
    }
}

- (BOOL)isMainRoute {
    NSString *host = [self.host lowercaseString];
    return ([self routeType] == IMXRouteTypeNative &&
            [host isEqualToString:IMXROUTE_HOST_MAIN]);
}

- (NSString *)baseURLString {
    return [NSString stringWithFormat:@"%@://%@%@",
            [self scheme] ? : @"",
            [self host] ? : @"",
            [self path] ? : @""];
}

- (NSURL *)appendQueries:(NSDictionary<NSString *, NSString *> *)queries {
    if (queries.count == 0) {
        return self;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:YES];
    NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray arrayWithArray:components.queryItems];
    [queries enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key,
                                                 NSString * _Nonnull value,
                                                 BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[NSString class]] &&
            [value isKindOfClass:[NSString class]]) {
            [queryItems addObject:[[NSURLQueryItem alloc]
                                   initWithName:key
                                   value:[value removeSpaceCharacterSets]]];
        } else {
            NSAssert(NO, @"The key: %@, value: %@ are not inherit NSString", key, value);
        }
    }];
    components.queryItems = queryItems;
    return components.URL;
}

- (NSDictionary<NSString *, NSString *> *)parseQueries {
    // 此处针对h5链接可能在path中出现#，而url component无法识别的问题做处理
    NSString *processedUrlStr;
    if ([self.absoluteString containsString:@"#/"]) {
        processedUrlStr = [self.absoluteString stringByReplacingOccurrencesOfString:@"#/" withString:@""];
    } else {
        processedUrlStr = self.absoluteString;
    }
    NSURL *processedUrl = [NSURL URLWithString:processedUrlStr];
    NSURLComponents *components = [NSURLComponents componentsWithURL:processedUrl resolvingAgainstBaseURL:YES];
    NSMutableDictionary<NSString *, NSString *> *queries = [NSMutableDictionary dictionary];
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull queryItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [queries setObject:[queryItem.value removeSpaceCharacterSets] ? : @""
                    forKey:queryItem.name];
    }];
    return queries;
}

@end

@interface IMXRoute ()

@property (nonatomic, strong) NSMapTable<NSString *, id> *routeMapTable;

@end

@implementation IMXRoute

+ (void)load {
    [IMXRoute registerAllRoutesAutomatically];
}

IMX_SINGLETON_FOR_IMPLEMENTATION(IMXRoute)

+ (BOOL)canHandleURL:(NSURL *)URL {
    switch ([URL routeType]) {
        case IMXRouteTypeNative: {
            if ([URL isMainRoute]) { return YES; }
            Class cls = [IMXRoute classforRoute:[URL baseURLString]];
            return cls != nil;
        }
            break;
        case IMXRouteTypeWeb: {
            return nil;
        }
            break;
        case IMXRouteTypeOther: {
            return [UIApplication.sharedApplication canOpenURL:URL];
        }
            break;
        default:
            break;
    }
    
    return NO;
}

+ (void)handleURL:(NSURL * _Nonnull)URL {
    NSParameterAssert(URL);
    switch ([URL routeType]) {
        case IMXRouteTypeNative: {
            [self handleNativeURL:URL];
        }
            break;
        case IMXRouteTypeWeb: {
            [self handleWebURL:URL];
        }
            break;
        case IMXRouteTypeOther: {
            [self handleOtherURL:URL];
        }
            break;
        default:
            break;
    }
}

+ (void)handleNativeURL:(NSURL * _Nonnull)URL {
    NSDictionary<NSString *, NSString *> *queries = [URL parseQueries];
    // If URL is main route, then it should back to the root interface
    if ([URL isMainRoute]) {
        UIViewController *rootViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        [self dismissAllPresentedViewControllersWithCompletion:^{
            [[self visibleViewController].navigationController popToRootViewControllerAnimated:YES];
        }];
        rootViewController.routeParams = queries;
    } else {
        BOOL needPresent = [queries[IMXROUTE_QUERY_PRESENT] boolValue];
        BOOL needBack    = [queries[IMXROUTE_QUERY_BACK] boolValue];
        UINavigationController *visibleNavigationController = [self visibleViewController].navigationController;
        if (visibleNavigationController == nil && needPresent == NO) {
            NSAssert(NO, @"Navigation is not exist");
            return;
        }
        Class cls = [IMXRoute classforRoute:[URL baseURLString]];
        if (cls == nil) {
            NSAssert(NO, @"Route - %@ is not registered", [URL baseURLString]);
            return;
        }
        if (needPresent && needBack) {
            NSAssert(NO, @"back && present can not execute at the same time");
        } else if (needBack) {
            for (UIViewController *childViewController in visibleNavigationController.childViewControllers) {
                if ([childViewController class] == cls) {
                    [childViewController appendRouteParams:queries];
                    [childViewController removeRouteParamsWithKeys:@[IMXROUTE_QUERY_BACK]];
                    [visibleNavigationController popToViewController:childViewController
                                                            animated:YES];
                    break;
                }
            }
        } else {
            UIViewController *interface = [cls new];
            [interface appendRouteParams:queries];
            [visibleNavigationController pushViewController:interface
                                                   animated:YES];
        }
    }
}

+ (void)handleWebURL:(NSURL * _Nonnull)URL {
    NSDictionary<NSString *, NSString *> *queries = [URL parseQueries];
    UINavigationController *visibleNavigationController = [self visibleViewController].navigationController;
//    Class<ITGWebViewProtocol> webClass = [ITGRoute classforRoute:ITGWebViewRoute];
//    if (webClass) {
//        ITGViewController *interface = (ITGViewController *)[webClass instanceWithURL:URL];
//        [interface appendRouteParams:queries];
//        BOOL needPresent = [queries[ITGROUTE_QUERY_PRESENT] boolValue];
//        if (needPresent) {
//            if ([interface respondsToSelector:@selector(setPresented:)]) {
//                interface.presented = YES;
//            }
//            [interface removeRouteParamsWithKeys:@[ITGROUTE_QUERY_PRESENT]];
//            [[self visibleViewController]
//             presentViewController:[[ITGNavigationController alloc]
//                                    initWithRootViewController:interface]
//             animated:YES
//             completion:nil];
//        } else {
//            [visibleNavigationController pushViewController:interface
//                                                   animated:YES];
//        }
//    } else {
//        NSAssert(NO, @"Please add - pod 'ITGWebView' - in your Podfile");
//    }
}

+ (void)handleOtherURL:(NSURL * _Nonnull)URL {
    if (@available(iOS 10.0, *)){
        [[UIApplication sharedApplication] openURL:URL
                                           options:@{}
                                 completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

+ (void)presentURL:(NSURL * _Nonnull)URL {
    [self handleURL:[URL appendQueries:@{IMXROUTE_QUERY_PRESENT : @"1"}]]; // @"1" = ture
}

+ (void)backURL:(NSURL * _Nonnull)URL {
    [self handleURL:[URL appendQueries:@{IMXROUTE_QUERY_BACK : @"1"}]]; // @"1" = ture
}

+ (void)backWithParams:(NSDictionary<NSString *,NSString *> *)params {
    UIViewController *interface = [IMXRoute visibleViewController];
    NSUInteger index = [interface.navigationController.childViewControllers indexOfObject:interface];
    if (index > 0) {
        UIViewController *preInterface = [interface.navigationController.childViewControllers objectAtIndex:index - 1];
        [preInterface appendRouteParams:params];
        [interface.navigationController popViewControllerAnimated:YES];
    } else {
        UIViewController *presentingViewController = [interface _presentingViewController];
        [presentingViewController appendRouteParams:params];
        [interface.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

+ (void)dismissAllPresentedViewControllersWithCompletion:(void (^)(void))completion {
    UIViewController *rootViewController    = [[UIApplication sharedApplication] delegate].window.rootViewController;
    UIViewController *visibleViewController = [self visibleViewController];
    
    BOOL atRootStack = NO;
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *)rootViewController;
        atRootStack = ([tabBar.childViewControllers containsObject:visibleViewController] ||
                       [tabBar.childViewControllers containsObject:visibleViewController.navigationController]);
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi = (UINavigationController *)rootViewController;
        atRootStack = [navi.childViewControllers containsObject:visibleViewController];
    } else {
        atRootStack = (visibleViewController == rootViewController);
    }
    if (atRootStack == NO) {
        [visibleViewController dismissViewControllerAnimated:NO completion:^{
            [self dismissAllPresentedViewControllersWithCompletion:completion];
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

+ (UIViewController *)visibleViewController {
    UIViewController *rootViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    while ([rootViewController presentedViewController] != nil) {
        rootViewController = [rootViewController presentedViewController];
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *)rootViewController;
        rootViewController = tabBar.selectedViewController;
    }
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi = (UINavigationController *)rootViewController;
        rootViewController = navi.visibleViewController;
    }
    return rootViewController;
}

- (NSMapTable<NSString *, id> *)routeMapTable {
    if (!_routeMapTable) {
        _routeMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                               valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _routeMapTable;
}

+ (void)registerAllRoutesAutomatically {
    [self registerRoutesInBundle:[NSBundle mainBundle]];
    
    NSMutableArray *libPaths = [NSMutableArray new];
    // Static Framework
    NSArray<NSString *> *staticPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"bundle" inDirectory:@""];
    [libPaths addObjectsFromArray:staticPaths];
    
    // Dynamic Framework
    NSArray<NSString *> *dynamicPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"framework" inDirectory:@"Frameworks"];
    [libPaths addObjectsFromArray:dynamicPaths];
    
    for (NSString *path in libPaths) {
        [self registerRoutesInBundle:[NSBundle bundleWithPath:path]];
    }
}

+ (void)registerRoutesInBundle:(NSBundle *)bundle {
    NSArray<NSString *> *plistPaths = [bundle pathsForResourcesOfType:@"plist" inDirectory:@""];
    for (NSString *plistPath in plistPaths) {
        if ([plistPath containsString:@"IMXRoutes"]) {
            [self registerRouteInPlistPath:plistPath bundle:bundle];
        };
    }
}

+ (void)registerRouteInPlistPath:(NSString *)plistPath bundle:(NSBundle *)bundle {
    NSString *bundleName = [bundle infoDictionary][@"CFBundleName"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if (!plistDict) {
        return;
    }
    for (NSString *route in plistDict.allKeys) {
        NSString *classString = (NSString *)plistDict[route];
        Class aClass = NSClassFromString(classString) ? : NSClassFromString([NSString stringWithFormat:@"%@.%@", bundleName, classString]);
        if (aClass) {
            [IMXRoute registerClass:aClass forRoute:route];
        };
    }
}

+ (void)registerClass:(Class)aClass
             forRoute:(NSString *)route{
    NSParameterAssert(aClass);
    NSParameterAssert(route);
    route = [route stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![aClass isSubclassOfClass:[NSObject class]]) {
        [NSException raise:@"Wrong Class Type"
                    format:@"Class should inherit from NSObject"];
        return;
    }
    if (route.length == 0) {
        [NSException raise:@"Route Wrong"
                    format:@"Route should not be blank"];
        return;
    }
    if ([IMXRoute classforRoute:route]) {
        [NSException raise:@"Route Already Exists"
                    format:@"'%@' route Already Exists", route];
        return;
    }
    if ([IMXRoute routeForClass:aClass]) {
        [NSException raise:@"Class Already Exists"
                    format:@"'%@' Class Already Exists", NSStringFromClass(aClass)];
        return;
    }
    @synchronized([IMXRoute shared].routeMapTable) {
        [[IMXRoute shared].routeMapTable setObject:aClass
                                            forKey:route];
    }
}

+ (Class)classforRoute:(NSString *)route {
    @synchronized([IMXRoute shared].routeMapTable) {
        return [[IMXRoute shared].routeMapTable objectForKey:route];
    }
}

+ (NSString *)routeForClass:(Class)aClass {
    @synchronized([IMXRoute shared].routeMapTable) {
        NSEnumerator *enumerator = [[IMXRoute shared].routeMapTable keyEnumerator];
        NSString *key = nil;
        while ((key = [enumerator nextObject])) {
            Class bClass = [[IMXRoute shared].routeMapTable objectForKey:key];
            if (bClass == aClass) {
                return key;
            }
        }
        return nil;
    }
}

@end
