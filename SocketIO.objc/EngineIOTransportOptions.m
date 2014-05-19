//
//  EngineIOTransportOptions.m
//  
//
//  Created by Hao-kang Den on 5/12/14.
//
//

#import "EngineIOTransportOptions.h"

@implementation EngineIOTransportOptions

- (id) initWithString:(NSString *)URLString
{
    self = [super init];
    if (self) {
        _uri          = [[NSURLComponents alloc] initWithString:URLString];
        self.method   = @"GET";
        self.query    = @{@"b64":@"0"};
        self.isBinary = false;
    }
    return self;
}

- (NSString *) queryString
{
    NSMutableString *qs = @"".mutableCopy;
    for (NSString *key in self.query.allKeys) {
        id raw = self.query[key];
        NSString *value = nil;
        // nullish trap
        if (!(raw == [NSNull null] || ![raw description].length)) {
            value = [[raw description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [qs appendFormat:@"%@%@%@%@"
         , qs.length ? @"&" : @""
         , [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
         , value ? @"=" : @""
         , value ? value : @""
        ];
    }
    
    return qs.length ? qs : nil;
}

- (void) setQuery:(NSDictionary *)query
{
    _query = query;
    self.uri.query = [self queryString];
}

- (void) querySetValue:(id)object forKey:(id<NSCopying>)key
{
    NSMutableDictionary *q = self.query.mutableCopy;
    q[key] = object;
    self.query = q;
}

- (void) queryRemoveValueForKey:(id<NSCopying>)key
{
    NSMutableDictionary *q = self.query.mutableCopy;
    [q removeObjectForKey:key];
    self.query = q;
}

- (NSURL *)URL
{
    NSURL *url = self.uri.URL;
    return url;
}

@end
