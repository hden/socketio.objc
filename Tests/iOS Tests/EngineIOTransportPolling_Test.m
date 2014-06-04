//
//  EngineIOTransportPolling_Test.m
//  SocketIO Tests
//
//  Created by Hao-kang Den on 5/21/14.
//
//

#define EXP_SHORTHAND

#import <XCTest/XCTest.h>
#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"
#import "EngineIORequest.h"
#import "EngineIOTransportPolling.h"

SpecBegin(EngineIOTransportPolling)

describe(@"polling", ^{
    setAsyncSpecTimeout(20);
    it(@"should work", ^AsyncBlock {
        EngineIOTransportOptions *opt       = [[EngineIOTransportOptions alloc] initWithURL:nil];
        EngineIOTransportPolling *transport = [[EngineIOTransportPolling alloc] initWithOptions:opt];
        [transport open];
        [transport on:@"error" listener:^(NSError *error) {
            @throw error;
        }];
        [transport once:@"open" listener:^{
            [transport once:@"packet" listener:^(EngineIOPacket *packet) {
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[packet.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                [transport.options querySetValue:data[@"sid"] forKey:@"sid"];
                [transport once:@"close" listener:done];
                [transport close];
            }];
        }];
    });
});

SpecEnd
