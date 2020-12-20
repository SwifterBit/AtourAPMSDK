//
//  AASystemMonitor.h
//  AtourAPMSDK
//
//  Created by sue on 2020/12/10.
//

#import <Foundation/Foundation.h>
#import "AACPUUsage.h"
#import "AARAMUsage.h"
#import "AANetworkFlow.h"
@class AASystemMonitor;
NS_ASSUME_NONNULL_BEGIN
@protocol AASystemMonitorDelegate <NSObject>
/**
 CPU 使用情况回调
 @param app_cpu_usage 应用 CPU 使用情况
 @param timestamp 时间戳
 */
- (void)didUpdateAppCPUUsage:(float)app_cpu_usage timestamp:(NSString *)timestamp;

/**
 RAM 使用情况回调
 @param app_ram_usage 应用 RAM 使用情况
 @param system_ram_usage 系统 RAM 使用情况
 @param timestamp 时间戳
 */
- (void)didUpdateAppRamUsage:(unsigned long long)app_ram_usage
              systemRamUsage:(aa_system_ram_usage)system_ram_usage
                   timestamp:(NSString *)timestamp;

/**
 网络流量监控
 @param sent 上行 byte/timeInterval
 @param received received 下行 byte/timeInterval
 @param total 流量结构体
 @param timestamp 时间戳
 */
- (void)didUpdateNetworkFlowSent:(unsigned int)sent
                        received:(unsigned int)received
                           total:(aa_flow_IOBytes)total
                       timestamp:(NSString *)timestamp;;

@end

@interface AASystemMonitor : NSObject

/**
 监控间隔
 */
@property (nonatomic, assign) NSTimeInterval timeInterval;


/**
 单例对象
 
 @return AASystemMonitor
 */
+ (AASystemMonitor *)sharedInstance;

/**
 委托对象添加监控
 
 @param delegate 委托对象
 */
- (void)addDelegate:(id<AASystemMonitorDelegate>)delegate;

/**
 委托对象去掉监控
 
 @param delegate 委托对象
 */
- (void)removeDelegate:(id<AASystemMonitorDelegate>)delegate;

/**
 开启监控
 */
- (void)start;

/**
 关闭监控
 */
- (void)stop;
@end

NS_ASSUME_NONNULL_END
