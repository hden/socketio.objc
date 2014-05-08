//
//  EngineIOPacket.m
//  
//
//  Created by Hao-kang Den on 5/8/14.
//
//

#import "EngineIOPacket.h"

@implementation EngineIOPacket

+ (NSArray *) packetslist
{
    return @[
             @"open"
             , @"close"
             , @"ping"
             , @"pong"
             , @"message"
             , @"upgrade"
             , @"noop"
            ];
}

- (BOOL) isEqualToPacket:(EngineIOPacket *)packet
{
    BOOL isSameType = self.type == packet.type;
    BOOL hasSameData = (self.data == nil && packet.data == nil) || [self.data isEqualToString:packet.data];
    return isSameType && hasSameData;
}

- (BOOL) isEqual:(id)object
{
    if (self == object) {
        return true;
    }
    
    if (![object isKindOfClass:[EngineIOPacket class]]) {
        return false;
    }
    
    return [self isEqualToPacket:object];
}

@end
