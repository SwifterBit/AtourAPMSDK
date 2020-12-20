//
//  AADeviceInfo.m
//  AtourAPMSDK
//
//  Created by sue on 2020/12/9.
//

#import "AASystemInfo.h"
#import "sys/utsname.h"

@implementation AASystemInfo
/**
 获取设备型号
 
 @return NSString
 */
+ (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceModel;
}

/**
 获取系统版本
 
 @return NSString
 */
+ (NSString *)getSystemVersion {
    return [UIDevice currentDevice].systemVersion;
}

/**
 获取系统名称
 
 @return NSString
 */
+ (NSString *)getSystemName {
    return [UIDevice currentDevice].systemName;
}

/**
 获取应用名称
 
 @return NSString
 */
+ (NSString *)getBundleDisplayName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

/**
 获取应用版本号
 
 @return NSString
 */
+ (NSString *)getBundleShortVersionString {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

/**
 获取内部版本号
 
 @return NSString
 */
+ (NSString *)getBundleVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}
@end
