//
//  AARAMUsage.h
//  AtourAPMSDK
//
//  Created by sue on 2020/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 内存使用情况
 */
typedef struct {
    unsigned long long used_size;
    unsigned long long available_size;
    unsigned long long total_size;
}aa_system_ram_usage;

@interface AARAMUsage : NSObject

/**
 获取APP内存使用量
 通过phys_footprint 更加准确，视为实际使用内存 区别于resident_size
 参考https://github.com/apple/darwin-xnu 中osfmk/kern/task.c 对phys_footprint的注释
 @return byte
 */
+ (unsigned long long)getAppRAMUsage;

/**
 获取当前系统内存情况

 @return aa_system_ram_usage
 */
+ (aa_system_ram_usage)getSystemRamUsageStruct;

@end

NS_ASSUME_NONNULL_END
