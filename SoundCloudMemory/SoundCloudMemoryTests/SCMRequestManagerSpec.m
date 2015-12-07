//
//  SCMRequestManagerSpecSpec.m
//  SoundCloudMemory
//
//

#import "Spec.h"

SpecBegin(SCMRequestManager)

describe(@"SCMRequestManager", ^{
    
    __block SCMRequestManager *requestManager;
    
    beforeAll(^{
        [Expecta setAsynchronousTestTimeout:5];
    });
    
    beforeEach(^{
        requestManager = [SCMRequestManager new];
    });
    
    describe(@"request", ^{
       
        it(@"returns ok http status", ^{
            waitUntil(^(DoneCallback done) {
                
                __block NSString *responseString = nil;
                NSURLSession *session = [NSURLSession sharedSession];
                
                [[session dataTaskWithURL:[NSURL URLWithString:kMockURL]
                        completionHandler:^(NSData *data,
                                            NSURLResponse *response,
                                            NSError *error) {
                            if (data.length > 0 && error == nil) {
                                responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            }
                            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                expect(statusCode).to.equal(200);
                                expect(responseString).toNot.beNil();
                            });
                            done();
                        }] resume];
            });
        });

        it(@"has a manager created", ^{
            expect(requestManager).toNot.beNil();
        });
        
        it(@"returns the user id", ^{
            waitUntil(^(DoneCallback done) {
            
              [requestManager requestUserForTrackURL:kTrackURL andCompletionHandler:^void(NSDictionary *dictionary, NSError *error) {
                  NSString *user_id = dictionary[@"user_id"];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      expect(dictionary).toNot.beNil();
                      expect(dictionary).to.beKindOf([NSDictionary class]);
                      expect(user_id).toNot.beNil();
                      expect(error).to.beNil();
                  });
                  done();
              }];
            });
        });
        
        it(@"returns the tracklist of an user", ^{
            waitUntil(^(DoneCallback done) {

                [requestManager requestTrackListForUserId:kUserId andCompletionHandler:^void(NSArray *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        expect(response).toNot.beNil();
                        expect(response).to.beKindOf([NSArray class]);
                        expect(error).to.beNil();
                    });
                    done();
                }];
                
            });
        });
    });

    afterEach(^{
        requestManager = nil;
    });
    
    afterAll(^{

    });
});

SpecEnd
