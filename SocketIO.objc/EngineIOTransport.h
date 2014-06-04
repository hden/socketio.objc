//
//  EngineIOTransport.h
//  
//
//  Created by Hao-kang Den on 5/8/14.
//
//

#import <Foundation/Foundation.h>
#import "Emitter+Blocks.h"
#import "EngineIOPacket.h"
#import "EngineIOTransportOptions.h"

typedef enum {
    EngineIOTransportTypeXHRPolling  = 0
    , EngineIOTransportTypeWebsocket = 1
} EngineIOTransportType;

typedef enum {
    EngineIOTransportReadyStateClosed    = 0
    , EngineIOTransportReadyStateClosing = 1
    , EngineIOTransportReadyStateOpen    = 2
    , EngineIOTransportReadyStateOpening = 3
    , EngineIOTransportReadyStatePaused  = 4
    , EngineIOTransportReadyStatePausing = 5
} EngineIOTransportReadyState;

@interface EngineIOTransport : NSObject
{
    __block EngineIOTransportReadyState readyState;
    __block __weak EngineIOTransport *this;
}

@property (nonatomic) BOOL writable;
@property (nonatomic) EngineIOTransportOptions *options;

- (id) initWithOptions:(EngineIOTransportOptions *)options;
- (NSString *)name;
- (void) onError:(NSError *)error withDescription:(NSString *)description;
- (void) open;
- (void) close;
- (void) send:(NSArray *)packets;
- (void) write:(NSArray *)packets;
- (void) onOpen;
- (void) onData:(NSData *)data;
- (void) onPacket:(EngineIOPacket *)packet;
- (void) onClose;
- (void) doOpen;
- (void) doClose;
- (void) pause:(void (^)())onPause;

@end
