//
//  SCMTrack.m
//  SoundCloudMemory
//
//
//

#import "SCMTrack.h"

static NSString *const kArtworkDictionaryKey = @"artwork_url";
static NSString *const kFlippedProperty = @"flipped";
static NSString *const kMatchedProperty = @"matched";

@implementation SCMTrack

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:kArtworkDictionaryKey]) {
        return YES;
    }
    return NO;
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName{
    if ([propertyName isEqualToString:kFlippedProperty] || [propertyName isEqualToString:kMatchedProperty]) {
        return YES;
    }
    return NO;
}


@end
