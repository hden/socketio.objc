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
    it(@"should work", ^AsyncBlock {
        EngineIOTransportOptions *opt       = [[EngineIOTransportOptions alloc] initWithURL:nil];
        [opt querySetValue:@"polling" forKey:@"transport"];
        EngineIOTransportPolling *transport = [[EngineIOTransportPolling alloc] initWithOptions:opt];
        [transport open];
        [transport on:@"error" listener:^(NSError *error) {
            @throw error;
        }];
        [transport on:@"open" listener:^{
            [transport on:@"close" listener:done];
            [transport close];
        }];
    });
});

SpecEnd
