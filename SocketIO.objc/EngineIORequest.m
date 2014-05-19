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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_options.URL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60.0];
    request.HTTPMethod = _options.method;
    
    if ([_options.method isEqualToString:@"POST"]) {
        if (isBinary) {
            [request addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-type"];
        } else {
            [request addValue:@"text/plain;charset=UTF-8" forHTTPHeaderField:@"Content-type"];
        }
    }
    
    if (_options.data) {
        request.HTTPBody = _options.data;
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
