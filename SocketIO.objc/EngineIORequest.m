//
//  EngineIORequest.m
//  
//
//  Created by Hao-kang Den on 5/19/14.
//
//

#import "EngineIORequest.h"

@implementation EngineIORequest

- (id) initWithOptions:(EngineIOTransportOptions *)options
{
    self = [super init];
    if (self) {
        _options = options;
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [self create:_options.isBinary];
    }
    return self;
}

- (void) create:(BOOL)isBinary
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_options.URL cachePolicy:0 timeoutInterval:60.0];
    request.HTTPMethod = _options.method != nil ? _options.method : @"GET";
    
    if ([_options.method isEqualToString:@"POST"]) {
        if (isBinary) {
            [request addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-type"];
        } else {
            [request addValue:@"text/plain;charset=UTF-8" forHTTPHeaderField:@"Content-type"];
        }
    }
    
    if (_options.data) {
//        request.HTTPBody = [_options.data base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
        request.HTTPBody = _options.data;
        NSLog(@"writing data %@", [[NSString alloc] initWithData:_options.data encoding:NSUTF8StringEncoding]);
    }
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            return [self onError:error];
        }
        if (data) {
            [self onData:data];
        }
    }];
    [task resume];
}

- (void) onSuccess
{
    [self emit:@"success"];
}

- (void) onData:(NSData *)data
{
    NSLog(@"request got data %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [self emit:@"data", data];
    [self onSuccess];
}

- (void) onError:(NSError *)error
{
    [self emit:@"error", error];
    [self cleanup];
}

- (void) cleanup
{
    if (_session != nil) {
        [_session invalidateAndCancel];
         _session = nil;
    }
}

- (void) abort
{
    [self cleanup];
}

@end
