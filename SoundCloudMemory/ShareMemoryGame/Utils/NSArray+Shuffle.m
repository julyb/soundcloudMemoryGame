//
//  NSArray+Shuffle.m
//  SoundCloudMemory
//
//  
//

#import "NSArray+Shuffle.h"

@implementation NSArray (Shuffle)

- (NSArray *)shuffle {
    NSMutableArray *shuffledArray = [self mutableCopy];
    NSUInteger count = [shuffledArray count];
    for (NSUInteger i = count - 1; i > 0; i--) {
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((int32_t)(i + 1))];
    }
    return [shuffledArray copy];
}

@end
