//
//  EngineIOClient.m
//  
//
//  Created by Hao-kang Den on 5/7/14.
//
//

#import <BlocksKit/A2BlockInvocation.h>

#import "EngineIOClient.h"
#import "EngineIOParser.h"
#import "EngineIOTransportPolling.h"

# pragma mark -
# pragma mark EngineIOClient private interface

@interface EngineIOClient (Private)

@end

# pragma mark -
# pragma mark EngineIOClient implementation

@implementation EngineIOClient

+ (int) protocol
{
    return [EngineIOParser protocal];
}

- (id) initWith:(EngineIOTransportOptions *)options
{
    self = [super init];
    if (self) {
        _options       = options != nil ? options : [[EngineIOTransportOptions alloc] init];
        readyState     = EngineIOTransportReadyStateClosed;
        writeBuffer    = @[].mutableCopy;
        callbackBuffer = @[].mutableCopy;
        prevBufferLen  = 0;
        upgrading      = false;
        [self open];
    }
    return self;
}

/**
 * Creates transport of the given type.
 *
 * @param {String} transport name
 * @return {Transport}
 * @api private
 */

- (EngineIOTransport *) createTransport:(EngineIOTransportType)type
{
    NSLog(@"creating transport %d", type);
    EngineIOTransportOptions *opt = _options.copy;
    EngineIOTransport *transport;
    
    // append engine.io protocol identifier
    NSString *protocol = [NSString stringWithFormat:@"%d", [[self class] protocol]];
    [opt querySetValue:protocol forKey:@"EIO"];
    
    switch (type) {
        case EngineIOTransportTypeWebsocket:
//            transport = [[EngineIOTransport alloc] initWith:opt];
            break;
            
        default:
            transport = [[EngineIOTransportPolling alloc] initWithOptions:_options.copy];
            break;
    }
    
    return transport;
}

/**
 * Initializes transport to use and starts probe.
 *
 * @api private
 */

- (void) open
{
    readyState = EngineIOTransportReadyStateOpening;
    EngineIOTransport *transport = [self createTransport:EngineIOTransportTypeXHRPolling];
    [transport open];
    self.transport = transport;
}

/**
 * Sets the current transport. Disables the existing one (if any).
 *
 * @api private
 */
- (void) setTransport:(EngineIOTransport *)transport
{
    __block __weak EngineIOClient *this = self;
    NSLog(@"setting transport %@", transport.name);
    if (self.transport != nil) {
        [self.transport removeAllListeners];
    }
    
    // set up transport
    _transport = transport;
    
    // set up transport listeners
    [transport on:@"drain" listener:^{
        [self onDrain];
    }];
    
    [transport on:@"packet" listener:^(EngineIOPacket *packet) {
        [self onPacket:packet];
    }];
    
    [transport on:@"error" listener:^(NSError *error) {
        [self onError:error];
    }];
    
    [transport on:@"close" listener:^{
        [self onClose:@"transport close" description:nil];
    }];
}

/**
 * Probes a transport.
 *
 * @param {String} transport name
 * @api private
 */

//- (void) probe:(EngineIOPacketTypes)type
//{
//    NSLog(@"probing transport %d", type);
//    __block EngineIOTransport *t = [self createTransport:type];
//    BOOL failed = false;
//    
//    void (^onTransportOpen)() = ^{
//        if (failed) {
//            return;
//        }
//        
//        NSLog(@"probe transport %d opened", type);
//        EngineIOPacket *p = [[EngineIOPacket alloc] init];
//        p.type = EngineIOPacketTypePing;
//        p.data = @"probe";
//        [t send:@[p]];
//        [t once:@"packet" listener:^(EngineIOPacket *msg){
//            if (failed) {
//                return;
//            }
//            
//            if (msg.type == EngineIOPacketTypePong && [msg.data isEqualToString:@"probe"]) {
//                NSLog(@"probe transport %d pong", type);
//                upgrading = true;
//                [this emit:@"upgrading", t];
//                NSLog(@"pausing current transport %@", _transport.name);
//                [_transport pause:^{
//                    if (failed) {
//                        return;
//                    }
//                    
//                    if (readyState == EngineIOTransportReadyStateClosed || readyState == EngineIOTransportReadyStateClosing) {
//                        return;
//                    }
//                    
//                    NSLog(@"changing transport and sending upgrade packet");
//                    
//                    [this setTransport:t];
//                    EngineIOPacket *p = [[EngineIOPacket alloc] init];
//                    p.type = EngineIOPacketTypeUpgrade;
//                    [t send:@[p]];
//                    [this emit:@"upgrade", t];
//                    t = nil;
//                    upgrading = false;
//                    [this flush];
//                }];
//            } else {
//                NSLog(@"probe transport %d", type);
//                NSError *error = [[NSError alloc] initWithDomain:@"EngineIOClient" code:0 userInfo:@{@"message": @"probe error"}];
//                [this emit:@"error", error];
//            }
//        }];
//    };
//}

