//
//  AtourAPMManager.m
//  AtourAPMSDK
//
//  Created by sue on 2020/12/8.
//

#import "AtourAPMManager.h"
#import "AAFPSMonitor.h"
#import "AASystemMonitor.h"
#import "AACacheBySqlite.h"
#import "AAANRMonitor.h"
void *AtourApmQueueTag = &AtourApmQueueTag;


@interface AtourAPMManager ()<AAFPSMonitorDelegate ,AASystemMonitorDelegate,AAANRMonitorDelegate>
@property (nonatomic, strong) AACacheBySqlite *cache;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end
@implementation AtourAPMManager

+ (AtourAPMManager *)sharedInstance {
    static AtourAPMManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ///apmsdk-v1 代表代码版本 为升级适配准备
        _cache = [[AACacheBySqlite alloc] initWithFilePath:[self filePathForData:@"apm-v1"]];
        if (_cache == nil) {
            NSLog(@"SqliteException: init  Cache in Sqlite fail");
        }
        NSString *label = [NSString stringWithFormat:@"com.atourapm.serialQueue.%p", self];
        _serialQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_serialQueue, AtourApmQueueTag, &AtourApmQueueTag, NULL);
    }
    return self;
}

/**
 开启监控
 */
- (void)start {
    [[AAFPSMonitor sharedInstance] addDelegate:self];
    [[AAFPSMonitor sharedInstance] start];
    [[AASystemMonitor sharedInstance] addDelegate:self];
    [[AASystemMonitor sharedInstance] start];
    [[AAANRMonitor sharedInstance] addDelegate:self];
    [[AAANRMonitor sharedInstance] start];
}

/**
 根据配置项开启监控
 */
- (void)startWithConfigOptions:(AtourAPMConfigOptions)option {
   
    if (option & AtourAPMFPS) {
        [[AAFPSMonitor sharedInstance] addDelegate:self];
        [[AAFPSMonitor sharedInstance] start];
    }
    
    if (option & AtourAPMANR) {
        [[AAANRMonitor sharedInstance] addDelegate:self];
        [[AAANRMonitor sharedInstance] start];
    }
    
    if (option & AtourAPMSystem) {
        [[AASystemMonitor sharedInstance] addDelegate:self];
        [[AASystemMonitor sharedInstance] start];
    }
    
}

- (void)stop {
    [[AAFPSMonitor sharedInstance] stop];
    [[AASystemMonitor sharedInstance] stop];
    [[AAANRMonitor sharedInstance] stop];
}

/**
 设置采集频率 内存 cpu等数据
 */
- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    [AASystemMonitor sharedInstance].timeInterval = timeInterval;
    [[AASystemMonitor sharedInstance] stop];
    [[AASystemMonitor sharedInstance] start];
}

/**
 FPS 更新回调
 @param fps 刷新率
 @param timestamp 时间戳
 */
- (void)didUpdateFPS:(float)fps timestamp:(NSString *)timestamp{
    dispatch_async(_serialQueue, ^{
        [self.cache addFPS:fps timestamp:timestamp];
    });
}

/**
 CPU 使用情况回调
 @param app_cpu_usage 应用 CPU 使用情况
 @param timestamp 时间戳
 */
- (void)didUpdateAppCPUUsage:(float)app_cpu_usage timestamp:(NSString *)timestamp{
    dispatch_async(_serialQueue, ^{
        [self.cache addCpuUsage:app_cpu_usage timestamp:timestamp];
    });
}

/**
 RAM 使用情况回调
 @param app_ram_usage 应用 RAM 使用情况
 @param system_ram_usage 系统 RAM 使用情况
 @param timestamp 时间戳
 */
- (void)didUpdateAppRamUsage:(unsigned long long)app_ram_usage
              systemRamUsage:(aa_system_ram_usage)system_ram_usage
                   timestamp:(NSString *)timestamp {
    dispatch_async(_serialQueue, ^{
        [self.cache addAppRamUsage:app_ram_usage/1024 timestamp:timestamp];
    });
}

/**
 网络流量监控
 @param sent 实时上行 byte/timeInterval
 @param received received 实时下行 byte/timeInterval
 @param total 总流量
 @param timestamp 时间戳
 */
- (void)didUpdateNetworkFlowSent:(unsigned int)sent
                        received:(unsigned int)received
                           total:(aa_flow_IOBytes)total
                       timestamp:(NSString *)timestamp{
    dispatch_async(_serialQueue, ^{
        [self.cache addNetworkFlow:(sent+received)/1024 timestamp:timestamp];
    });
}

/**
 卡顿回调
 @param callStack 卡顿日志
 @param timestamp 时间戳
 */
- (void)didRecievedANRInfo:(NSString *)callStack timestamp:(NSString *)timestamp{
    dispatch_async(_serialQueue, ^{
        [self.cache addANR:callStack timestamp:timestamp];
    });
}

#define AtourAPMSDKNumber @"AtourAPMSDKNumber"
- (NSString *)filePathForData:(NSString *)data {

    NSString  *directoryPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"APMSDK"];
    BOOL isDir = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir];
    if (!isExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    ///确保每组测试数据分开
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:AtourAPMSDKNumber];
    ///超过10组数据则清空
    if (index >= 10) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
        if (success) {
            index = 1;
            [[NSUserDefaults standardUserDefaults] setInteger:index forKey:AtourAPMSDKNumber];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSLog(@"delete all case when count reach 10");
        }
    }else {
        index++;
        [[NSUserDefaults standardUserDefaults] setInteger:index forKey:AtourAPMSDKNumber];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    NSString *filepath = [NSString stringWithFormat:@"%@/%@-%zd.sqlite",directoryPath, data,index];
    NSLog(@"filepath for %@ is %@", data, filepath);
    return filepath;
}

@end
