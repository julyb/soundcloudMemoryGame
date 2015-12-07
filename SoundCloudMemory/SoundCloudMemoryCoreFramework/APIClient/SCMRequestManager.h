//
//  SCMRequestManager.h
//  SoundCloudMemory
//
//
//

#import <Foundation/Foundation.h>
#import "SCMRequestManagerProtocol.h"

@interface SCMRequestManager : NSObject <SCMRequestManagerProtocol>

@property (nullable, nonatomic, strong) NSURLSession *session;

- (nonnull instancetype) init;
- (nonnull instancetype) initWithSession:(NSURLSession * __nullable)session NS_DESIGNATED_INITIALIZER;

@end
