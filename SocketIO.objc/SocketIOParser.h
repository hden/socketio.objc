//
//  SocketIOParser.h
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
} SocketIOPacketTypes;

@interface SocketIOParser : NSObject

+ (NSArray *) packetTypes;
+ (NSDictionary *) decodeString:(NSString *)str;

@end
