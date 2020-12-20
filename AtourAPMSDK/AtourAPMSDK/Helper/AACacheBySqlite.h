//
//  AACacheBySqlite.h
//  AtourAPMSDK
//
//  Created by sue on 2020/12/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 一个基于Sqlite封装的接口，用于存储统计的数据
 */
@interface AACacheBySqlite : NSObject

/**
 根据传入的文件路径初始化
 @param filePath  传入的数据文件路径
 @return id 实例
 */
- (id)initWithFilePath:(NSString *)filePath;

/**
 添加CPUUsage 数据
 @param cpuUsage app占用CPU 百分比
 @param timestamp 时间戳
 */
- (void)addCpuUsage:(float)cpuUsage timestamp:(NSString *)timestamp;

/**
 添加RAMUsage 数据
 @param app_ram_usage  app占用的RAM
 @param timestamp 时间戳
 */
- (void)addAppRamUsage:(float)app_ram_usage timestamp:(NSString *)timestamp;
/**
 添加流量数据
@param received app收到的流量
@param timestamp 时间戳
*/
- (void)addNetworkFlow:(unsigned int)received timestamp:(NSString *)timestamp;

/**
 添加FPS 数据
@param fps 刷新率
@param timestamp 时间戳
 */
- (void)addFPS:(float)fps timestamp:(NSString *)timestamp;

/**
 添加ANR 数据
@param callStack 堆栈数据
@param timestamp 时间戳
 */
- (void)addANR:(NSString *)callStack timestamp:(NSString *)timestamp;
@end

NS_ASSUME_NONNULL_END
