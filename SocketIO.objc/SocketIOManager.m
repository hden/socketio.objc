//
//  SocketIOManager.m
//  
//
//  Created by Hao-kang Den on 6/7/14.
//
//

#import "SocketIOManager.h"
#import "SocketIOPacket.h"
#import "SocketIOParser.h"
#import "EngineIOUtil.h"

@implementation SocketIOManager



/**
 * Called upon a socket close.
 *
 * @param {Socket} socket
 */

//TODO

/**
 * Writes a packet.
 *
 * @param {Object} packet
 * @api private
 */

- (void) packet:(SocketIOPacket *)packet
{
    NSLog(@"writing packet");
    __block __weak SocketIOManager *this = self;
    
    if (!self.encoding) {
        // encode, then write to engine with result
        _encoding = true;
        [SocketIOParser encode:packet withCallback:^(NSArray *encodedPackets) {
            for (NSString *encodedPacket in encodedPackets) {
                // TODO
//                [this.engine write:encodedPacket];
            }
            _encoding = false;
            [this processPacketQueue];
        }];
    } else {
        // add packet to the queue
        [self.packetBuffer addObject:packet];
    }
}

/**
 * If packet buffer is non-empty, begins encoding the
 * next packet in line.
 *
 * @api private
 */

- (void) processPacketQueue
{
    if (self.packetBuffer.count > 0 && !self.encoding) {
        SocketIOPacket *pack = self.packetBuffer[0];
        [self.packetBuffer removeObjectsAtIndexes:0];
        [self packet:pack];
    }
}

/**
 * Clean up transport subscriptions and packet buffer.
 *
 * @api private
 */

- (void) cleanup
{
    // TODO
    _packetBuffer = @[].mutableCopy;
    _encoding     = false;
}

/**
 * Close the current socket.
 *
 * @api private
 */

- (void) close
{
    [self disconnect];
}

- (void) disconnect
{
    _skipReconnect = true;
//    [self.engine close];
}

/**
 * Called upon engine close.
 *
 * @api private
 */

- (void) onClose:(NSString *)reason
{
    NSLog(@"close");
    [self cleanup];
    _readyState = SocketIOReadyStateClosed;
    [self emit:@"close", reason];
    if (self.reconnection && !self.skipReconnect) {
        [self reconnect];
    }
}

/**
 * Attempt a reconnection.
 *
 * @api private
 */

- (void) reconnect
{
    if (self.reconnecting) {
        return;
    }
    
    __block __weak SocketIOManager *this = self;
    _attempts++;
    
    if (self.attempts > self.reconnectionAttempts) {
        NSLog(@"reconnect failed");
        [self emit:@"reconnect_failed"];
        _reconnecting = false;
    } else {
        int delay = self.attempts * self.reconnectionDelay;
        delay = MIN(delay, self.reconnectionDelayMax);
        NSLog(@"will wait %dms before reconnect attempt", delay);
        _reconnecting = true;
        
        __block NSTimer *timer = [EngineIOUtil setTimeout:^{
            NSLog(@"attempting reconnect");
            [this emit:@"reconnect_attempt"];
            // TODO self.open(...
        } withInervel:delay];
        
        [_subs addObject:@{@"destroy":^void() {
            [EngineIOUtil clearTimeout:timer];
        }}];
    }
}

/**
 * Called upon successful reconnect.
 *
 * @api private
 */

- (void) onreconnect
{
    int attempt   = self.attempts;
    _attempts     = 0;
    _reconnecting = false;
    [self emit:@"reconnect", attempt];
}

@end
