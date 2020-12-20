//
//  AACallStack.h
//  RunloopDemo
//
//  Created by sue on 2020/9/28.
//  Copyright © 2020 atour. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 堆栈类
@interface AACallStack : NSObject
+ (NSString *)aa_backtraceOfAllThread;
+ (NSString *)aa_backtraceOfCurrentThread;
+ (NSString *)aa_backtraceOfMainThread;
+ (NSString *)aa_backtraceOfNSThread:(NSThread *)thread;
@end

NS_ASSUME_NONNULL_END
