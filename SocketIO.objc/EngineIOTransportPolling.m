//
//  EngineIOTransportPolling.m
//  
//
//  Created by Hao-kang Den on 5/9/14.
//
//

#import "EngineIOTransportPolling.h"
#import "EngineIOParser.h"
#import "EngineIORequest.h"

@implementation EngineIOTransportPolling

# pragma mark -
# pragma mark https://github.com/LearnBoost/engine.io-client/blob/master/lib/transports/polling.js

/**
 * Transport name.
 */

- (NSString *) name
{
    return @"polling";
}

/**
 * Opens the socket (triggers polling). We write a PING message to determine
 * when the transport is open.
 *
 * @api private
 */

- (void) doOpen
{
    [self poll];
}

/**
 * Pauses `.
 *
 * @param {Function} callback upon buffers are flushed and transport is paused
 * @api private
 */

- (void) pause:(void (^)())onPause
{
    readyState = EngineIOTransportReadyStatePausing;
    
    void (^pause)() = ^void() {
        NSLog(@"paused");
        readyState = EngineIOTransportReadyStatePaused;
        if (onPause) {
            onPause();
        }
    };
    
    if (polling || self.writable) {
        __block int total = 0;
        
        if (polling) {
            NSLog(@"we are cuurently polling - waiting to pause");
            total++;
            [self once:@"pollComplete" listener:^{
                NSLog(@"pre-pause polling complete");
                --total ? : pause();
            }];
        }
        
        if (self.writable) {
            NSLog(@"we are currently writing - waiting to pause");
            total++;
            [self once:@"drain" listener:^{
                NSLog(@"pre-pause writing complete");
                --total ? : pause();
            }];
        }
    } else {
        pause();
    }
}

/**
 * Starts polling cycle.
 *
 * @api public
 */

- (void) poll
{
    NSLog(@"polling");
    polling = true;
    [self doPoll];
    [self emit:@"poll"];
}

/**
 * Overloads onData to detect payloads.
 *
 * @api private
 */

- (void) onData:(NSData *)data
{
    NSLog(@"polling got data %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    void (^callback)(EngineIOPacket *) = ^void(EngineIOPacket *packet) {
        // if its the first message we consider the transport open
        if (readyState == EngineIOTransportReadyStateOpening) {
            [this onOpen];
        }
        
        // if its a close packet, we close the ongoing requests
        if (packet.type == EngineIOPacketTypeClose) {
            return [this onClose];
        }

        // otherwise bypass onData and handle the message
        [this onPacket:packet];
    };
    
    // decode payload
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *list = [EngineIOParser decodePayload:str];
    for (EngineIOPacket *p in list) {
        callback(p);
    }
    
    // if an event did not trigger closing
    if (readyState != EngineIOTransportReadyStateClosed) {
        // if we got data we're not polling
        polling = false;
        [self emit:@"pollComplete"];
        
        if (readyState == EngineIOTransportReadyStateOpen) {
            [self poll];
        } else {
            NSLog(@"ignoring poll - transport state %d", readyState);
        }
    }
}

/**
 * For polling, send a close packet.
 *
 * @api private
 */

- (void) doClose
{
    void (^close)() = ^void() {
        NSLog(@"writing close packet");
        EngineIOPacket *p = [[EngineIOPacket alloc] init];
        p.type = EngineIOPacketTypeClose;
        [this write:@[p]];
    };
    
    if (readyState == EngineIOTransportReadyStateOpen) {
        NSLog(@"transport open - closing");
        close();
    } else {
        // in case we're trying to close while
        // handshaking is in progress (GH-164)
        NSLog(@"transport not open - deferring close");
        [self once:@"open" listener:close];
    }
}

/**
 * Writes a packets payload.
 *
 * @param {Array} data packets
 * @param {Function} drain callback
 * @api private
 */

- (void) write:(NSArray *)packets
{
    self.writable = false;
    
    void (^callbackfn)() = ^void() {
        this.writable = false;
        [this emit:@"drain"];
    };
    
    NSString *data = [EngineIOParser encodePayload:packets];
    [self doWrite:data withCallback:callbackfn];
}

/**
 * Generates uri for connection.
 *
 * @api private
 */

- (NSURL *) uri
{
    return _options.URL;
}

# pragma mark -
# pragma mark https://github.com/LearnBoost/engine.io-client/blob/master/lib/transports/polling-xhr.js

- (EngineIORequest *) requestWithOptions:(EngineIOTransportOptions *)options
{
    if (options == nil) {
        options = _options.copy;
    }
    return [[EngineIORequest alloc] initWithOptions:options];
}

/**
 * Sends data.
 *
 * @param {String} data to send.
 * @param {Function} called upon flush.
 * @api private
 */

- (void) doWrite:(id)data withCallback:(void (^)())fn
{
    NSData *d;
    EngineIOTransportOptions *opt = _options.copy;
    
    if ([data isKindOfClass:[NSString class]]) {
        d = [data dataUsingEncoding:NSUTF8StringEncoding];
        opt.isBinary = false;
    }
    
    if ([data isKindOfClass:[NSData class]]) {
        d = data;
    }

    opt.method = @"POST";
    opt.data   = d;
    
    EngineIORequest *req = [self requestWithOptions:opt];
    
    if (fn != nil) {
        [req once:@"success" listener:fn];
    }
    
    [req once:@"error" listener:^(NSError *error) {
        [this onError:error withDescription:@"xhr post error"];
    }];
}

/**
 * Starts a poll cycle.
 *
 * @api private
 */

- (void) doPoll
{
    EngineIORequest *req = [self requestWithOptions:nil];
    [req on:@"data" listener:^(NSData *data) {
        [this onData:data];
    }];
    [req on:@"error" listener:^(NSError *error) {
        [this onError:error withDescription:@"xhr poll error"];
    }];
}

@end