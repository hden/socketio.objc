//
//  EngineIOTransportPolling.h
//  
//
//  Created by Hao-kang Den on 5/9/14.
//
//

#import <Foundation/Foundation.h>
#import "EngineIOTransport.h"

@interface EngineIOTransportPolling : EngineIOTransport
{
    BOOL polling;
//    EngineIOTransportOptions *options;
}

- (void) poll;
- (void) doPoll;
- (void) doWrite:(id)data withCallback:(void (^)())callback;

@end
