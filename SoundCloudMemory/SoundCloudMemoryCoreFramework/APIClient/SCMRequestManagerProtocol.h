//
//  SCMRequestManagerProtocol.h
//  SoundCloudMemory
//
//
//

#import <Foundation/Foundation.h>

@protocol SCMRequestManagerProtocol <NSObject>

/**
 * @discussion A request to the API to get the userId
 * @param trackURL The URL of the track that we get from the extension context once we share a track
 * @param completion The completion block of the request
 */
- (void)requestUserForTrackURL:(NSString * __nonnull) trackURL
          andCompletionHandler:(nonnull void (^)(NSDictionary * __nullable response,
                                                 NSError * __nullable error))completion;

/**
 * @discussion A request to the API to get the track list for a specific user id
 * @param user_id The SoundCloud user id
 * @param completion The completion block of the request
 */
- (void)requestTrackListForUserId:(NSString * __nonnull) userId
             andCompletionHandler:(nonnull void (^)(NSArray * __nullable response,
                                                    NSError * __nullable error))completion;

@end
