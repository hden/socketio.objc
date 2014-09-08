//
//  EngineIOUtil.m
//  
//
//  Created by Hao-kang Den on 6/7/14.
//
//

#import "EngineIOUtil.h"
#import <BlocksKit/A2BlockInvocation.h>

@implementation EngineIOUtil

/**
 * timer polyfill
 */

+ (NSTimer *) setTimeout:(void (^)())fn withInervel:(NSTimeInterval)interval
{
    A2BlockInvocation *blockInvocation = [[A2BlockInvocation alloc] initWithBlock:fn];
    NSMethodSignature *signature       = blockInvocation.methodSignature;
    NSInvocation *invocation           = [NSInvocation invocationWithMethodSignature:signature];
    
    return [NSTimer scheduledTimerWithTimeInterval:interval invocation:invocation repeats:true];
}

+ (void) clearTimeout:(NSTimer *)timer
{
    [timer invalidate];
}

@end
