//
//  EngineIOParser.m
//  
//
//  Created by Hao-kang Den on 5/7/14.
//
//

#import "EngineIOParser.h"

@implementation EngineIOParser

# pragma mark -
# pragma mark pseudo constants

+ (int) protocal
{
    return 3;
}

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

+ (EngineIOPacket *) error
{
    EngineIOPacket *err = [[EngineIOPacket alloc] init];
    err.type = EngineIOPacketTypeError;
    err.data = @"parser error";
    return err;
}

# pragma mark -
# pragma mark private methods

+ (BOOL) isNumeric:(NSString *)str
{
    NSCharacterSet *numeric = [NSCharacterSet decimalDigitCharacterSet];
    switch (str.length) {
        case 0:
            return false;
            break;
            
        case 1:
            return [[@"0,1,2,3,4,5,6,7,8,9" componentsSeparatedByString:@","] indexOfObject:str] != NSNotFound;
            break;
            
        default:
            return [numeric isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:str]];
            break;
    }
}

# pragma mark -
# pragma mark public methods

/**
 * Encodes a packet.
 *
 *     <packet type id> [ <data> ]
 *
 * Example:
 *
 *     5hello world
 *     3
 *     4
 *
 * Binary is encoded in an identical principle
 *
 * @api private
 */

+ (NSString *) encodePacket:(EngineIOPacket *)packet
{
    if (packet.data != nil) {
        return [NSString stringWithFormat:@"%d%@", packet.type, packet.data];
    }
    
    return [NSString stringWithFormat:@"%d", packet.type];
}

/**
 * Decodes a packet.
 *
 * @return {NSDictionary} with `type` and `data` (if any)
 * @api private
 */

+ (EngineIOPacket *) decodePacket:(NSString *)data
{
    EngineIOPacket *p    = [[EngineIOPacket alloc] init];
    NSScanner *scanner   = [NSScanner scannerWithString:data];
    scanner.scanLocation = 1;
    
    // look up type
    NSArray *packetsTypes    = [self packetslist];
    NSString *typeStr        = [data substringToIndex:1];
    EngineIOPacketTypes type = typeStr.intValue;
    p.type = type;
    
    BOOL isNumeric   = [self isNumeric:typeStr];
    BOOL isValidType = p.type < packetsTypes.count;
    
    if (!(isNumeric && isValidType)) {
        return [self error];
    }
    
    if (data.length > 1) {
        p.data = [data substringFromIndex:1];
    }
    
    return p;
}

//{
//    NSArray *packetslist    = [EngineIOParser packetslist];
//    NSString *type          = [data substringToIndex:1];
//    
//    BOOL isNumeric   = [EngineIOParser isNumeric:type];
//    BOOL isValidType = type.intValue < packetslist.count;
//    
//    if (!(isNumeric && isValidType)) {
//        return [EngineIOParser error];
//    }
//    
//    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
//    d[@"type"] = [EngineIOParser packetslist][type.intValue];
//    
//    if (data.length > 1) {
//        d[@"data"] = [data substringFromIndex:1];
//    }
//    
//    return d;
//}

/**
 * Encodes multiple messages (payload).
 *
 *     <length>:data
 *
 * Example:
 *
 *     11:hello world2:hi
 *
 * If any contents are binary, they will be encoded as base64 strings. Base64
 * encoded strings are marked with a b before the length specifier
 *
 * @param {NSArray} packets
 * @api private
 */

+ (NSString *) encodePayload:(NSArray *)packets
{
    if (packets.count == 0) {
        return @"0:";
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (EngineIOPacket *packet in packets) {
        NSString *encoded = [EngineIOParser encodePacket:packet];
        encoded = [NSString stringWithFormat:@"%u:%@", (unsigned)encoded.length, encoded];
        [results addObject:encoded];
    }
    
    return [results componentsJoinedByString:@""];
}

/*
 * Decodes data when a payload is maybe expected. Possible binary contents are
 * decoded from their base64 representation
 *
 * @param {NSString} data, callback method
 * @api public
 */

+ (NSArray *) decodePayload:(NSString *)data
{
    // 111:0{"sid":"47uAgML6ugNVXoh2AAAB","upgrades":["websocket","flashsocket"],"pingInterval":25000,"pingTimeout":60000}
    NSMutableArray *frames     = [NSMutableArray array];
    NSMutableArray *components = [NSMutableArray arrayWithArray:[data componentsSeparatedByString:@":"]];
    NSString *header           = components[0];
    
    if (![EngineIOParser isNumeric:header]) {
        return @[[EngineIOParser error]];
    }
    
    [components removeObjectAtIndex:0];
    
    NSString *body;
    if (components.count == 1) {
        body = components[0];
    } else {
        body = [components componentsJoinedByString:@":"];
    }

    int idx = header.intValue;
    
    if (idx > body.length) {
        return @[[EngineIOParser error]];
    }
    
    NSString *frame = [body substringToIndex:idx];
    NSString *tail  = [body substringFromIndex:idx];
    
    if (![frame isEqualToString:@""]) {
        EngineIOPacket *packet = [EngineIOParser decodePacket:frame];
        if ([packet isEqual:[EngineIOParser error]]) {
            // earily return following the original engine.io-parser
            return @[packet];
        }
        [frames addObject:packet];
    };
    
    if (![tail isEqualToString:@""]) {
        // more frames
        [frames addObjectsFromArray:[EngineIOParser decodePayload:[body substringFromIndex:idx]]];
    }
    
    return frames;
}

@end
