//
//  AARAMUsage.m
//  AtourAPMSDK
//
//  Created by sue on 2020/12/9.
//

#import "AARAMUsage.h"
#import <mach/mach.h>
#import <mach/task_info.h>
@implementation AARAMUsage

/**
 获取APP内存使用量
 通过phys_footprint 更加准确，视为实际使用内存 区别于resident_size
 参考https://github.com/apple/darwin-xnu 中osfmk/kern/task.c 对phys_footprint的注释
 @return byte
 */
+ (unsigned long long)getAppRAMUsage {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kr = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kr != KERN_SUCCESS) {
        return 0;
    }
    return vmInfo.phys_footprint;
}

/**
 获取当前系统内存情况

 @return aa_system_ram_usage
 */
+ (aa_system_ram_usage)getSystemRamUsageStruct {
    vm_statistics64_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kr = host_statistics(mach_host_self(),
                                       HOST_VM_INFO,
                                       (host_info_t)&vmStats,
                                       &infoCount);
    
    aa_system_ram_usage system_memory_usage = {0, 0, 0};
    if (kr != KERN_SUCCESS) {
        return system_memory_usage;
    }
    system_memory_usage.used_size = (vmStats.active_count + vmStats.wire_count + vmStats.inactive_count) * vm_kernel_page_size;
    system_memory_usage.available_size = (vmStats.free_count) * vm_kernel_page_size;
    system_memory_usage.total_size = [NSProcessInfo processInfo].physicalMemory;
    return system_memory_usage;
}
@end
