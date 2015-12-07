//
//  NSArray+Shuffle.h
//  SoundCloudMemory
//
//
//

#import <Foundation/Foundation.h>

@interface NSArray (Shuffle)

/* Returns an array where the elements are in a random order using Fisher–Yates shuffle algorithm
 */
- (NSArray *)shuffle;

@end
