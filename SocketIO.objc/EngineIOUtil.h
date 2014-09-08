//
//  EngineIOUtil.h
//  
//
//  Created by Hao-kang Den on 6/7/14.
//
//

#import <Foundation/Foundation.h>

@interface EngineIOUtil : NSObject

+ (NSTimer *) setTimeout:(void (^)())fn withInervel:(NSTimeInterval)interval;
+ (void) clearTimeout:(NSTimer *)timer;

@end
