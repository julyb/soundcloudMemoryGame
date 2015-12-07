//
//  SCMTrackListManagerSpec.m
//  SoundCloudMemory
//
//  Created by Jules on 9/17/15.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "Spec.h"

SpecBegin(SCMTrackListManager)

describe(@"SCMTrackListManager", ^{
    
    __block SCMTrackListManager *trackListManager;
    __block SCMRequestManager *requestManager;
    
    beforeAll(^{
        [Expecta setAsynchronousTestTimeout:20];

    });
    
    beforeEach(^{
        requestManager = [SCMRequestManager new];
        trackListManager = [[SCMTrackListManager alloc] initWithRequestManager:requestManager];
    });
    
    describe(@"designated initializer", ^{
        it(@"sets all properties to input values", ^{
            expect(trackListManager.requestManager).to.equal(requestManager);
        });
    });
    
    describe(@"request", ^{
        it(@"returns the tracklist of the user id for the given track url", ^{
            waitUntil(^(DoneCallback done) {
                
                [trackListManager getTrackListForUserWithTrackURL:kTrackURL andCompletionHandler:^void(NSArray *response, NSError *error) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         expect(response).toNot.beNil();
                         expect(response).to.beKindOf([NSArray class]);
                         expect(response.count).to.beGreaterThan(0);
                         expect(response[0]).to.beKindOf([SCMTrack class]);
                         expect(error).to.beNil();
                     });
                    done();
                }];
            });
        });
    });
    
    afterEach(^{
        requestManager = nil;
        trackListManager = nil;
    });
    
    afterAll(^{

    });
});

SpecEnd
