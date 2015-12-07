//
//  SCMRequestManager.m
//  SoundCloudMemory
//
//
//

#import "SCMRequestManager.h"

static NSString *const kAPIBaseURL = @"https://api.soundcloud.com/";
static NSString *const kClientIDValue = @"ef06a036e68c2001e74d54e0f30a2c27";

static NSString *const kURLQueryDictionaryKey = @"url";
static NSString *const kClientIdQueryDictionaryKey = @"client_id";
static NSString *const kLimitQueryDictionaryKey = @"limit";
static NSString *const kLimitQueryDictionaryValue = @"8";

static NSString *const kResolvePath = @"resolve";
static NSString *const kTracksForUserPath = @"users/%@/tracks";

@interface SCMRequestManager ()

@end

@implementation SCMRequestManager


- (instancetype)init {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config];
    self = [self initWithSession:urlSession];
    return self;
}

- (nonnull instancetype)initWithSession:(NSURLSession *)session {
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)requestForUrl:(NSURL *)url withCompletionHandler:(void (^)(id response, NSError *error))completion {
    
    [[_session dataTaskWithURL:url
             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                 if (!error) {
                     NSError *parseError = nil;
                     NSArray *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:NSJSONReadingMutableContainers
                                                                               error: &parseError];
                     if (!parseError) {
                         completion(jsonResponse, nil);
                     } else {
                         completion(nil, parseError);
                     }
                 } else {
                     completion(nil, error);
                 }
             }] resume];
}

- (void)requestUserForTrackURL:(NSString *) trackURL
          andCompletionHandler:(void (^)(NSDictionary * response,
                                                 NSError *error))completion {
    
    NSString *urlString = [kAPIBaseURL stringByAppendingString:kResolvePath];
    NSDictionary *queryDictionary = @{ kURLQueryDictionaryKey      : trackURL,
                                       kClientIdQueryDictionaryKey : kClientIDValue };
    NSURL *endpoint = [self endpointForUrlString:urlString withQuery:queryDictionary];
    
    [self requestForUrl:endpoint withCompletionHandler:^(id response, NSError *error) {
        if (!error) {
            completion(response, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)requestTrackListForUserId:(NSString *) userId
             andCompletionHandler:(void (^)(NSArray *response,
                                                    NSError *error))completion {

    NSString *urlString = [kAPIBaseURL stringByAppendingString:[NSString stringWithFormat:kTracksForUserPath, userId]];
    NSDictionary *queryDictionary = @{ kClientIdQueryDictionaryKey : kClientIDValue,
                                       kLimitQueryDictionaryKey    : kLimitQueryDictionaryValue };
    NSURL *endpoint = [self endpointForUrlString:urlString withQuery:queryDictionary];

    [self requestForUrl:endpoint withCompletionHandler:^(NSArray *response, NSError *error) {
        if (!error) {
            completion(response, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (NSURL *)endpointForUrlString:(NSString *)urlString withQuery:(NSDictionary *)queryDictionary {
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSString *key in queryDictionary) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:queryDictionary[key]]];
    }
    components.queryItems = queryItems;
    return components.URL;
}

@end
