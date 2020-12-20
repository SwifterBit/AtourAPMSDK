//
//  AADateFormatter.m
//  AtourAPMSDK
//
//  Created by sue on 2020/12/16.
//

#import "AADateFormatter.h"

@implementation AADateFormatter {
    NSDateFormatter *_dateFormatter;
}
/**
 单例对象
 
 @return AADateFormatter
 */
+ (AADateFormatter *)sharedInstance  {
    static AADateFormatter *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}
@end
