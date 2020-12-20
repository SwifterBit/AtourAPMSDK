//
//  AACPUUsage.h
//  AtourAPMSDK
//
//  Created by sue on 2020/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AACPUUsage : NSObject
/**
 APP CPU 使用率

 @return float 获取失败返回 0
 */
+ (float)getAppCPUUsage;
@end

NS_ASSUME_NONNULL_END
