//
//  EngineIOClient_Test.m
//  SocketIO Tests
//
//  Created by Hao-kang Den on 6/2/14.
//
//

#define EXP_SHORTHAND

#import <XCTest/XCTest.h>
#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"
#import "EngineIOClient.h"

SpecBegin(EngineIOClient)

describe(@"connection", ^{
    setAsyncSpecTimeout(20);
    
    __block EngineIOClient *socket;
    
    afterEach(^{
        [socket close];
    });
    
    it(@"should connect to localhost", ^AsyncBlock {
        socket = [[EngineIOClient alloc] initWith:nil];
        [socket once:@"open" listener:^{
            [socket once:@"message" listener:^(NSString *data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(data).to.equal(@"hi");
                    done();
                });
            }];
        }];
    });
    
    xit(@"should receive multibyte utf-8 strings with polling", ^AsyncBlock {
        socket = [[EngineIOClient alloc] initWith:nil];
        NSString *str = @"智に働けば角が立つ。情に棹させば流される。";
        [socket once:@"open" listener:^{
            [socket on:@"message" listener:^(NSString *data) {
                if ([data isEqualToString:@"hi"]) {
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(data).to.equal(str);
                    done();
                });
            }];
            
            [socket send:str callback:nil];
        }];
    });
    
    it(@"should not send packets if socket closes", ^AsyncBlock {
        socket = [[EngineIOClient alloc] initWith:nil];
        [socket once:@"open" listener:^{
            __block BOOL noPacket = true;
            [socket once:@"packetCreate" listener:^{
                noPacket = false;
            }];
            
            [socket on:@"close" listener:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(noPacket).to.equal(true);
                    done();
                });
            }];
            [socket close];
        }];
    
    });
    
});

SpecEnd