/**
 * Called when connection is deemed open.
 *
 * @api public
 */

- (void) onOpen
{
    NSLog(@"socket open");
    readyState = EngineIOTransportReadyStateOpen;
    [self emit:@"open"];
    [self flush];
}

/**
 * Handles a packet.
 *
 * @api private
 */

- (void) onPacket:(EngineIOPacket *)packet
{
    if (readyState == EngineIOTransportReadyStateOpen || readyState == EngineIOTransportReadyStateOpening) {
        NSLog(@"socket receive: type %d , data %@", packet.type, packet.data);
        [self emit:@"packet", packet];
        // Socket is live - any packet counts
        [self emit:@"heartbeat"];
        
        switch (packet.type) {
            case EngineIOPacketTypeOpen:
                [self onHandshake:[NSJSONSerialization JSONObjectWithData:[packet.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil]];
                break;
            
            case EngineIOPacketTypePong:
                [self setPing];
                break;
                
            case EngineIOPacketTypeError:
                [self emit:@"error", [NSError errorWithDomain:@"EngineIOClient" code:packet.data.integerValue userInfo:nil]];
                break;
                
            case EngineIOPacketTypeMessage:
                [self emit:@"data", packet.data];
                [self emit:@"message", packet.data];
                break;
                
            default:
                break;
        }
    } else {
        NSLog(@"packet received with socket readyState %d", readyState);
    }
}

/**
 * Called upon handshake completion.
 *
 * @param {Object} handshake obj
 * @api private
 */

- (void) onHandshake:(NSDictionary *)data
{
    __block __weak EngineIOClient *this = self;
    [self emit:@"handshake", data];
    NSString *sid = data[@"sid"];
    [_options querySetValue:sid forKey:@"sid"];
    [self.transport.options querySetValue:sid forKey:@"sid"];
    _upgrades    = [self filterUpgrades:data[@"upgrades"]];
    pingInterval = data[@"pingInterval"];
    pingTimeout  = data[@"pingTimeout"];
    [self onOpen];
    // In case open handler closes socket
    if (readyState == EngineIOTransportReadyStateClosed) {
        return;
    }
    [self setPing];
    
    // Prolong liveness of socket on heartbeat
    [self removeAllListeners:@"heartbeat"];
    [self once:@"heartbeat" listener:^{
        [this onHeartbeat:nil];
    }];
}

/**
 * Resets ping timeout.
 *
 * @api private
 */

- (void) onHeartbeat:(NSNumber *)timeout
{
    [self clearTimeout:pingTimeoutTimer];
    __block EngineIOTransportReadyState state = readyState;
    __block __weak EngineIOClient *this = self;
    
    if (timeout == nil) {
        timeout = @(pingInterval.intValue + pingTimeout.intValue);
    }
    
    pingTimeoutTimer = [self setTimeout:^{
        if (state == EngineIOTransportReadyStateClosed) {
            return;
        }
        [this onClose:@"ping timeout" description:nil];
    } withInervel:timeout.doubleValue];
}

/**
 * timer polyfill
 */

- (NSTimer *) setTimeout:(void (^)())fn withInervel:(NSTimeInterval)interval
{
    A2BlockInvocation *blockInvocation = [[A2BlockInvocation alloc] initWithBlock:fn];
    NSMethodSignature *signature       = blockInvocation.methodSignature;
    NSInvocation *invocation           = [NSInvocation invocationWithMethodSignature:signature];
    
    return [NSTimer scheduledTimerWithTimeInterval:interval invocation:invocation repeats:true];
}

- (void) clearTimeout:(NSTimer *)timer
{
    [timer invalidate];
}

/**
 * Pings server every `this.pingInterval` and expects response
 * within `this.pingTimeout` or closes connection.
 *
 * @api private
 */

- (void) setPing
{
    __block __weak NSNumber *interval   = pingInterval;
    __block __weak EngineIOClient *this = self;
    
    [self clearTimeout:pingIntervalTimer];
    pingIntervalTimer = [self setTimeout:^{
        NSLog(@"writing ping packet - expecting pong within %@ms", interval);
        [this ping];
        [this onHeartbeat:interval];
    } withInervel:pingInterval.doubleValue];
}

/**
 * Sends a ping packet.
 *
 * @api public
 */

- (void) ping
{
    [self sendPacket:EngineIOPacketTypePing data:nil callback:nil];
}

/**
 * Called on `drain` event
 *
 * @api private
 */

- (void) onDrain
{
    for (int i = 0; i < prevBufferLen; i++) {
        if (callbackBuffer[i] != nil) {
            A2BlockInvocation *blockInvocation = [[A2BlockInvocation alloc] initWithBlock:callbackBuffer[i]];
            NSMethodSignature *signature       = blockInvocation.methodSignature;
            NSInvocation *invocation           = [NSInvocation invocationWithMethodSignature:signature];
            [invocation invoke];
        }
    }
    
    NSRange range  = NSMakeRange(0, prevBufferLen);
    writeBuffer    = [writeBuffer subarrayWithRange:range].mutableCopy;
    callbackBuffer = [callbackBuffer subarrayWithRange:range].mutableCopy;
    
    // setting prevBufferLen = 0 is very important
    // for example, when upgrading, upgrade packet is sent over,
    // and a nonzero prevBufferLen could cause problems on `drain`
    prevBufferLen = 0;
    
    if (writeBuffer.count == 0) {
        [self emit:@"drain"];
    } else {
        [self flush];
    }
}

/**
 * Flush write buffers.
 *
 * @api private
 */

- (void) flush
{
    if (readyState != EngineIOTransportReadyStateClosed && self.transport.writable && !upgrading && writeBuffer.count > 0) {
        NSLog(@"flushing %lu packets in socket", (unsigned long)writeBuffer.count);
        [self.transport send:writeBuffer];
        // keep track of current length of writeBuffer
        // splice writeBuffer and callbackBuffer on `drain`
        prevBufferLen = (int)writeBuffer.count;
        [self emit:@"flush"];
    }
}

/**
 * Sends a message.
 *
 * @param {String} message.
 * @param {Function} callback function.
 * @return {Socket} for chaining.
 * @api public
 */

- (void) write:(NSString *)msg callback:(void (^)())fn
{
    [self send:msg callback:fn];
}

- (void) send:(NSString *)msg callback:(void (^)())fn
{
    [self sendPacket:EngineIOPacketTypeMessage data:msg callback:fn];
}

/**
 * Sends a packet.
 *
 * @param {String} packet type.
 * @param {String} data.
 * @param {Function} callback function.
 * @api private
 */

- (void) sendPacket:(EngineIOPacketTypes)type data:(NSString *)data callback:(void (^)())fn
{
    EngineIOPacket *packet = [[EngineIOPacket alloc] init];
    packet.type = type;
    packet.data = data;
    [self emit:@"packetCreate", packet];
    [writeBuffer addObject:packet];
    if (fn == nil) {
        fn = ^void() {};
    }
    [callbackBuffer addObject:fn];
    [self flush];
}

/**
 * Closes the connection.
 *
 * @api private
 */

- (void) close
{
    if (readyState == EngineIOTransportReadyStateOpening || readyState == EngineIOTransportReadyStateOpen) {
        [self onClose:@"forced close" description:nil];
        NSLog(@"socket closing - telling transport to close");
        [self.transport close];
    }
}

/**
 * Called upon transport error
 *
 * @api private
 */

- (void) onError:(NSError *)error
{
    NSLog(@"socket error %@", error.userInfo);
    [self emit:@"error", error];
    [self onClose:@"transport error" description:error];
}

/**
 * Called upon transport close.
 *
 * @api private
 */

- (void) onClose:(NSString *)reason description:(id)desc
{
    if (readyState == EngineIOTransportReadyStateOpen || readyState == EngineIOTransportReadyStateOpening) {
        NSLog(@"socket close with reason: %@", desc);
        
        // clear timers
        [self clearTimeout:pingIntervalTimer];
        [self clearTimeout:pingTimeoutTimer];
        writeBuffer    = @[].mutableCopy;
        callbackBuffer = @[].mutableCopy;
        
        // stop event from firing again for transport
        [self.transport removeAllListeners:@"close"];
        
        // ensure transport won't stay open
        [self.transport close];
        
        // ignore further transport communication
        [self.transport removeAllListeners];
        
        // set ready state
        readyState = EngineIOTransportReadyStateClosed;
        
        // clear session id
        [_options queryRemoveValueForKey:@"sid"];
        
        // emit close event
        [self emit:@"close", reason, desc];
    }
}

/**
 * Filters upgrades, returning only those matching client transports.
 *
 * @param {Array} server upgrades
 * @api private
 *
 */

- (NSArray *) filterUpgrades:(NSArray *)upgrades
{
//    return [upgrades indexOfObject:@"websocket"] == NSNotFound ? @[] : @[@"websocket"];
    // sorry, websocket will be supported ASAP
    return @[];
}

@end
