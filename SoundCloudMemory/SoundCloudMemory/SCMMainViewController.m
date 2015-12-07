//
//  SCMMainViewController.m
//  SoundCloudMemory
//


#import "SCMMainViewController.h"

static NSString * const kSoundCloudURL = @"soundcloud:tracks:";

@implementation SCMMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTouchOpenSoundCloud:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kSoundCloudURL]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kSoundCloudURL]];
    } else {
        //TODO: alert with message: 'Please install SoundCloud app'
    }
}

@end
