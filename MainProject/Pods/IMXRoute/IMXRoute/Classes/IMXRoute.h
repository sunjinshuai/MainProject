//
//  IMXRoute.h
//  Route
//
//  Created by Dennis on 2018/7/18.
//  Copyright © 2018年 iTutorGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IMX_ROUTE_REGISTER(Route) \
+ (void)load { \
    [IMXRoute registerClass:[self class] \
                   forRoute:Route]; \
} \

#define IMX_SINGLETON_FOR_INTERFACE \
\
+ (instancetype)shared;

#define IMX_SINGLETON_FOR_IMPLEMENTATION(className) \
\
+ (instancetype)shared { \
    static className *instance = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        instance = [[self alloc] init]; \
    }); \
    return instance; \
}


// SCHEME
#define IMXROUTE_SCHEME_HTTPS   @"https"
#define IMXROUTE_SCHEME_HTTP    @"http"
#define IMXROUTE_SCHEME_NATIVE  @"sisi"

// HOST
#define IMXROUTE_HOST_MAIN      @"main"

// QUERY
#define IMXROUTE_QUERY_BACK     @"back"
#define IMXROUTE_QUERY_PRESENT  @"present"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (IMXRoute)

@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *routeParams;

/**
 *  @brief  Append Route Params
 *  @params routeParams Params Map
 */
- (void)appendRouteParams:(NSDictionary<NSString *, NSString *> *)routeParams;

/**
 *  @brief  Remove Route Params
 *  @params keys Params Keys
 */
- (void)removeRouteParamsWithKeys:(NSArray<NSString *> *)keys;

@end

typedef NS_ENUM(NSUInteger, IMXRouteType) {
    // URL that will go to the a native View
    // e.g. tutorabc://booking
    IMXRouteTypeNative,
    
    // URL that will go to the a web View
    // e.g. http(s)://www.itutorgroup.com
    IMXRouteTypeWeb,
    
    // URL that will perform the method openURL: method of UIApplication.
    // e.g. telprompt://13888888888, weixin://dl/business/?ticket=ta428d
    IMXRouteTypeOther,
};

@interface NSURL (IMXRoute)

/**
 *  @brief  Append Queries
 *  @params queries Query Map
 *  @return Same URL instance with added query items
 */
- (NSURL *)appendQueries:(NSDictionary<NSString *, NSString *> *)queries;

/**
 *  @brief  Parse Queries
 *  @return A query items map
 */
- (NSDictionary<NSString *, NSString *> *)parseQueries;

@end

@interface IMXRoute : NSObject

/**
 *  @brief  Register Route Manually
 *  @params aClass className
 *  @params route  routeName
 *
 *  @Important If you want to register routes automatically
 *             You just create a plist file inside module's bundle
 *             The plist's key is 'route', value is 'className'
 *             Of course, routes plist file naming format is 'ITGRoutes_*.plist'
 *             PLEASE FOLLOW THE NAMING FORMAT!!!
 *
 *             Suggest register Route in '+(load)' method
 */
+ (void)registerClass:(Class)aClass
             forRoute:(NSString *)route;

/**
 *  @brief  ClassforRoute
 *  @params route  routeName
 *  @return aClass class
 */
+ (Class _Nullable)classforRoute:(NSString *)route;

/**
 *  @brief  RouteForClass
 *  @params aClass class
 *  @return Route  routeName
 */
+ (NSString * _Nullable)routeForClass:(Class)aClass;

/**
 *  Returns a Boolean value indicating whether ITGRoute is available to handle a URL scheme.
 */
+ (BOOL)canHandleURL:(NSURL *)URL;

/**
 *  Handle URL, it will open/back a native/web interface, or do something others
 */
+ (void)handleURL:(NSURL *)URL;

// -------------------- Handle Route Helper -------------------------
/**
 *  Handle URL, it will present a native/web interface
 */
+ (void)presentURL:(NSURL *)URL;

/**
 *  Handle URL, it will back a native/web interface which in the 'SAME' navigation stack
 */
+ (void)backURL:(NSURL *)URL;

/**
 * Handle URL, it will back to previous interface with params
 */
+ (void)backWithParams:(NSDictionary<NSString *, NSString *> * _Nullable)params;

// -------------------- Interface Helper -------------------------
/**
 *  @return Current visibleViewController on screen
 */
+ (UIViewController *)visibleViewController;

/**
 *  Dismiss all presented visibleViewController
 *  @params completion The finished callback
 */
+ (void)dismissAllPresentedViewControllersWithCompletion:(void (^ _Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END

