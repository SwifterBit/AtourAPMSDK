//
//  AtourAPMManager.h
//  AtourAPMSDK
//
//  Created by sue on 2020/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, AtourAPMConfigOptions) {
    AtourAPMNone       = 0,          ///全部
    AtourAPMFPS       = 1 << 0,     ///fps
    AtourAPMANR       = 1 << 1,     ///卡顿
    AtourAPMSystem    = 1 << 2,  ///cpu、ram、networkflow
};


@interface AtourAPMManager : NSObject
/**
 单例对象
 
 @return AtourAPMManager
 */
+ (AtourAPMManager *)sharedInstance;
/**
 开启监控
 */
- (void)start;

/**
 根据配置项开启监控
 */
- (void)startWithConfigOptions:(AtourAPMConfigOptions)option;

/**
 关闭监控
 */
- (void)stop;

/**
 设置采集频率 内存 cpu等数据
 */
- (void)setTimeInterval:(NSTimeInterval)timeInterval;
@end

NS_ASSUME_NONNULL_END
