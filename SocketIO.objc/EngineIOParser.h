//
//  EngineIOParser.h
//  
//
//  Created by Hao-kang Den on 5/7/14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    EngineIOPacketTypeOpen      = 0
    , EngineIOPacketTypeClose   = 1
    , EngineIOPacketTypePing    = 2
    , EngineIOPacketTypePong    = 3
    , EngineIOPacketTypeMessage = 4
    , EngineIOPacketTypeUpgrade = 5
    , EngineIOPacketTypeNoop    = 6
} EngineIOPacketTypes;

typedef void(^EngineIOCallback)(id error, id result);

@interface EngineIOParser : NSObject

+ (NSArray *) packetslist;
+ (NSDictionary *) error;
+ (NSString *) encodePacket:(NSDictionary *)packet;
+ (NSDictionary *) decodePacket:(NSString *)data;
+ (NSString *) encodePayload:(NSArray *)packets;
+ (NSArray *) decodePayload:(NSString *)data;

@end
