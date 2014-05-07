//
//  SocketIOParser_Test.m
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
#import "SocketIOParser.h"

SpecBegin(SocketIOParser)

describe(@"parser", ^{
    it(@"exposes types", ^{
        SocketIOPacket *packet = [[SocketIOPacket alloc] init];
        packet.type = SocketIOPacketTypeConnect;
        packet.nsp  = @"/woot";
        
        expect([SocketIOParser decodeString:[SocketIOParser encodeAsString:packet]]).to.equal(packet);
    });
    
    it(@"encodes disconnection", ^{
        SocketIOPacket *packet = [[SocketIOPacket alloc] init];
        packet.type = SocketIOPacketTypeDisconnect;
        packet.nsp  = @"/woot";
        
        expect([SocketIOParser decodeString:[SocketIOParser encodeAsString:packet]]).to.equal(packet);
    });
    
    it(@"encodes an event", ^{
        SocketIOPacket *packet = [[SocketIOPacket alloc] init];
        packet.type = SocketIOPacketTypeEvent;
        packet.data = @[@"a", @1, @{}];
        packet.nsp  = @"/";
        
        expect([SocketIOParser decodeString:[SocketIOParser encodeAsString:packet]]).to.equal(packet);
        
        packet.nsp  = @"/test";
        expect([SocketIOParser decodeString:[SocketIOParser encodeAsString:packet]]).to.equal(packet);
    });
    
    it(@"encodes an ack", ^{
        SocketIOPacket *packet = [[SocketIOPacket alloc] init];
        packet.type = SocketIOPacketTypeAck;
        packet.data = @[@"a", @1, @{}];
        packet.id   = @123;
        packet.nsp  = @"/";
        
        expect([SocketIOParser decodeString:[SocketIOParser encodeAsString:packet]]).to.equal(packet);
    });
});

SpecEnd