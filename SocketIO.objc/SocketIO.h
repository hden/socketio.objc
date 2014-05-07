//
//  SocketIO.h
//
//  based on
//  socket.IO-objc https://github.com/pkyeck/socket.IO-objc
//  by Philipp Kyeck http://beta-interactive.de
//
//  using
//  https://github.com/square/SocketRocket
//
//  Created by Hao-kang Den on 5/4/14.
//

#import <Foundation/Foundation.h>
#import "SocketIOTransport.h"

@class SocketIO;
@class SocketIOPacket;

typedef void(^SocketIOCallback)(id args);

extern NSString* const SocketIOError;

typedef enum {
    SocketIOServerRespondedWithInvalidConnectionData = -1,
    SocketIOServerRespondedWithDisconnect = -2,
    SocketIOHeartbeatTimeout = -3,
    SocketIOWebSocketClosed = -4,
    SocketIOTransportsNotSupported = -5,
    SocketIOHandshakeFailed = -6,
    SocketIODataCouldNotBeSend = -7,
    SocketIOUnauthorized = -8
} SocketIOErrorCodes;


@protocol SocketIODelegate <NSObject>
@optional
- (void) socketIODidConnect:(SocketIO *)socket;
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error;
- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet;
- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet;
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet;
- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet;
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error;
@end


@interface SocketIO : NSObject <NSURLConnectionDelegate, SocketIOTransportDelegate>
{
    NSString *_host;
    NSInteger _port;
    NSString *_sid;
    NSString *_endpoint;
    NSDictionary *_params;
    
    __weak id<SocketIODelegate> _delegate;
    
    NSObject <SocketIOTransport> *_transport;
    
    BOOL _isConnected;
    BOOL _isConnecting;
    BOOL _useSecure;
    
    NSArray *_cookies;
    
    NSURLConnection *_handshake;
    
    // heartbeat
    NSTimeInterval _heartbeatTimeout;
    dispatch_source_t _timeout;
    
    NSMutableArray *_queue;
    
    // acknowledge
    NSMutableDictionary *_acks;
    NSInteger _ackCount;
    
    // http request
    NSMutableData *_httpRequestData;
    
    // get all arguments from ack? (https://github.com/pkyeck/socket.IO-objc/pull/85)
    BOOL _returnAllDataFromAck;
}

@property (nonatomic, readonly) NSString *host;
@property (nonatomic, readonly) NSInteger port;
@property (nonatomic, readonly) NSString *sid;
@property (nonatomic, readonly) NSTimeInterval heartbeatTimeout;
@property (nonatomic) BOOL useSecure;
@property (nonatomic) NSArray *cookies;
@property (nonatomic, readonly) BOOL isConnected, isConnecting;
@property (nonatomic, weak) id<SocketIODelegate> delegate;
@property (nonatomic) BOOL returnAllDataFromAck;

- (id) initWithDelegate:(id<SocketIODelegate>)delegate;
- (void) connectToURL:(NSURL *)url withParams:(NSDictionary *)params;

- (void) disconnect;
- (void) disconnectForced;

- (void) emit:(NSString *)topic withArgs:(id)args andCallback:(SocketIOCallback)cb;
//- (void) emit:(NSString *)topic withArgs:(id)args, ...;
- (void) sendAcknowledgement:(NSString*)pId withArgs:(NSArray *)data;

- (void) setResourceName:(NSString *)name;

@end
