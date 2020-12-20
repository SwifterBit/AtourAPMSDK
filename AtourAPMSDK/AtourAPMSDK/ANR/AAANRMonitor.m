//
//  AAANRMonitor.m
//  AtourAPMSDK
//
//  Created by sue on 2020/12/14.
//

#import "AAANRMonitor.h"
#import "AACallStack.h"
#import "AADateFormatter.h"
@interface AAANRMonitor ()

/**
 卡顿委托回调对象集合
 */
@property (nonatomic, strong) NSHashTable *hashTable;

/**
 信号量
 */
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_semaphore_t eventSemaphore;

/**
 主线程观察
 */
@property (nonatomic, assign) CFRunLoopObserverRef observer;

/**
 RunLoop处于状态值
 */
@property (nonatomic, assign) CFRunLoopActivity activity;

/**
 操作队列
 */
///监听runloop状态在after waiting和before sources之间
@property (nonatomic, strong) dispatch_queue_t queue;
///监听runloop状态为before waiting状态下是否卡顿
@property (nonatomic, strong) dispatch_queue_t eventQueue;

/**
 记录日志-卡顿时间阈值，默认0.2s
 */
@property (nonatomic, assign, readwrite) NSTimeInterval timeOutInterval;

/**
 记录日志-卡顿次数阈值，默认5次
 */
@property (nonatomic, assign, readwrite) NSInteger timeOutCount;

/**
 当前记录的卡顿次数
 */
@property (nonatomic, assign) NSInteger curTimeOutCount;

@end

/**
 创建 RunLoop observer对象

 @param observer observer对象
 @param activity runloop观察状态
 @param info 信息
 */
static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    AAANRMonitor *monitor =  (__bridge AAANRMonitor*)info;
    monitor.activity = activity;
    dispatch_semaphore_signal(monitor.semaphore);
}

@implementation AAANRMonitor

#pragma mark - Life Cycle
/**
 单例对象
 
 @return AAANRMonitor
 */
+ (AAANRMonitor *)sharedInstance  {
    static AAANRMonitor *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

/**
 初始化，设置阈值
 
 @param timeOutInterval 记录日志-卡顿时间阈值
 @param timeOutCount 记录日志-卡顿次数阈值
 @return instancetype
 */
- (instancetype)initWithTimeOutInterval:(double)timeOutInterval timeOutCount:(NSInteger)timeOutCount {
    if (self = [super init]) {
        _curTimeOutCount = 0;
        _timeOutInterval = timeOutInterval;
        _timeOutCount = timeOutCount;
        _queue = dispatch_queue_create("com.atour.AAANRMonitor", DISPATCH_QUEUE_SERIAL);
        _eventQueue = dispatch_queue_create("com.atour.AAANRMonitor.event", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

/**
 初始化
 
 @return instancetype
 */
- (instancetype)init {
    return [self initWithTimeOutInterval:0.2 timeOutCount:5];
}

/**
 释放
 */
- (void)dealloc {
    [self stop];
    [self removeAllDelegates];
}

#pragma mark - Public Method
/**
 开启监控
 
 @param delegate 委托对象
 */
- (void)addDelegate:(id<AAANRMonitorDelegate>)delegate {
    [self.hashTable addObject:delegate];
}

/**
 关闭监控
 
 @param delegate 委托对象
 */
- (void)removeDelegate:(id<AAANRMonitorDelegate>)delegate {
    if ([self.hashTable containsObject:delegate]) {
        [self.hashTable removeObject:delegate];
    }
}

/**
 开启监控卡顿
 */
- (void)start {
    if (_observer) {
        return;
    }
    _semaphore = dispatch_semaphore_create(0);
    _eventSemaphore = dispatch_semaphore_create(0);
    CFRunLoopObserverContext context = {0, (__bridge void*)self, &CFRetain, &CFRelease};
    _observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallBack, &context);
    
    // 观察主线程Runloop
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_eventQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        while (YES) {
            if (strongSelf.activity == kCFRunLoopBeforeWaiting) {
                __block BOOL timeOut = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    timeOut = NO;
                    dispatch_semaphore_signal(strongSelf.eventSemaphore);
                });
                [NSThread sleepForTimeInterval:strongSelf.timeOutInterval];
                if (timeOut) {
                    [strongSelf handleANRTimeOut];
                }
                dispatch_wait(strongSelf.eventSemaphore, DISPATCH_TIME_FOREVER);
            }
        }
    });
    
    dispatch_async(_queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        while (YES) {
            long waitTime = dispatch_semaphore_wait(strongSelf.semaphore, dispatch_time(DISPATCH_TIME_NOW, strongSelf.timeOutInterval*1000*NSEC_PER_MSEC));
            if (waitTime != 0) {
                if (!strongSelf.observer) {
                    strongSelf.curTimeOutCount = 0;
                    strongSelf.activity = 0;
                    strongSelf.semaphore = nil;
                    strongSelf.eventSemaphore = nil;
                    return ;
                }
                // 超时
                if (strongSelf.activity == kCFRunLoopBeforeSources || strongSelf.activity == kCFRunLoopAfterWaiting) {
                    if (++strongSelf.curTimeOutCount < strongSelf.timeOutCount) {
                        continue;
                    }
                    // 超时5*200ms
                    [strongSelf handleANRTimeOut];
                    [NSThread sleepForTimeInterval:strongSelf.timeOutInterval];
                }
            }
            strongSelf.curTimeOutCount = 0;
        }
    });
}

/**
 关闭监控卡顿
 */
- (void)stop {
    if (!_observer) {
        return;
    }
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = NULL;
    _curTimeOutCount = 0;
    _activity = 0;
}

#pragma mark - Private Method
/**
 去除所有委托对象
 */
- (void)removeAllDelegates {
    [self.hashTable removeAllObjects];
}

/**
 记录卡顿
 */
- (void)handleANRTimeOut {
    if (!_hashTable) {
        return;
    }
    NSString *content = [AACallStack aa_backtraceOfAllThread];
    NSString *timestamp = [[AADateFormatter sharedInstance].dateFormatter stringFromDate:[NSDate date]];
    for (id<AAANRMonitorDelegate> delegate in _hashTable) {
        if ([delegate respondsToSelector:@selector(didRecievedANRInfo:timestamp:)]) {
            [delegate didRecievedANRInfo:content timestamp:timestamp];
        }
    }
}

#pragma mark - Getters and Setters
/**
 卡顿委托回调对象集合

 @return NSHashTable
 */
- (NSHashTable *)hashTable {
    if (!_hashTable) {
        _hashTable = [NSHashTable weakObjectsHashTable];
    }
    return _hashTable;
}

@end
