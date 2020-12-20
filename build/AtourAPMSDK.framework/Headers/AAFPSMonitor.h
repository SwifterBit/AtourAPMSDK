//
//  AAFPSMonitor.h
//  AtourAPMSDK
//
//  Created by sue on 2020/12/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AAFPSMonitor;
@protocol AAFPSMonitorDelegate <NSObject>

/**
 FPS 更新回调
 @param fps 刷新率
 @param timestamp 时间戳
 */
- (void)didUpdateFPS:(float)fps timestamp:(NSString *)timestamp;

@end
@interface AAFPSMonitor : NSObject
/**
 FPS 检测间隔时间默认1s
 */
@property (nonatomic, assign) NSTimeInterval updateFPSInterval;

/**
 单例对象
 
 @return AAFPSMonitor
 */
+ (instancetype)sharedInstance;

/**
 委托对象添加监控
 
 @param delegate 委托对象
 */
- (void)addDelegate:(id<AAFPSMonitorDelegate>)delegate;

/**
 委托对象去除监控
 
 @param delegate 委托对象
 */
- (void)removeDelegate:(id<AAFPSMonitorDelegate>)delegate;

/**
 开启检测 FPS
 */
- (void)start;

/**
 关闭检测 FPS
 */
- (void)stop;
@end

NS_ASSUME_NONNULL_END
