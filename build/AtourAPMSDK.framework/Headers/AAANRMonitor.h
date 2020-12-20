//
//  AAANRMonitor.h
//  AtourAPMSDK
//
//  Created by sue on 2020/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AAANRMonitor;
@protocol AAANRMonitorDelegate <NSObject>

/**
 卡顿回调
 @param callStack 卡顿日志
 @param timestamp 时间戳
 */
- (void)didRecievedANRInfo:(NSString *)callStack timestamp:(NSString *)timestamp;

@end


@interface AAANRMonitor : NSObject

/**
 记录日志-卡顿时间阈值，默认0.2s
 */
@property (nonatomic, assign, readonly) NSTimeInterval timeOutInterval;

/**
 记录日志-卡顿次数阈值，默认5次
 */
@property (nonatomic, assign, readonly) NSInteger timeOutCount;

/**
 单例对象

 @return AAANRMonitor
 */
+ (AAANRMonitor *)sharedInstance;

/**
 初始化，设置阈值

 @param timeOutInterval 记录日志-卡顿时间阈值
 @param timeOutCount 记录日志-卡顿次数阈值
 @return instancetype
 */
- (instancetype)initWithTimeOutInterval:(double)timeOutInterval timeOutCount:(NSInteger)timeOutCount;

/**
 初始化

 @return instancetype
 */
- (instancetype)init;

/**
 委托对象添加监控

 @param delegate 委托对象
 */
- (void)addDelegate:(id<AAANRMonitorDelegate>)delegate;

/**
 委托对象去掉监控
 
 @param delegate 委托对象
 */
- (void)removeDelegate:(id<AAANRMonitorDelegate>)delegate;

/**
 开启监控卡顿
 */
- (void)start;

/**
 关闭监控卡顿
 */
- (void)stop;

@end


NS_ASSUME_NONNULL_END
