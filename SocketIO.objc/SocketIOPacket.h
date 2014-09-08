//
//  SocketIOPacket.h
//  
//
//  Created by Hao-kang Den on 5/7/14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    SocketIOPacketTypeConnect       = 0
    , SocketIOPacketTypeDisconnect  = 1
    , SocketIOPacketTypeEvent       = 2
    , SocketIOPacketTypeAck         = 3
    , SocketIOPacketTypeError       = 4
    , SocketIOPacketTypeBinaryEvent = 5
    , SocketIOPacketTypeBinaryAck   = 6
} SocketIOPacketTypes;

@interface SocketIOPacket : NSObject

@property (nonatomic) SocketIOPacketTypes type;
@property (nonatomic) NSArray *data;
@property (nonatomic) id attachments;
@property (nonatomic) NSString *nsp;
@property (nonatomic) NSNumber *id;

+ (NSArray *) types;
- (BOOL) isEqualToPacket:(SocketIOPacket *)packet;
- (BOOL) isEqual:(id)object;

@end
