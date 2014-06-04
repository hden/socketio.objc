//
//  EngineIOClient.h
//  
//
//  Created by Hao-kang Den on 5/7/14.
//
//

#import <Foundation/Foundation.h>
#import "EngineIOTransport.h"

@interface EngineIOClient : NSObject
{
    __block EngineIOTransportReadyState readyState;
    EngineIOTransportOptions *_options;
    NSArray *_upgrades;
    NSMutableArray *writeBuffer;
    NSMutableArray *callbackBuffer;
    int prevBufferLen;
    NSNumber *pingInterval;
    NSNumber *pingTimeout;
    NSTimer *pingIntervalTimer;
    NSTimer *pingTimeoutTimer;
    __block BOOL upgrading;
}

@property (nonatomic) EngineIOTransport *transport;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readonly) BOOL disconnected;

+ (int) protocol;
- (id) initWith:(EngineIOTransportOptions *)options;
- (void) send:(NSString *)msg callback:(void (^)())fn;
- (void) close;
- (NSTimer *) setTimeout:(void (^)())fn withInervel:(NSTimeInterval)interval;

@end
