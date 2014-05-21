//
//  EngineIOTransport.m
//  
//
//  Created by Hao-kang Den on 5/8/14.
//
//

#import "EngineIOTransport.h"
#import "EngineIOParser.h"

@implementation EngineIOTransport

- (id) initWithOptions:(EngineIOTransportOptions *)options
{
    self = [super init];
    if (self) {
        _options = options;
        this     = self;
    }
    return self;
}

/**
 * Emits an error.
 *
 * @param {String} str
 * @return {Transport} for chaining
 * @api public
 */

- (void) onError:(NSError *)error withDescription:(NSString *)description;
{
    NSError *err = [NSError errorWithDomain:@"EngineIOTransport" code:1 userInfo:@{@"type": @"TransportError", @"description": description}];
    [self emit:@"error", err];
}


/**
 * Opens the transport.
 *
 * @api public
 */

- (void) open
{
    if (readyState == EngineIOTransportReadyStateClosed) {
        readyState = EngineIOTransportReadyStateOpening;
        [self doOpen];
    }
}

/**
 * Closes the transport.
 *
 * @api private
 */

- (void) close
{
    if (readyState == EngineIOTransportReadyStateOpening || readyState == EngineIOTransportReadyStateOpen) {
        [self doClose];
        [self onClose];
    }
}

/**
 * Sends multiple packets.
 *
 * @param {Array} packets
 * @api private
 */

- (void) send:(NSArray *)packets;
{
    if (readyState == EngineIOTransportReadyStateOpen) {
        [self write:packets];
    } else {
        @throw @"Transport not open";
    }
}

/**
 * Called upon open
 *
 * @api private
 */

- (void) onOpen
{
    readyState = EngineIOTransportReadyStateOpen;
    self.writable = true;
    [self emit:@"open"];
}

/**
 * Called with data.
 *
 * @param {String} data
 * @api private
 */

- (void) onData:(NSString *)data;
{
    [self onPacket:[EngineIOParser decodePacket:data]];
}

/**
 * Called with a decoded packet.
 */

- (void) onPacket:(EngineIOPacket *)packet;
{
    [self emit:@"packet", packet];
}

/**
 * Called upon close.
 *
 * @api private
 */

- (void) onClose;
{
    readyState = EngineIOTransportReadyStateClosed;
    [self emit:@"close"];
}

- (void) dealloc
{
    [self removeAllListeners];
}

@end
