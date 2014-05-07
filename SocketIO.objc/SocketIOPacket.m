//
//  SocketIOPacket.m
//  
//
//  Created by Hao-kang Den on 5/7/14.
//
//

#import "SocketIOPacket.h"

@implementation SocketIOPacket

# pragma mark -
# pragma mark pseudo constants

+ (NSArray *) types
{
    return @[
             @"CONNECT"
             , @"DISCONNECT"
             , @"EVENT"
             , @"BINARY_EVENT"
             , @"ACK"
             , @"ERROR"
             ];
}

- (BOOL) isEqualToPacket:(SocketIOPacket *)packet
{
    BOOL isSameType = self.type == packet.type;
    BOOL hasSameData = (self.data == nil && packet.data == nil) || [self.data isEqualToArray:packet.data];
    BOOL hasSameAttachments = (self.attachments == nil && packet.attachments == nil) || [self.attachments isEqual:packet.attachments];
    BOOL hasSameNsp = (self.nsp == nil && packet.nsp == nil) || [self.nsp isEqualToString:packet.nsp];
    BOOL hasSameId = (self.id == nil && packet.id == nil) || [self.id isEqualToNumber:packet.id];
    return isSameType && hasSameData && hasSameAttachments && hasSameNsp && hasSameId;
}

- (BOOL) isEqual:(id)object
{
    if (self == object) {
        return true;
    }
    
    if (![object isKindOfClass:[SocketIOPacket class]]) {
        return false;
    }
    
    return [self isEqualToPacket:object];
}

@end
