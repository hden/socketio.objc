//
//  EngineIOTransportOptions.h
//  
//
//  Created by Hao-kang Den on 5/12/14.
//
//

#import <Foundation/Foundation.h>

@interface EngineIOTransportOptions : NSObject <NSCopying>

@property (nonatomic) NSDictionary *query;
@property (nonatomic) NSString *method;
@property (nonatomic) NSData *data;
@property (nonatomic) BOOL isBinary;
@property (nonatomic, readonly) NSURLComponents *uri;

- (id) initWithURL:(NSString *)URL;
- (void) querySetValue:(id)object forKey:(id<NSCopying>)key;
- (void) queryRemoveValueForKey:(id<NSCopying>)key;
- (NSURL *)URL;

@end
