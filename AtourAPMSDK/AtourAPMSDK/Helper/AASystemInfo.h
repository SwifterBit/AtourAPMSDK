//
//  AADeviceInfo.h
//  AtourAPMSDK
//
//  Created by sue on 2020/12/9.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface AASystemInfo : NSObject
/**
 获取设备型号

 @return NSString
 */
+ (NSString *)getDeviceModel;

/**
 获取系统版本

 @return NSString
 */
+ (NSString *)getSystemVersion;

/**
 获取系统名称

 @return NSString
 */
+ (NSString *)getSystemName;

/**
 获取应用名称
 
 @return NSString
 */
+ (NSString *)getBundleDisplayName;

/**
 获取应用版本号
 
 @return NSString
 */
+ (NSString *)getBundleShortVersionString;

/**
 获取内部版本号
 
 @return NSString
 */
+ (NSString *)getBundleVersion;

@end

NS_ASSUME_NONNULL_END
