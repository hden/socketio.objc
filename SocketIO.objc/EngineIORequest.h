//
//  EngineIORequest.h
//  
//
//  Created by Hao-kang Den on 5/19/14.
//
//

#import <Foundation/Foundation.h>
#import "Emitter+Blocks.h"
#import "EngineIOTransportOptions.h"

@interface EngineIORequest : NSObject
{
    EngineIOTransportOptions *_options;
    NSURLSession *_session;
}

- (id) initWithOptions:(EngineIOTransportOptions *)options;
- (void) create:(BOOL)isBinary;
- (void) abort;

@end
