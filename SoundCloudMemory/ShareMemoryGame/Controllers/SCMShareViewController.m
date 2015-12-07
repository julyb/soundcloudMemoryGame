//
//  SCMShareViewController.m
//  ShareMemoryGame
//


#import "SCMShareViewController.h"
#import "SoundCloudMemoryCoreFramework.h"
#import "SCMCollectionCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSArray+Shuffle.h"
#import "AFNetworkReachabilityManager.h"
@import MobileCoreServices;

static const float kPaddingCell = 5.0f;
static const int kNumberOfCells = 4;
static const float kSpinnerLineWidth = 2.0f;

@interface SCMShareViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nullable, nonatomic, copy) NSMutableArray *trackList;
@property (nullable, weak, nonatomic) IBOutlet UICollectionView *tracksCollectionView;
@property (nonnull, weak, nonatomic) IBOutlet JTMaterialSpinner *spinnerView;
@property (nonnull, weak, nonatomic) IBOutlet UIView *collectionContainerView;
@property (nullable, nonatomic, strong) NSIndexPath *previousSelectedIndexPath;
@property (nonatomic, assign) NSUInteger mismatchedTilesCount;

@end

@implementation SCMShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTapGestureRecognizer];
    [self checkNetworkAvailability];
    [self setupSpinner];
    [self getPermalinkFromExtension];
}

#pragma mark Setup
- (void)setupTapGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(dismissGameView)];
    
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)setupSpinner {
    _spinnerView.circleLayer.lineWidth = kSpinnerLineWidth;
    _spinnerView.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    [_spinnerView beginRefreshing];
}

#pragma mark Load Data Source
// Get permalink from extension context and set the list of tracks
- (void)getPermalinkFromExtension {
    SCMTrackListManager *dataManager = [[SCMTrackListManager alloc] initWithRequestManager:[SCMRequestManager new]];
   
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *provider in item.attachments) {
            [provider loadItemForTypeIdentifier:(NSString *) kUTTypeURL options:nil
                              completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                                  if (error == nil) {
                                      NSString *trackURL = ((NSURL *) item).absoluteString;
                                      [dataManager getTrackListForUserWithTrackURL:trackURL andCompletionHandler:^void(NSArray *trackList, NSError *error) {
                                          if (trackList || trackList.count != 0) {
                                              [self configureTrackList:trackList];
                                              self.mismatchedTilesCount = trackList.count;
                                              [self.tracksCollectionView reloadData];
                                              [self.spinnerView endRefreshing];
                                          } else {
                                              //TODO: handle trackList is nill
                                          }
                                      }];
                                  } else {
                                      //TODO: error handling
                                  }
                              }];
        }
    }
}

#pragma mark - Configure Data Source 
// Add tracks duplicates and put them in a random order
- (void)configureTrackList:(NSArray *)trackList {
    NSMutableArray *trackListToDisplay = [[NSMutableArray alloc] init];
    for (int i = 0; i < trackList.count; i++) {
        [trackListToDisplay addObject:trackList[i]];
        [trackListToDisplay addObject:[trackList[i] copy]];
    }
    self.trackList = [NSMutableArray arrayWithArray:[trackListToDisplay shuffle]];
}

#pragma mark - UICollectionView Data Source
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.trackList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SCMCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SCMCollectionCellIdentifier" forIndexPath:indexPath];
    
    SCMTrack *track = [self.trackList objectAtIndex:indexPath.row];
    [cell.artworkImageView sd_setImageWithURL:[NSURL URLWithString:track.artwork_url] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageRetryFailed];
    cell.backgroundColor = [UIColor grayColor];

    if (track.isMatched) {
        cell.backgroundColor = [UIColor clearColor];
        cell.artworkImageView.hidden = YES;
        [cell setUserInteractionEnabled:YES];
        
    } else if (track.isFlipped) {
        cell.artworkImageView.hidden = NO;
    } else {
        cell.artworkImageView.hidden = YES;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UICollectionView Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat widthSize = (collectionView.frame.size.width / kNumberOfCells) - kPaddingCell;
    CGSize itemSize = CGSizeMake(widthSize, widthSize);
    return itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SCMCollectionCell *cell = (SCMCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    SCMTrack *selectedTrack = [self.trackList objectAtIndex:indexPath.row];
    if (!selectedTrack.isFlipped) {
        selectedTrack.flipped = YES;
        cell.artworkImageView.hidden = NO;
        [UIView transitionWithView:cell.artworkImageView
                          duration:.5
                           options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                               cell.backgroundColor = [UIColor clearColor];
                           }
                        completion:^(BOOL finished) {
                            [self checkIfTilesMatch:selectedTrack withIndexPath:indexPath];
                            if (self.mismatchedTilesCount == 0) {
                                [self gameHasEnded];
                            }
                        }];
    }
}

#pragma mark Memory Game Logic 
- (void)checkIfTilesMatch:(SCMTrack *)selectedTrack withIndexPath:(NSIndexPath *)indexPath{
    if (self.previousSelectedIndexPath) {
        SCMTrack *previousTrack = [self.trackList objectAtIndex:self.previousSelectedIndexPath.row];
        if ([selectedTrack.id isEqualToString:previousTrack.id]) {
            // found a match
            selectedTrack.matched = YES;
            previousTrack.matched = YES;
            self.mismatchedTilesCount -= 1;
        } else {
            // match not found
            selectedTrack.flipped = NO;
            previousTrack.flipped = NO;
        }
        [self.tracksCollectionView reloadItemsAtIndexPaths:@[indexPath, self.previousSelectedIndexPath]];
        self.previousSelectedIndexPath = nil;
   } else {
        self.previousSelectedIndexPath = indexPath;
    }
}

- (void)gameHasEnded {
    [UIView transitionWithView:self.view
                      duration:2.0
                       options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                           self.view.alpha = 0;
                       }
                    completion:^(BOOL finished) {
                        [self dismissGameView];
                    }];
}

- (void)dismissGameView {
    [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
}

#pragma mark UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.view];
    return !CGRectContainsPoint(self.collectionContainerView.frame, touchPoint);
}

#pragma mark - Network Handling
- (void)checkNetworkAvailability {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self setupSpinner];
                [self getPermalinkFromExtension];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            case AFNetworkReachabilityStatusUnknown:
                [self displayNetworkError];
                break;
            default:
                break;
        }
    }];
}

- (BOOL)isNetworkReachable {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

//TODO: Make a class for Alerts Handling
- (void)displayNetworkError {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                             message:@"No internet connection."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
