//
//  EngineIORequest_Test.m
//  SocketIO Tests
//
//  Created by Hao-kang Den on 5/19/14.
//
//

#define EXP_SHORTHAND

#import <XCTest/XCTest.h>
#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"
#import "EngineIORequest.h"
#import "EngineIOTransportOptions.h"

SpecBegin(EngineIORequest)

describe(@"request", ^{
    it(@"should work", ^AsyncBlock {
        EngineIOTransportOptions *opt = [[EngineIOTransportOptions alloc] initWithString:@"http://requestb.in/tprw7otp"];
        opt.data = [@"{\"foo\":\"bar\"}" dataUsingEncoding:NSUTF8StringEncoding];
        opt.method = @"POST";
        
        EngineIORequest *req = [[EngineIORequest alloc] initWithOptions:opt];
        [req once:@"error" listener:^ (NSError *error) {
            @throw error;
        }];
        
        [req once:@"success" listener:^{
            done();
        }];
    });
});

SpecEnd
