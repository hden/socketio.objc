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
            EngineIOPacket *packet = [[EngineIOPacket alloc] init];
            packet.type            = EngineIOPacketTypeMessage;
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should encode an open packet", ^{
            EngineIOPacket *packet = [[EngineIOPacket alloc] init];
            packet.type = EngineIOPacketTypeOpen;
            packet.data = @"{\"some\":\"json\"}";
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should encode a close packet", ^{
            EngineIOPacket *packet = [[EngineIOPacket alloc] init];
            packet.type = EngineIOPacketTypeClose;
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should encode an ping packet", ^{
            EngineIOPacket *packet = [[EngineIOPacket alloc] init];
            packet.type = EngineIOPacketTypePing;
            packet.data = @"1";
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should encode an pong packet", ^{
            EngineIOPacket *packet = [[EngineIOPacket alloc] init];
            packet.type = EngineIOPacketTypePong;
            packet.data = @"1";
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should encode an message packet", ^{
            EngineIOPacket *packet = [[EngineIOPacket alloc] init];
            packet.type = EngineIOPacketTypeMessage;
            packet.data = @"aaa";
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        xit(@"should encode a message packet coercing to string");
        
        it(@"should encode an upgrade packet", ^{
            EngineIOPacket *packet = [[EngineIOPacket alloc] init];
            packet.type = EngineIOPacketTypeUpgrade;
            expect([EngineIOParser decodePacket:[EngineIOParser encodePacket:packet]]).to.equal(packet);
        });
        
        it(@"should match the encoding format", ^{
            EngineIOPacket *packet1 = [[EngineIOPacket alloc] init];
            packet1.type = EngineIOPacketTypeMessage;
            packet1.data = @"test";
            expect([EngineIOParser encodePacket:packet1]).to.equal(@"4test");
            
            EngineIOPacket *packet2 = [[EngineIOPacket alloc] init];
            packet2.type = EngineIOPacketTypeMessage;
            expect([EngineIOParser encodePacket:packet2]).to.equal(@"4");
        });
    });
    
    describe(@"decoding error handing", ^{
        EngineIOPacket *err = [[EngineIOPacket alloc] init];
        err.type = EngineIOPacketTypeError;
        err.data = @"parser error";
        
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
            EngineIOPacket *packet1 = [[EngineIOPacket alloc] init];
            packet1.type = EngineIOPacketTypeMessage;
            packet1.data = @"a";
            NSArray *payload = @[packet1];
            expect([EngineIOParser decodePayload:[EngineIOParser encodePayload:payload]]).to.equal(payload);
            
            EngineIOPacket *packet2 = [[EngineIOPacket alloc] init];
            packet2.type = EngineIOPacketTypePing;
            payload = @[packet1, packet2];
            expect([EngineIOParser decodePayload:[EngineIOParser encodePayload:payload]]).to.equal(payload);
        });
        
        it(@"should encode/decode empty payloads", ^{
            NSArray *payload = @[];
            expect([EngineIOParser decodePayload:[EngineIOParser encodePayload:payload]]).to.equal(payload);
        });
    });
    
    describe(@"decoding error handling", ^{
        EngineIOPacket *err = [[EngineIOPacket alloc] init];
        err.type = EngineIOPacketTypeError;
        err.data = @"parser error";
        
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
