//
//  EngineIOParser_Test.m
//  SocketIO Tests
//
//  Created by Hao-kang Den on 5/7/14.
//
//
#define EXP_SHORTHAND

#import <XCTest/XCTest.h>
#import "Specta.h"
#import "Expecta.h"
#import "OCMock.h"
#import "EngineIOParser.h"

SpecBegin(EngineIOParser)

describe(@"packets", ^{
    describe(@"encoding and decoding", ^{
        it(@"should allow no data", ^{
            NSDictionary *packet = @{@"type": @"message"};
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should encode an open packet", ^{
            NSDictionary *packet = @{
                                     @"type": @"open"
                                   , @"data": @"{\"some\":\"json\"}"
                                    };
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should encode a close packet", ^{
            NSDictionary *packet = @{@"type": @"close"};
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should encode an ping packet", ^{
            NSDictionary *packet = @{
                                     @"type": @"ping"
                                   , @"data": @"1"
                                    };
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should encode an pong packet", ^{
            NSDictionary *packet = @{
                                     @"type": @"pong"
                                   , @"data": @"1"
                                    };
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should encode an message packet", ^{
            NSDictionary *packet = @{
                                     @"type": @"message"
                                   , @"data": @"aaa"
                                    };
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        xit(@"should encode a message packet coercing to string");
        
        it(@"should encode an upgrade packet", ^{
            NSDictionary *packet = @{@"type": @"upgrade"};
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should match the encoding format", ^{
            NSDictionary *packet = @{
                                     @"type": @"message"
                                   , @"data": @"test"
                                    };
            expect([EngineIOParser encodePacket:packet]).to.equal(@"4test");
            expect([EngineIOParser encodePacket:[NSDictionary dictionaryWithObject:@"message" forKey:@"type"]]).to.equal(@"4");
        });
    });
    
    describe(@"decoding error handing", ^{
        NSDictionary *err = @{
                              @"type": @"error"
                            , @"data": @"parser error"
                             };
        
        it(@"should disallow bad format", ^{
            expect([EngineIOParser decodePacket:@"::"]).to.equal(err);
        });
        
        it(@"should disallow inexistent types", ^{
            expect([EngineIOParser decodePacket:@"94103"]).to.equal(err);
        });
    });
});

describe(@"payloads", ^{
    describe(@"encoding and decoding", ^{
        it(@"should encode/decode packets", ^{
            NSArray *payload = @[@{@"type": @"message", @"data": @"a"}];
            expect([EngineIOParser decodePayload:[EngineIOParser encodePayload:payload]]).to.equal(payload);
            payload = @[@{@"type": @"message", @"data": @"a"}, @{@"type": @"ping"}];
            expect([EngineIOParser decodePayload:[EngineIOParser encodePayload:payload]]).to.equal(payload);
        });
        
        it(@"should encode/decode empty payloads", ^{
            NSArray *payload = @[];
            expect([EngineIOParser decodePayload:[EngineIOParser encodePayload:payload]]).to.equal(payload);
        });
    });
    
    describe(@"decoding error handling", ^{
        NSDictionary *err = @{@"type": @"error", @"data": @"parser error"};
        it(@"should err on bad payload format", ^{
            expect([EngineIOParser decodePayload:@"1!"]).to.equal(@[err]);
            expect([EngineIOParser decodePayload:@""]).to.equal(@[err]);
            expect([EngineIOParser decodePayload:@"))"]).to.equal(@[err]);
        });
        
        it(@"should err on bad payload length", ^{
            expect([EngineIOParser decodePayload:@"1:"]).to.equal(@[err]);
        });
        
        it(@"should err on bad packet format", ^{
            expect([EngineIOParser decodePayload:@"3:99:"]).to.equal(@[err]);
            expect([EngineIOParser decodePayload:@"1:aa"]).to.equal(@[err]);
            expect([EngineIOParser decodePayload:@"1:a2:b"]).to.equal(@[err]);
        });
    });
});

SpecEnd
