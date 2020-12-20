//
//  AACPUUsage.m
//  AtourAPMSDK
//
//  Created by sue on 2020/12/9.
//

#import "AACPUUsage.h"
#import <mach/task.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>
#import <mach/thread_act.h>

@implementation AACPUUsage
/**
 APP CPU 使用率

 @return float 获取失败返回 0
 */
+ (float)getAppCPUUsage {
    kern_return_t           kr;
    thread_array_t          threadList;         // 保存当前mach task的线程列表
    mach_msg_type_number_t  threadCount;        // 保存当前mach task的线程个数
    thread_info_data_t      threadInfo;         // 保存单个线程的信息列表
    mach_msg_type_number_t  threadInfoCount;    // 保存当前线程的信息列表大小
    thread_basic_info_t     threadBasicInfo;    // 线程的基本信息
    
    // 通过task_threads API调用获取指定task的线程列表
    // mach_task_self 表示获取当前的 mach task
    kr = task_threads(mach_task_self(), &threadList, &threadCount);
    if (kr != KERN_SUCCESS) {
        return 0;
    }
    float cpuUsage = 0;
    for (int i = 0; i < threadCount; i++) {
        threadInfoCount = THREAD_INFO_MAX;
        // 通过thread_info API调用来查询指定线程的信息
        // flavor参数传的是THREAD_BASIC_INFO，使用这个类型会返回线程的基本信息，
        // 定义在 thread_basic_info_t 结构体，包含了用户和系统的运行时间、运行状态和调度优先级等
        kr = thread_info(threadList[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount);
        if (kr != KERN_SUCCESS) {
            return 0;
        }

        threadBasicInfo = (thread_basic_info_t)threadInfo;
        if (!(threadBasicInfo->flags & TH_FLAGS_IDLE)) {
            cpuUsage += threadBasicInfo->cpu_usage;
        }
    }
    
    // 回收内存
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)threadList, threadCount * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    return cpuUsage / (float)TH_USAGE_SCALE * 100.0;
}
@end
