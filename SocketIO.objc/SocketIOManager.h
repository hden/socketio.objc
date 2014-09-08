//
//  SocketIOManager.h
//  
//
//  Created by Hao-kang Den on 6/7/14.
//
//

#import <Foundation/Foundation.h>
#import "Emitter+Blocks.h"

typedef enum {
    SocketIOReadyStateClosed    = 0
    , SocketIOReadyStateClosing = 1
    , SocketIOReadyStateOpen    = 2
    , SocketIOReadyStateOpening = 3
    , SocketIOReadyStatePaused  = 4
    , SocketIOReadyStatePausing = 5
} SocketIOReadyState;

@interface SocketIOManager : NSObject

@property (nonatomic, readonly) NSMutableDictionary *nsp;
@property (nonatomic, readonly) NSMutableArray *subs;
@property (nonatomic) BOOL reconnection;
@property (nonatomic) int reconnectionAttempts;
@property (nonatomic) NSTimeInterval reconnectionDelay;
@property (nonatomic) NSTimeInterval reconnectionDelayMax;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, readonly) SocketIOReadyState readyState;

@property (nonatomic, readonly) int connected;
@property (nonatomic, readonly) int attempts;
@property (nonatomic) __block BOOL encoding;
@property (nonatomic, readonly) NSMutableArray *packetBuffer;
@property (nonatomic, readonly) BOOL reconnecting;
@property (nonatomic, readonly) BOOL skipReconnect;
@end
