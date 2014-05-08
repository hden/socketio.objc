//
//  EngineIOPacket.h
//  
//
//  Created by Hao-kang Den on 5/8/14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    EngineIOPacketTypeError     = -1
    , EngineIOPacketTypeOpen    = 0
    , EngineIOPacketTypeClose   = 1
    , EngineIOPacketTypePing    = 2
    , EngineIOPacketTypePong    = 3
    , EngineIOPacketTypeMessage = 4
    , EngineIOPacketTypeUpgrade = 5
    , EngineIOPacketTypeNoop    = 6
} EngineIOPacketTypes;

@interface EngineIOPacket : NSObject

@property (nonatomic) EngineIOPacketTypes type;
@property (nonatomic) NSString *data;

+ (NSArray *) packetslist;
- (BOOL) isEqualToPacket:(EngineIOPacket *)packet;
- (BOOL) isEqual:(id)object;

@end
