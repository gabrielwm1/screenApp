//
//  ParseHelper.h
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseUI/PFLogInViewController.h>
#import "PFMovie.h"
#import "PFMovieLocation.h"
#import "PFTrailer.h"
#import "PFCast.h"
#import "PFCrew.h"
#import "ParseConverter.h"
#import "TMDBMovie.h"
#import "LocationHelper.h"
#import "ScreenLogInViewController.h"

@class PFLoginBlocks;
@class OCMovie;

#define parseDidAddMovieToWatchlistNotification  @"didAddMovieToWatchlist"
#define parseDidAddMovieToSeenNotification @"didAddMovieToSeen"

typedef void(^SuccessBlock)(void);
typedef void(^ObjectBlock)(id object);
typedef void(^BoolBlock)(BOOL result);
typedef void(^ArrayBlock)(NSArray *results);
typedef void(^ErrorBlock)(NSError *error);
typedef void(^QueryBlock)(PFQuery *query);
typedef void(^NameImageBlock)(NSString *name, NSString *userName, NSString *image);

typedef enum OnState {
    onWatchlist,
    onSeen,
    onEither
} OnState;

@interface RequestingBlock : NSObject

@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) BoolBlock boolBlock;

+ (RequestingBlock *)withUser:(PFUser *)user boolBlock:(BoolBlock)boolBl;

@end


@interface ParseHelper : NSObject <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate> {
    NSArray *userMovies;
    NSArray *seenMovies;
    PFLoginBlocks *loginBlocks;
    ScreenLogInViewController *loginViewController;
    NSArray *requestedUsers;
    NSArray *friends;
    NSArray *friendRequests;
    NSArray *facebookFriendsIds;
    NSArray *twitterFriendIds;
    NSMutableArray *requestingObjectsForSentFriendRequest;
    NSMutableArray *requestingObjectsForFriends;
    NSMutableArray *requestingObjectsForFriendRequested;
    NSMutableDictionary *friendsWithMovieOnWatchlist;
    BOOL gettingRequestedUsers;
    BOOL gettingFriends;
    BOOL gettingFriendRequests;
}

- (void)addMovieToWatchlist:(TMDBMovie *)movie success:(ObjectBlock)success error:(ErrorBlock)errorBlock;
- (void)addMovieToSeen:(TMDBMovie *)movie success:(ObjectBlock)success error:(ErrorBlock)errorBlock;
- (void)removeMovieFromWatchlist:(TMDBMovie *)movie success:(SuccessBlock)success error:(ErrorBlock)errorBlock;
- (void)removeMovieFromSeen:(TMDBMovie *)movie success:(SuccessBlock)success error:(ErrorBlock)errorBlock;
- (void)moviesForUser:(PFUser *)user success:(ArrayBlock)success error:(ErrorBlock)errorBlock refresh:(BOOL)refresh;
- (void)moviesForUser:(PFUser *)user success:(ArrayBlock)success error:(ErrorBlock)errorBlock;
- (void)movieForTmdbMovie:(TMDBMovie *)movie success:(ObjectBlock)success error:(ErrorBlock)errorBlock;
- (void)moviesSeenForUser:(PFUser *)user success:(ArrayBlock)success error:(ErrorBlock)errorBlock;
- (void)userHasMovieId:(NSString *)tmdbId success:(BoolBlock)success error:(ErrorBlock)errorBlock;
- (void)userHasSeenMovieId:(NSString *)tmdbId success:(BoolBlock)success error:(ErrorBlock)errorBlock;
- (BOOL)userHasOCMovie:(OCMovie *)movie state:(OnState)state;
- (NSArray *)userHasOCMovies:(NSArray *)movies state:(OnState)state;
- (void)showLoginOnViewController:(UIViewController *)controller blocks:(PFLoginBlocks *)blocks;
- (int)maxDemandFromUsersMovies;

- (void)getWatchlistIfNeeded:(SuccessBlock)success error:(ErrorBlock)errorBlock;
- (void)getSeenIfNeeded:(SuccessBlock)success error:(ErrorBlock)errorBlock;

- (void)mostPopularAroundCoordinate:(CLLocation *)location radius:(float)radius limit:(int)limit success:(ArrayBlock)success error:(ErrorBlock)errorBlock;

- (void)requestMovieWithTitle:(NSString *)title description:(NSString *)description success:(SuccessBlock)success error:(ErrorBlock)errorBlock;

- (void)rateMovieWithTmdbId:(NSString *)tmdbId rating:(float)rating success:(SuccessBlock)success errorBlock:(ErrorBlock)errorblock;

// Returns movies that were recently added to showtimes that are on watchlist.
- (void)checkForNewShowtimesOnWatchlist:(ArrayBlock)success error:(ErrorBlock)errorBlock;

#pragma mark - Social
- (void)facebookFriendsWithApp:(ArrayBlock)success error:(ErrorBlock)errorBlock;
- (void)getParseFriends:(ArrayBlock)succcess error:(ErrorBlock)errorBlock;
- (void)twitterFriends:(ArrayBlock)success error:(ErrorBlock)errorBlock;
- (void)userWithFacebookId:(NSString *)fbId success:(ObjectBlock)success error:(ErrorBlock)error;
- (void)searchUsers:(NSString *)search success:(ArrayBlock)success error:(ErrorBlock)error;
- (void)sendFriendRequestToUser:(PFUser *)user success:(SuccessBlock)success error:(ErrorBlock)errorBlock;
- (void)acceptFriendRequestFromUser:(PFUser *)user success:(SuccessBlock)success error:(ErrorBlock)errorBlock;
- (void)userHasRequestedUser:(PFUser *)user success:(BoolBlock)success;
- (void)userIsFriendsWithUser:(PFUser *)user success:(BoolBlock)success;
- (void)friendRequests:(ArrayBlock)success error:(ErrorBlock)errorBlock;
- (void)userHasRequestedToBeFriends:(PFUser *)user success:(BoolBlock)success;

- (void)friendsWithMovieOnWatchlist:(TMDBMovie *)movie success:(ArrayBlock)success error:(ErrorBlock)error;
- (void)friendsWithMovieSeen:(TMDBMovie *)movie success:(ArrayBlock)success error:(ErrorBlock)error;

- (void)twitterGetNameImage:(NameImageBlock)success error:(ErrorBlock)error;

- (void)friendsQuery:(QueryBlock)success;
- (void)twitterParseFriendsQuery:(QueryBlock)success;
- (void)facebookFriendsParseQuery:(QueryBlock)success;

+ (ParseHelper *)sharedInstance;

- (void)logout;

#pragma mark - EXPERIMENTAL

- (void)movieReccommendations:(ArrayBlock)success error:(ErrorBlock)errorBlock;

@end
