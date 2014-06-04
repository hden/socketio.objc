//
//  EngineIOParser.h
//  
//
//  Created by Hao-kang Den on 5/7/14.
//
//

#import <Foundation/Foundation.h>
#import "EngineIOPacket.h"

@interface EngineIOParser : NSObject

+ (int) protocal;
+ (NSArray *) packetslist;
+ (EngineIOPacket *) error;
+ (NSString *) encodePacket:(EngineIOPacket *)packet;
+ (EngineIOPacket *) decodePacket:(NSString *)data;
+ (NSString *) encodePayload:(NSArray *)packets;
+ (NSArray *) decodePayload:(NSString *)data;

@end
