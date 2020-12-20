//
//  AASystemMonitor.m
//  AtourAPMSDK
//
//  Created by sue on 2020/12/10.
//

#import "AASystemMonitor.h"
#import "AADateFormatter.h"

@interface AASystemMonitor () {
    struct {
        unsigned int didUpdateCPUUsage     :1;
        unsigned int didUpdateRamUsage     :1;
        unsigned int didUpdateNetworkFlow  :1;
    } _delegateFlags;
    aa_flow_IOBytes _networkFlow;
    aa_flow_IOBytes _startNetworkFlow;
    BOOL _isFisrtGetNetworkFlow;
}

/**
 委托回调对象集合
 */
@property (nonatomic, strong) NSHashTable *hashTable;

/**
 定时器
 */
@property (nonatomic, strong) dispatch_source_t source_t;

@end


@implementation AASystemMonitor

/**
 单例对象
 
 @return AASystemMonitor
 */
+ (AASystemMonitor *)sharedInstance  {
    static AASystemMonitor *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _timeInterval = 1.0;
        _isFisrtGetNetworkFlow = YES;
    }
    return self;
}

/**
 释放对象
 */
- (void)dealloc {
    [self stop];
    [self.hashTable removeAllObjects];
}

/**
 委托对象添加监控
 
 @param delegate 委托对象
 */
- (void)addDelegate:(id<AASystemMonitorDelegate>)delegate {
    [self.hashTable addObject:delegate];
}

/**
 委托对象去掉监控
 
 @param delegate 委托对象
 */
- (void)removeDelegate:(id<AASystemMonitorDelegate>)delegate {
    if ([self.hashTable containsObject:delegate]) {
        [self.hashTable removeObject:delegate];
    }
}

/**
 开启监控
 */
- (void)start {
    if (!_source_t) {
        _startNetworkFlow = [AANetworkFlow getFlowIOBytes];
    }
    if (_source_t) {
        [self stop];
    }
    dispatch_resume(self.source_t);
}

- (void)stop {
    dispatch_source_cancel(self.source_t);
    self.source_t = nil;
}

/**
 定时操作
 */
- (void)monitor {

    // CPU
    float app_cpu_usage = [AACPUUsage getAppCPUUsage];

    // RAM
    unsigned long long app_ram_usage = [AARAMUsage getAppRAMUsage];
    aa_system_ram_usage system_ram_usage = [AARAMUsage getSystemRamUsageStruct];
    
    // NetworkFlow
    aa_flow_IOBytes networkFlow = [AANetworkFlow getFlowIOBytes];
    aa_flow_IOBytes startNetworkFlow;
    startNetworkFlow.wifi_received = networkFlow.wifi_received - _startNetworkFlow.wifi_received;
    startNetworkFlow.wifi_sent = networkFlow.wifi_sent - _startNetworkFlow.wifi_sent;
    startNetworkFlow.cellular_sent = networkFlow.cellular_sent - _startNetworkFlow.cellular_sent;
    startNetworkFlow.cellular_received = networkFlow.cellular_received - _startNetworkFlow.cellular_received;
    startNetworkFlow.total_received = networkFlow.total_received - _startNetworkFlow.total_received;
    startNetworkFlow.total_sent = networkFlow.total_sent - _startNetworkFlow.total_sent;
    
    NSString *timestamp = [[AADateFormatter sharedInstance].dateFormatter stringFromDate:[NSDate date]];
    for (id<AASystemMonitorDelegate> delegate in _hashTable) {
        BOOL didUpdateCPUUsage = [delegate respondsToSelector:@selector(didUpdateAppCPUUsage:timestamp:)];
        BOOL didUpdateRamUsage = [delegate respondsToSelector:@selector(didUpdateAppRamUsage:systemRamUsage:timestamp:)];
        BOOL didUpdateNetworkFlow = [delegate respondsToSelector:@selector(didUpdateNetworkFlowSent:received:total:timestamp:)];
    
        if (didUpdateCPUUsage) {
            [delegate didUpdateAppCPUUsage:app_cpu_usage timestamp:timestamp];
        }
        
        if (didUpdateRamUsage) {
            [delegate didUpdateAppRamUsage:app_ram_usage systemRamUsage:system_ram_usage timestamp:timestamp];
        }
        
        if (didUpdateNetworkFlow) {
            if (_isFisrtGetNetworkFlow) {
                _isFisrtGetNetworkFlow = NO;
            } else {
                ///实时上下行 + total
                [delegate didUpdateNetworkFlowSent:networkFlow.total_sent-_networkFlow.total_sent
                                          received:networkFlow.total_received-_networkFlow.total_received
                                             total:startNetworkFlow timestamp:timestamp];
            }
            _networkFlow = networkFlow;
        }
    }
}

#pragma mark - Getters and Setters
/**
 委托回调对象集合
 
 @return NSHashTable
 */
- (NSHashTable *)hashTable {
    if (!_hashTable) {
        _hashTable = [NSHashTable weakObjectsHashTable];
    }
    return _hashTable;
}

- (dispatch_source_t)source_t {
    if (!_source_t) {
        uint64_t interval = self.timeInterval * NSEC_PER_SEC;
        //创建一个专门执行timer回调的GCD队列
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        //创建Timer
        _source_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        //使用dispatch_source_set_timer函数设置timer参数
        dispatch_source_set_timer(_source_t, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
        //设置回调
        dispatch_source_set_event_handler(_source_t, ^(){
            [self monitor];
        });
    }
    return _source_t;
}
@end
