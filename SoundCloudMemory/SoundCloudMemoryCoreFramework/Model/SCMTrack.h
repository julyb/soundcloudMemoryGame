//
//  SCMTrack.h
//  SoundCloudMemory
//
//
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface SCMTrack : JSONModel

@property (nonnull, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, copy) NSString *user_id;
@property (nullable, nonatomic, copy) NSString<Optional> *artwork_url;

/**
 * @brief The property becomes YES if the track has been selected, otherwise is NO
 */
@property (nonatomic, assign, getter=isFlipped) BOOL flipped;

/**
 * @brief The property becomes YES if the track has been matched with its pair, otherwise is NO
 */
@property (nonatomic, assign, getter=isMatched) BOOL matched;

@end
