//
//  AANetworkFlow.h
//  AtourAPMSDK
//
//  Created by sue on 2020/12/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    unsigned int wifi_sent;
    unsigned int wifi_received;
    unsigned int cellular_sent;
    unsigned int cellular_received;
    unsigned int total_sent;
    unsigned int total_received;
} aa_flow_IOBytes;

@interface AANetworkFlow : NSObject
/**
 获取系统网络流量

 @return aa_flow_IOBytes
 */
+ (aa_flow_IOBytes)getFlowIOBytes;

/**
 获取 wifi iP 地址

 @return NSString
 */
+ (NSString *)getWifiIPAddress;

/**
 获取 SIM 卡 iP 地址

 @return NSString
 */
+ (NSString *)getCellularIPAddress;

/**
 iP 字典集合（包含iP4 iP6）

 @return NSDictionary
 */
+ (NSDictionary *)getIPAddresses;

/**
 获取设备当前网络IP地址

 @param isIPv4 iP 输出格式
 @return NSString
 */
+ (NSString *)getIPAddress:(BOOL)isIPv4;

@end

NS_ASSUME_NONNULL_END
