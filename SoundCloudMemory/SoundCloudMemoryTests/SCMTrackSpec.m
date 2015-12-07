//
//  SCMTrackSpecSpec.m
//  SoundCloudMemory
//
//  Created by Jules on 9/16/15.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "Spec.h"

SpecBegin(SCMTrack)

describe(@"SCMTrack", ^{
    
    __block SCMTrack *track;
    __block NSDictionary *dictionary;
    
    beforeAll(^{

    });
    
    beforeEach(^{
        dictionary = @{@"id": @"224168339", @"user_id": kUserId, @"artwork_url": @"https://i1.sndcdn.com/artworks-000129749219-3t1ac5-large.jpg" };
        track = [[SCMTrack alloc] initWithDictionary:dictionary error:nil];
    });
    
    describe(@"designated initializer", ^{
        it(@"sets all properties to input values", ^{
            expect(track.id).to.equal(dictionary[@"id"]);
            expect(track.user_id).to.equal(dictionary[@"user_id"]);
            expect(track.artwork_url).to.equal(dictionary[@"artwork_url"]);
            expect(track.isFlipped).to.equal(NO);
            expect(track.isMatched).to.equal(NO);
        });
    });
    
    afterEach(^{
        dictionary = nil;
        track = nil;
    });
    
    afterAll(^{

    });
});

SpecEnd
