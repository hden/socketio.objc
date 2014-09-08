//
//  SocketIOSocket.h
//  
//
//  Created by Hao-kang Den on 6/7/14.
//
//

#import <Foundation/Foundation.h>
#import "Emitter+Blocks.h"
#import "SocketIOPacket.h"

@interface SocketIOSocket : NSObject

@property (nonatomic) NSString *nsp;
@property (nonatomic) int ids;
@property (nonatomic) NSMutableDictionary *acks;
@property (nonatomic) NSMutableArray *buffer;
@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL disconnected;

- (void) close;
- (void) disconnect;

@end
