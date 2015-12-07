//
//  SCMTrackListManager.h
//  SoundCloudMemory
//
//
//

#import <Foundation/Foundation.h>
#import "SCMRequestManager.h"

@interface SCMTrackListManager : NSObject

@property (nonnull, nonatomic, strong) SCMRequestManager *requestManager;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithRequestManager:(nullable id<SCMRequestManagerProtocol>)requestManager NS_DESIGNATED_INITIALIZER;

- (void)getTrackListForUserWithTrackURL:(NSString * __nonnull)trackURL
                   andCompletionHandler:(nonnull void (^)(NSArray * __nullable trackList,
                                                 NSError * __nullable error))completion;

@end
