//
//  SCMTrackListManager.m
//  SoundCloudMemory
//
//
//

#import "SCMTrackListManager.h"
#import "SCMTrack.h"

@interface SCMTrackListManager()

@end

@implementation SCMTrackListManager


- (instancetype)initWithRequestManager:(SCMRequestManager *)requestManager {
    if (self = [super init]) {
        _requestManager = requestManager;
    }
    return self;
}

- (void)getTrackListForUserWithTrackURL:(NSString *)trackURL
      andCompletionHandler:(void (^)(NSArray *trackList,
                                     NSError *error))completion {

     [self getUserForTrackURL:trackURL andCompletionHandler:^(NSString *userId, NSError *error) {
         if (error == nil) {
             __weak SCMTrackListManager *weakSelf = self;
             [weakSelf getTrackListForUserId:userId andCompletionHandler:^(NSArray *trackList, NSError *error) {
                 if (error == nil) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         completion(trackList, nil);
                     });
                 } else {
                     completion(nil, error);
                 }
             }];
         } else {
             completion(nil, error);
         }
     }];
}

- (void)getUserForTrackURL:(NSString *) trackURL
      andCompletionHandler:(void (^)(NSString *userId,
                                     NSError *error))completion {
    
    [_requestManager requestUserForTrackURL:trackURL andCompletionHandler:^(NSDictionary *response, NSError *error){
        if (error == nil) {
            NSError *err = nil;
            SCMTrack *track = [[SCMTrack alloc] initWithDictionary:response error:&err];
            completion(track.user_id, nil);
        } else {
            completion(0, error);
        }
    }];
}

- (void)getTrackListForUserId:(NSString *) userId
         andCompletionHandler:(void (^)(NSArray *trackList,
                                       NSError *error))completion {
    [_requestManager requestTrackListForUserId:userId andCompletionHandler:^(NSArray *response, NSError *error) {
        if (error == nil) {
            NSMutableArray *trackList = [[NSMutableArray alloc] init];
            for (NSDictionary *trackDictionary in response) {
                if ([trackDictionary isKindOfClass:[NSDictionary class]]) {
                    NSError *err = nil;
                    SCMTrack *track = [[SCMTrack alloc] initWithDictionary:trackDictionary error:&err];
                    [trackList addObject:track];
                } else {
                    //TODO: handle dictionary is not valid
                    completion(nil, nil);
                }
            }
            completion(trackList, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
