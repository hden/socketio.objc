//
//  SocketIOParser.m
//  
//
//  Created by Hao-kang Den on 5/7/14.
//
//

#import "SocketIOParser.h"

@implementation SocketIOParser

+ (NSArray *) packetTypes
{
    return [NSArray arrayWithObjects:
            @"CONNECT"
            , @"DISCONNECT"
            , @"EVENT"
            , @"BINARY_EVENT"
            , @"ACK"
            , @"ERROR"
            , nil];
}

+ (NSDictionary *) decodeString:(NSString *)str
{
    NSMutableDictionary *p = [[NSMutableDictionary alloc] init];
    NSNumberFormatter *f   = [[NSNumberFormatter alloc] init];
    f.numberStyle          = NSNumberFormatterDecimalStyle;
    NSNumber *type         = [f numberFromString:[str substringToIndex:1]];
    
    [p setObject:type forKey:@"type"];
    
    return p;
}

@end
