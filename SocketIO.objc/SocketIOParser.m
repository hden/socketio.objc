//
//  SocketIOParser.m
//  
//
//  Created by Hao-kang Den on 5/7/14.
//
//

#import "SocketIOParser.h"

@implementation SocketIOParser

# pragma mark -
# pragma mark pseudo constants

+ (SocketIOPacket *) error
{
    SocketIOPacket *err = [[SocketIOPacket alloc] init];
    err.type = SocketIOPacketTypeError;
    err.data = @[@"parser error"];
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
 * Encode packet as string.
 *
 * @param {Object} packet
 * @return {String} encoded
 * @api private
 */

+ (NSString *) encodeAsString:(SocketIOPacket *)packet
{
    NSMutableString *str = [NSMutableString stringWithString:@""];
    BOOL nsp = false;
    
    // first is type
    [str appendFormat:@"%d", packet.type];
    
    // attachments if we have them
    if (packet.type == SocketIOPacketTypeBinaryEvent || packet.type == SocketIOPacketTypeAck) {
        if (packet.attachments != nil) {
            [str appendFormat:@"%@-", packet.attachments];
        } else {
            [str appendString:@"-"];
        }
        
    }
    
    // if we have a namespace other than `/`
    // we append it followed by a comma `,`
    if (packet.nsp != nil && ![packet.nsp isEqualToString:@"/"]) {
        nsp = true;
        [str appendString:packet.nsp];
    }
    
    // immediately followed by the id
    if (packet.id != nil) {
        if (nsp) {
            [str appendString:@","];
            nsp = false;
        }
        [str appendFormat:@"%@", packet.id];
    }
    
    // json data
    if (packet.data != nil) {
        if (nsp) {
            [str appendString:@","];
        }
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:packet.data options:0 error:nil];
        [str appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }
    
    return str;
}

/**
 * Decode a packet String (JSON data)
 *
 * @param {String} str
 * @return {Object} packet
 * @api private
 */

+ (SocketIOPacket *) decodeString:(NSString *)str
{
    SocketIOPacket *p    = [[SocketIOPacket alloc] init];
    NSScanner *scanner   = [NSScanner scannerWithString:str];
    scanner.scanLocation = 1;
    
    // look up type
    NSArray *packetsTypes    = [SocketIOPacket types];
    NSString *typeStr        = [str substringToIndex:1];
    SocketIOPacketTypes type = typeStr.intValue;
    p.type = type;
    
    BOOL isNumeric   = [self isNumeric:typeStr];
    BOOL isValidType = p.type < packetsTypes.count;
    
    if (!(isNumeric && isValidType)) {
        return [self error];
    }
    
    // look up attachments if type binary
    if (p.type == SocketIOPacketTypeBinaryEvent || p.type == SocketIOPacketTypeAck) {
        NSString *attachments;
        [scanner scanUpToString:@"-" intoString:&attachments];
        p.attachments = attachments;
        scanner.scanLocation++;
    }
    
    // look up namespace (if any)
    if ([str characterAtIndex:scanner.scanLocation] == '/') {
        NSString __autoreleasing *nsp;
        [scanner scanUpToString:@"," intoString:&nsp];
        p.nsp = nsp;
        if (scanner.isAtEnd) return p;
        scanner.scanLocation++;
    } else {
        p.nsp = @"/";
    }
    
    // look up id
    NSString *next  = [str substringWithRange:NSMakeRange(scanner.scanLocation, 1)];
    BOOL isNotEmpty = ![next isEqualToString:@""];
    if (isNotEmpty && [self isNumeric:next]) {
        NSString *id;
        [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&id];
        p.id = [NSNumber numberWithInt:id.intValue];
    }
    
    // look up json data
    if (!scanner.isAtEnd) {
        NSData *d = [[str substringFromIndex:scanner.scanLocation] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *data = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            return [self error];
        }
        p.data = data;
    }
    
    return p;
}

@end
