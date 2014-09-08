//
//  SocketIOSocket.m
//  
//
//  Created by Hao-kang Den on 6/7/14.
//
//

#import "SocketIOSocket.h"
#import <BlocksKit/A2BlockInvocation.h>

@implementation SocketIOSocket

- (id) initWith:(NSString *)nsp
{
    self = [super init];
    if (self) {
        _nsp          = nsp;
        _ids          = 0;
        _acks         = @{}.mutableCopy;
        _buffer       = @[].mutableCopy;
        _connected    = false;
        _disconnected = true;
    }
    return self;
}

/**
 * Produces an ack callback to emit with an event.
 *
 * @api private
 */

- (void (^)()) ack:(id)ackid
{
    __block __weak SocketIOSocket *this = self;
    __block BOOL sent = false;
    return ^void() {
        if (sent) {
            return;
        }
        
        sent = true;
    };
}

/**
 * Called upon a server acknowlegement.
 *
 * @param {Object} packet
 * @api private
 */

- (void) onack:(SocketIOPacket *)packet
{
    NSLog(@"calling ack %@ with %@", packet.id, packet.data);
    A2BlockInvocation *blockInvocation = [[A2BlockInvocation alloc] initWithBlock:self.acks[packet.id]];
    NSMethodSignature *signature       = blockInvocation.methodSignature;
    NSInvocation *invocation           = [NSInvocation invocationWithMethodSignature:signature];
    
    // equivalent to JavaScript: `fn.apply(this, packet.data)`
    NSArray *args = packet.data;
    for (int i=0; i < MIN(signature.numberOfArguments-2, args.count); i++) {
        id arg = args[i];
        [invocation setArgument:&arg atIndex:i+2];
    }
    [blockInvocation invokeWithInvocation:invocation];
    [self.acks removeObjectForKey:packet.id];
}

/**
 * Called upon server connect.
 *
 * @api private
 */

- (void) onconnect
{
    self.connected    = true;
    self.disconnected = false;
    [self emit:@"connect"];
    [self emitBuffered];
}

/**
 * Emit buffered events.
 *
 * @api private
 */

- (void) emitBuffered
{
    self.buffer = @[].mutableCopy;
}

/**
 * Disconnects the socket manually.
 *
 * @return {Socket} self
 * @api public
 */
- (void) close
{
    [self disconnect];
}

- (void) disconnect
{
    if (!self.connected) {
        return;
    }
    
    NSLog(@"performing disconnect (%@)", self.nsp);
    
}

@end
