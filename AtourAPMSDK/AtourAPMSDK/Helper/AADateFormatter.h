//
//  AADateFormatter.h
//  AtourAPMSDK
//
//  Created by sue on 2020/12/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AADateFormatter : NSObject

/**
 DateFormatter
 */
@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;
/**
 单例对象
 
 @return AASystemMonitor
 */
+ (AADateFormatter *)sharedInstance;

@end

NS_ASSUME_NONNULL_END
