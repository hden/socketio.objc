//
//  SocketIOParser.h
//  
//
//  Created by Hao-kang Den on 5/7/14.
//
//

#import <Foundation/Foundation.h>
#import "SocketIOPacket.h"

@interface SocketIOParser : NSObject

+ (void) encode:(SocketIOPacket *)packet withCallback:(void (^)(NSArray *encodedPackets))callback;
+ (SocketIOPacket *) error;
+ (NSString *) encodeAsString:(SocketIOPacket *)packet;
+ (SocketIOPacket *) decodeString:(NSString *)str;

@end
