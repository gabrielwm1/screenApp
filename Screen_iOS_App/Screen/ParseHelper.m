//
//  ParseHelper.m
//  Screen
//
//  Created by Mason Wolters on 11/8/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "ParseHelper.h"
#import "PFLoginBlocks.h"
#import "OnConnectHelper.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import "RottenTomatoesHelper.h"
#import "TMDBHelper.h"

dispatch_queue_t bgQueue;

@implementation RequestingBlock

+ (RequestingBlock *)withUser:(PFUser *)user boolBlock:(BoolBlock)boolBl {
    RequestingBlock *block = [[RequestingBlock alloc] init];
    block.user = user;
    block.boolBlock = boolBl;
    return block;
}

@end

@implementation ParseHelper

#pragma mark - Public

- (void)addMovieToWatchlist:(TMDBMovie *)mov success:(ObjectBlock)success error:(ErrorBlock)errorBlock {
    [[OnConnectHelper sharedInstance] movieIsNowPlaying:mov success:^(BOOL isPlaying) {
        if (isPlaying) {
            [[OnConnectHelper sharedInstance] ocMovieForTMDBMovieInNowPlaying:mov success:^(OCMovie *oc) {
                if (oc) {
                    [[PFUser currentUser] addObject:oc.rootId forKey:@"hasBeenAlerted"];
                    [[PFUser currentUser] saveInBackground];
                }
            }error:^(NSError *error) {
                
            }];
        }
    }error:^(NSError *error) {
    }];
    
    [self actuallyAddMovieToWatchlist:mov success:success error:errorBlock];
}

- (void)actuallyAddMovieToWatchlist:(TMDBMovie *)mov success:(ObjectBlock)success error:(ErrorBlock)errorBlock {
    PFMovie *movie = [ParseConverter movieForTmdbMovie:mov];
    [movie saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded || ![error.userInfo[@"error"] isEqualToString:@"fail"]) {
            if (error) {
                movie.objectId = error.userInfo[@"error"];
            } else {
                //is brand new
                
            }
            [[movie relationForKey:@"users"] addObject:[PFUser currentUser]];
            [movie incrementKey:@"userCount"];
            [[[PFUser currentUser] relationForKey:@"movies"] addObject:movie];
            
            [PFObject saveAllInBackground:@[[PFUser currentUser], movie] block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    userMovies = [@[movie] arrayByAddingObjectsFromArray:userMovies];
                    [[NSNotificationCenter defaultCenter] postNotificationName:parseDidAddMovieToWatchlistNotification object:self userInfo:@{@"movie": movie}];
                    success(movie);
                } else {
                    errorBlock(error);
                }
            }];
            
            [[LocationHelper sharedInstance] getCurrentLocation:^(CLLocation *location) {
                PFObject *movieLocation = [PFObject objectWithClassName:@"MovieLocation"];
                [movieLocation setObject:movie forKey:@"movie"];
                [movieLocation setObject:movie.objectId forKey:@"movieId"];
                [movieLocation setObject:[PFUser currentUser] forKey:@"user"];
                [movieLocation setObject:[PFGeoPoint geoPointWithLocation:location] forKey:@"location"];
                [movieLocation saveInBackground];
            }error:^(NSError *error) {
                NSLog(@"error getting location");
            }];
            
//            if (!error) {
//                if (!movie.rottenTomatoesScore) {
//                    [self saveRottenTomatoesForMovie:movie];
//                }
//            }
        } else {
            errorBlock(error);
        }
    }];
}

- (void)saveRottenTomatoesForMovie:(PFMovie *)movie {
    NSLog(@"should save rotten tomatoes");

    void(^saveTomatoes)(NSString *imdbId) = ^(NSString *imdbId) {
        NSLog(@"getting rotten tomatoes for imdb: %@", imdbId);
        if (imdbId.length > 2) {
            imdbId = [imdbId substringFromIndex:2];
        }
        [[RottenTomatoesHelper sharedInstance] movieForIMDBId:imdbId success:^(RTMovie *rt) {
            NSLog(@"success saving rotten tomatoes: %@", rt.ratings.criticsScore);
            movie.rottenTomatoesScore = rt.ratings.criticsScore;
            [movie saveInBackground];
        }error:^(NSError *error) {
            NSLog(@"error saving rotten tomatoes: %@", error.description);
        }];
    };
    
    if (movie.imdbId && ![movie.imdbId isEqualToString:@""]) {
        saveTomatoes(movie.imdbId);
    } else {
        [[TMDBHelper sharedInstance] movieForId:movie.tmdbId success:^(TMDBMovie *tmdb) {
            saveTomatoes(tmdb.imdbId);
        }error:^(NSError *error) {
            
        }];
    }
}

- (void)addMovieToSeen:(TMDBMovie *)mov success:(ObjectBlock)success error:(ErrorBlock)errorBlock {
    PFMovie *movie = [ParseConverter movieForTmdbMovie:mov];
    [movie saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded || ![error.userInfo[@"error"] isEqualToString:@"fail"]) {
            if (error) {
                movie.objectId = error.userInfo[@"error"];
            }
            [[movie relationForKey:@"usersSeen"] addObject:[PFUser currentUser]];
            [movie incrementKey:@"seenCount"];
            [[[PFUser currentUser] relationForKey:@"seen"] addObject:movie];
            
            [PFObject saveAllInBackground:@[[PFUser currentUser], movie] block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    seenMovies = [@[movie] arrayByAddingObjectsFromArray:seenMovies];
                    [[NSNotificationCenter defaultCenter] postNotificationName:parseDidAddMovieToSeenNotification object:self userInfo:@{@"movie": movie}];
                    [self removeMovieFromWatchlist:mov success:^{
                        
                    }error:^(NSError *error) {
                        
                    }];
                    success(movie);
                } else {
                    errorBlock(error);
                }
            }];
        } else {
            errorBlock(error);
        }
    }];
}

- (void)removeMovieFromWatchlist:(TMDBMovie *)tmdb success:(SuccessBlock)success error:(ErrorBlock)errorBlock {
    PFMovie *movie;
    for (PFMovie *mov in userMovies) {
        if ([mov.tmdbId isEqualToString:tmdb.tmdbId]) {
            movie = mov;
        }
    }
    
    if (movie) {
    
    PFRelation *movies = [[PFUser currentUser] relationForKey:@"movies"];
    [movies removeObject:movie];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error || !succeeded) {
            errorBlock(error);
        } else {
            NSMutableArray *newMovies = [NSMutableArray array];
            for (PFMovie *mov in userMovies) {
                if (![movie.objectId isEqualToString:mov.objectId]) {
                    [newMovies addObject:mov];
                }
            }
            userMovies = [NSArray arrayWithArray:newMovies];
            [[NSNotificationCenter defaultCenter] postNotificationName:parseDidAddMovieToWatchlistNotification object:self userInfo:@{@"movie": movie}];
            success();
        }
    }];
        
    PFRelation *users = [movie relationForKey:@"users"];
    [users removeObject:[PFUser currentUser]];
    
    [movie incrementKey:@"userCount" byAmount:[NSNumber numberWithInt:-1]];
    [movie saveInBackground];
    
    PFQuery *movieLocationQuery = [PFQuery queryWithClassName:@"MovieLocation"];
    [movieLocationQuery whereKey:@"movie" equalTo:movie];
    [movieLocationQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [movieLocationQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (error) {
        } else {
            if (results) {
                [PFObject deleteAllInBackground:results block:^(BOOL succeeded, NSError *deleteError) {
                    if (error || !succeeded) {
                    } else {
                    }
                }];
            }
        }
    }];
        
    } else {
        errorBlock(nil);
    }
}

- (void)removeMovieFromSeen:(TMDBMovie *)tmdb success:(SuccessBlock)success error:(ErrorBlock)errorBlock {
    PFMovie *movie;
    for (PFMovie *mov in seenMovies) {
        if ([mov.tmdbId isEqualToString:tmdb.tmdbId]) {
            movie = mov;
        }
    }
    
    if (movie) {
        
        PFRelation *seen = [[PFUser currentUser] relationForKey:@"seen"];
        [seen removeObject:movie];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error || !succeeded) {
                errorBlock(error);
            } else {
                NSMutableArray *newMovies = [NSMutableArray array];
                for (PFMovie *mov in seenMovies) {
                    if (![movie.objectId isEqualToString:mov.objectId]) {
                        [newMovies addObject:mov];
                    }
                }
                seenMovies = [NSArray arrayWithArray:newMovies];
                [[NSNotificationCenter defaultCenter] postNotificationName:parseDidAddMovieToSeenNotification object:self userInfo:@{@"movie": movie}];
                success();
            }
        }];
        
        PFRelation *users = [movie relationForKey:@"usersSeen"];
        [users removeObject:[PFUser currentUser]];
        
        [movie incrementKey:@"seenCount" byAmount:[NSNumber numberWithInt:-1]];
        [movie saveInBackground];
    } else {
        errorBlock(nil);
    }
}

- (void)moviesForUser:(PFUser *)user success:(ArrayBlock)success error:(ErrorBlock)errorBlock refresh:(BOOL)refresh {
    if (userMovies && !refresh && [user.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        success(userMovies);
    } else {
        PFRelation *movies = [user relationForKey:@"movies"];
        PFQuery *query = movies.query;
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        query.limit = 1000;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([user isEqual:[PFUser currentUser]]) {
                userMovies = objects;
            }
            if (error) {
                errorBlock(error);
            } else {
                success(objects);
            }
        }];
    }
}

- (void)moviesForUser:(PFUser *)user success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    [self moviesForUser:user success:success error:errorBlock refresh:NO];
}

- (void)moviesSeenForUser:(PFUser *)user success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    if (seenMovies && [user.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        success(seenMovies);
    } else {
        PFRelation *seen = [user relationForKey:@"seen"];
        PFQuery *query = seen.query;
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        query.limit = 1000;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([user isEqual:[PFUser currentUser]]) {
                seenMovies = objects;
            }
            if (error) {
                errorBlock(error);
            } else {
                success(objects);
            }
        }];
    }
}

- (void)movieForTmdbMovie:(TMDBMovie *)movie success:(ObjectBlock)success error:(ErrorBlock)errorBlock {
    PFQuery *query = [PFQuery queryWithClassName:@"Movie"];
    [query whereKey:@"tmdbId" equalTo:movie.tmdbId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            if (results.count > 0) {
                success(results[0]);
            } else {
                success(nil);
            }
        }
    }];
}

- (int)maxDemandFromUsersMovies {
    int max = 1;
    for (PFMovie *mov in userMovies) {
        if (mov.userCount > max) {
            max = mov.userCount;
        }
    }
    return max;
}

- (void)userHasMovieId:(NSString *)tmdbId success:(BoolBlock)success error:(ErrorBlock)errorBlock {
    [self moviesForUser:[PFUser currentUser] success:^(NSArray *results) {
        BOOL hasMovie = NO;
        for (PFMovie *movie in userMovies) {
            if ([movie.tmdbId isEqualToString:tmdbId]) {
                hasMovie = YES;
            }
        }
        success(hasMovie);
    }error:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)userHasSeenMovieId:(NSString *)tmdbId success:(BoolBlock)success error:(ErrorBlock)errorBlock {
    [self moviesSeenForUser:[PFUser currentUser] success:^(NSArray *results) {
        BOOL seenMovie = NO;
        for (PFMovie *movie in results) {
            if ([movie.tmdbId isEqualToString:tmdbId]) {
                seenMovie = YES;
            }
        }
        success(seenMovie);
    }error:^(NSError *error) {
        errorBlock(error);
    }];
}

- (BOOL)userHasOCMovie:(OCMovie *)movie state:(OnState)state {
    NSArray *searchThrough = (state == onWatchlist)?userMovies:seenMovies;
    BOOL matches = NO;
    for (PFMovie *mov in searchThrough) {
        if ([[OnConnectHelper sharedInstance] ocMovie:movie matchesPFMovie:mov]) matches = YES;
    }

    return matches;
}

- (NSArray *)userHasOCMovies:(NSArray *)movies state:(OnState)state {
    NSMutableArray *searchThrough = [NSMutableArray array];
    if (state == onWatchlist) {
        searchThrough = [NSMutableArray arrayWithArray:userMovies];
    } else if (state == onSeen) {
        searchThrough = [NSMutableArray arrayWithArray:seenMovies];
    } else if (state == onEither) {
        NSLog(@"on either");
        searchThrough = [NSMutableArray arrayWithArray:userMovies];
        [searchThrough addObjectsFromArray:seenMovies];
    }
    NSMutableDictionary *userMoviesDict = [NSMutableDictionary dictionary];
    
    for (PFMovie *mov in searchThrough) {
        [userMoviesDict setObject:mov forKey:[StringNormalizer normalizeString:mov.title]];
    }
    
    NSMutableArray *results = [NSMutableArray array];

    for (OCMovie *mov in movies) {
        if ([userMoviesDict objectForKey:[StringNormalizer normalizeString:mov.title]]) {
            //match title
            if ([[OnConnectHelper sharedInstance] ocMovie:mov matchesPFMovie:[userMoviesDict objectForKey:[StringNormalizer normalizeString:mov.title]]]) {
                //match!
                [results addObject:mov];
            }
        }
    }
    
    
    return results;
}

- (void)getWatchlistIfNeeded:(SuccessBlock)success error:(ErrorBlock)errorBlock {
    [self moviesForUser:[PFUser currentUser] success:^(NSArray *results) {
        success();
    }error:errorBlock];
}

- (void)getSeenIfNeeded:(SuccessBlock)success error:(ErrorBlock)errorBlock {
    [self moviesSeenForUser:[PFUser currentUser] success:^(NSArray *results) {
        success();
    }error:errorBlock];
}

- (void)mostPopularAroundCoordinate:(CLLocation *)location radius:(float)radius limit:(int)limit success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"topMoviesForArea" withParameters:@{@"latitude": [NSNumber numberWithDouble:location.coordinate.latitude],
                                                                           @"longitude": [NSNumber numberWithDouble:location.coordinate.longitude],
                                                                           @"radius": [NSNumber numberWithFloat:radius*1000],
                                                                           @"limit": [NSNumber numberWithInt:limit]}
        block:^(NSArray *results, NSError *error) {
            if (error) {
                errorBlock(error);
            } else {
                success(results);
            }
    }];
}

- (void)requestMovieWithTitle:(NSString *)title description:(NSString *)description success:(SuccessBlock)success error:(ErrorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"requestMovie" withParameters:@{@"title": title, @"description": description} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            success();
        }
    }];
}

- (void)rateMovieWithTmdbId:(NSString *)tmdbId rating:(float)rating success:(SuccessBlock)success errorBlock:(ErrorBlock)errorblock {
    if ([[PFUser currentUser] objectForKey:@"ratings"]) {
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:[[PFUser currentUser] objectForKey:@"ratings"]];
        [mutDict setObject:[NSNumber numberWithFloat:rating] forKey:tmdbId];
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:mutDict];
        [[PFUser currentUser] setObject:dict forKey:@"ratings"];
    } else {
        NSDictionary *dict = @{tmdbId: [NSNumber numberWithFloat:rating]};
        [[PFUser currentUser] setObject:dict forKey:@"ratings"];
    }
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            errorblock(error);
        } else {
            success();
        }
    }];
}

- (void)checkForNewShowtimesOnWatchlist:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    [self moviesForUser:[PFUser currentUser] success:^(NSArray *watchlist) {
        [[OnConnectHelper sharedInstance] showtimesInRadiusOfCurrentLocation:[[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue] success:^(NSArray *showtimes) {
            [self getWatchlistIfNeeded:^{
                
                dispatch_async(bgQueue, ^{
                    NSMutableArray *alerts = [NSMutableArray array];
                    for (OCMovie *showtime in showtimes) {
                        if ([self userHasOCMovie:showtime state:onWatchlist] && ![self userHasBeenAlertedOfOcMovie:showtime]) {
                            [alerts addObject:showtime];
                        }
                    }
                    if (alerts.count > 0) {
                        NSMutableArray *newAlerted = [NSMutableArray array];
                        if ([[PFUser currentUser] objectForKey:@"hasBeenAlerted"]) {
                            newAlerted = [NSMutableArray arrayWithArray:[[PFUser currentUser] objectForKey:@"hasBeenAlerted"]];
                        }
                        for (OCMovie *mov in alerts) {
                            [newAlerted addObject:mov.rootId];
                        }
                        [[PFUser currentUser] setObject:newAlerted forKey:@"hasBeenAlerted"];
                        [[PFUser currentUser] saveInBackground];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(alerts);
                    });
                });
 
            }error:^(NSError *error) {
                errorBlock(error);
            }];
        }error:^(NSError *error) {
            errorBlock(error);
        }];
    }error:^(NSError *error) {
        errorBlock(error);
    }];
}

- (BOOL)userHasBeenAlertedOfOcMovie:(OCMovie *)movie {
    if ([[PFUser currentUser] objectForKey:@"hasBeenAlerted"]) {
        NSArray *alerted = [[PFUser currentUser] objectForKey:@"hasBeenAlerted"];
        for (NSString *rootId in alerted) {
            if ([movie.rootId isEqualToString:rootId]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Social

- (void)facebookFriendsWithApp:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"me/friends?fields=id,name,picture" parameters:nil HTTPMethod:@"GET"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {

        if (error) {
            errorBlock(error);
        } else {
            NSArray* friends1 = (NSArray*)[result objectForKey:@"data"];
            
            NSMutableArray *fbIds = [NSMutableArray array];
            for (NSDictionary<FBGraphUser> *user in friends1) {
                [fbIds addObject:user.objectID];
            }
            facebookFriendsIds = [NSArray arrayWithArray:fbIds];
            success(friends1);
        }
        
        
    }];
}

- (void)userWithFacebookId:(NSString *)fbId success:(ObjectBlock)success error:(ErrorBlock)errorBlock {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"fbId" equalTo:fbId];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            if (objects && objects.count > 0) {
                success(objects[0]);
            } else {
                errorBlock(nil);
            }
        }
    }];
}

- (void)twitterFriends:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    
}

- (void)getParseFriends:(ArrayBlock)succcess error:(ErrorBlock)errorBlock {
    PFQuery *query = [[[PFUser currentUser] relationForKey:@"friends"] query];
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [query addAscendingOrder:@"name"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            succcess(objects);
        }
    }];
}

- (void)searchUsers:(NSString *)search success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    PFQuery *query = [PFUser query];
    [query whereKey:@"lowercaseName" hasPrefix:[search lowercaseString]];
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [query addAscendingOrder:@"lowercaseName"];
    [query setLimit:100];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            success(objects);
        }
    }];
}

- (void)sendFriendRequestToUser:(PFUser *)user success:(SuccessBlock)success error:(ErrorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"friendRequestUser" withParameters:@{@"userId": user.objectId} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:user];
            
            // Send push notification to query
            [PFPush sendPushMessageToQueryInBackground:pushQuery
                                           withMessage:[NSString stringWithFormat:@"%@ wants to be friends", [[PFUser currentUser] objectForKey:@"name"]]];
            success();
        }
    }];

    if (requestedUsers) {
        requestedUsers = [requestedUsers arrayByAddingObject:user];
    }
}

- (void)acceptFriendRequestFromUser:(PFUser *)user success:(SuccessBlock)success error:(ErrorBlock)errorBlock {
    [PFCloud callFunctionInBackground:@"acceptFriendRequest" withParameters:@{@"userId": user.objectId} block:^(id object, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            if (friendRequests) {
                NSMutableArray *temp = [NSMutableArray array];
                for (PFUser *user2 in friendRequests) {
                    if (![user.objectId isEqualToString:user2.objectId]) {
                        [temp addObject:user2];
                    }
                }
                friendRequests = [NSArray arrayWithArray:temp];
            }
            if (friends) {
                friends = [friends arrayByAddingObject:user];
            }
            success();
        }
    }];
}

- (void)userHasRequestedUser:(PFUser *)user success:(BoolBlock)success {
    if (requestedUsers) {
        [self userIsFriendsWithUser:user success:^(BOOL isFriends) {
            if (isFriends) {
                success(NO);
            } else {
                success([self userIsInArray:user array:requestedUsers]);
            }
        }];
    } else {
        if(!requestingObjectsForSentFriendRequest) requestingObjectsForSentFriendRequest = [NSMutableArray array];
        [requestingObjectsForSentFriendRequest addObject:[RequestingBlock withUser:user boolBlock:success]];
        
        if (!gettingRequestedUsers) {
            gettingRequestedUsers = YES;
            PFQuery *query = [[[PFUser currentUser] relationForKey:@"sentFriendRequests"] query];
            [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    requestedUsers = objects;
                    for (RequestingBlock *object in requestingObjectsForSentFriendRequest) {
                        [self userIsFriendsWithUser:user success:^(BOOL isFriends) {
                            if (isFriends) {
                                object.boolBlock(NO);
                            } else {
                                object.boolBlock([self userIsInArray:object.user array:requestedUsers]);
                            }
                        }];
                    }
                    gettingRequestedUsers = NO;
                    requestingObjectsForSentFriendRequest = nil;
                }
            }];
        }
    }
}

- (void)userIsFriendsWithUser:(PFUser *)user success:(BoolBlock)success {
    if (friends) {
        success([self userIsFriendsWithUser:user]);
    } else {
        if (!requestingObjectsForFriends) requestingObjectsForFriends = [NSMutableArray array];
        [requestingObjectsForFriends addObject:[RequestingBlock withUser:user boolBlock:success]];
        
        if (!gettingFriends) {
            gettingFriends = YES;
            PFQuery *query = [[[PFUser currentUser] relationForKey:@"friends"] query];
            [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    
                } else {
                    friends = objects;
                    for (RequestingBlock *object in requestingObjectsForFriends) {
                        object.boolBlock([self userIsFriendsWithUser:object.user]);
                    }
                    gettingFriends = NO;
                    requestingObjectsForFriends = nil;
                }
            }];
        }
    }
}

- (void)userHasRequestedToBeFriends:(PFUser *)user success:(BoolBlock)success {
    if (friendRequests) {
        [self userIsFriendsWithUser:user success:^(BOOL isFriends) {
            if (isFriends) {
                success(NO);
            } else {
                success([self userIsInArray:user array:friendRequests]);
            }
        }];
    } else {
        if (!requestingObjectsForFriendRequested) requestingObjectsForFriendRequested = [NSMutableArray array];
        [requestingObjectsForFriendRequested addObject:[RequestingBlock withUser:user boolBlock:success]];
        
        if (!gettingFriendRequests) {
            gettingFriendRequests = YES;
            PFQuery *query = [[[PFUser currentUser] relationForKey:@"friendRequests"] query];
            [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    
                } else {
                    friendRequests = objects;
                    for (RequestingBlock *object in requestingObjectsForFriendRequested) {
                        [self userIsFriendsWithUser:user success:^(BOOL isFriends) {
                            if (isFriends) {
                                object.boolBlock(NO);
                            } else {
                                object.boolBlock([self userIsInArray:object.user array:friendRequests]);
                            }
                        }];
                    }
                    gettingFriendRequests = NO;
                    requestingObjectsForFriendRequested = nil;
                }
            }];
        }
    }
}

- (void)friendRequests:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    PFQuery *query = [[[PFUser currentUser] relationForKey:@"friendRequests"] query];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:[[[PFUser currentUser] relationForKey:@"friends"] query]];
    [query orderByAscending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            errorBlock(error);
        } else {
            success(objects);
        }
    }];
}

- (void)friendsWithMovieOnWatchlist:(TMDBMovie *)movie success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    if ([friendsWithMovieOnWatchlist objectForKey:movie.tmdbId]) {
        success([friendsWithMovieOnWatchlist objectForKey:movie.tmdbId]);
    } else {
        [self friendsQuery:^(PFQuery *query) {
            PFQuery *movieQuery = [PFQuery queryWithClassName:@"Movie"];
            [movieQuery whereKey:@"tmdbId" equalTo:movie.tmdbId];
            
            [query whereKey:@"movies" matchesQuery:movieQuery];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                if (error) {
                    errorBlock(error);
                } else {
                    [friendsWithMovieOnWatchlist setObject:results forKey:movie.tmdbId];
                    success(results);
                }
            }];
        }];
    }
}

- (void)friendsWithMovieSeen:(TMDBMovie *)movie success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    [self friendsQuery:^(PFQuery *query) {
        PFQuery *movieQuery = [PFQuery queryWithClassName:@"Movie"];
        [movieQuery whereKey:@"tmdbId" equalTo:movie.tmdbId];
        
        [query whereKey:@"seen" matchesQuery:movieQuery];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (error) {
                errorBlock(error);
            } else {
                success(results);
            }
        }];
    }];
}

- (void)friendsQuery:(QueryBlock)success {
    PFQuery *parseFriends = [[[PFUser currentUser] relationForKey:@"friends"] query];
    [parseFriends whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    
    __block PFQuery *facebookQuery;
    __block PFQuery *twitterQuery;
    
    __block BOOL stillGettingFacebook = ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] && [self isFacebookConnected]);
//    __block BOOL stillGettingTwitter = [PFTwitterUtils isLinkedWithUser:[PFUser currentUser]];
    
    SuccessBlock block = ^{
        if (!stillGettingFacebook) {
            if (facebookQuery && twitterQuery) {
                PFQuery *query = [PFQuery orQueryWithSubqueries:@[parseFriends, facebookQuery, twitterQuery]];
                success(query);
            } else if (facebookQuery && !twitterQuery) {
                PFQuery *query = [PFQuery orQueryWithSubqueries:@[parseFriends, facebookQuery]];
                success(query);
            } else if (!facebookQuery && twitterQuery) {
                PFQuery *query = [PFQuery orQueryWithSubqueries:@[parseFriends, twitterQuery]];
                success(query);
            } else {
                success(parseFriends);
            }
        }
    };
    if (!stillGettingFacebook) {
        success(parseFriends);
    }
    if (stillGettingFacebook) {
        [self facebookFriendsParseQuery:^(PFQuery *query) {
            facebookQuery = query;
            stillGettingFacebook = NO;
            block();
        }];
    }
//    if (stillGettingTwitter) {
//        [self twitterParseFriendsQuery:^(PFQuery *query) {
//            twitterQuery = query;
//            stillGettingTwitter = NO;
//            block();
//        }];
//    }
    
    
}

- (void)facebookFriendsParseQuery:(QueryBlock)success {
    if (facebookFriendsIds) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"fbId" containedIn:facebookFriendsIds];
        [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
        success(query);
    } else {
        FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"me/friends?fields=id,name,picture" parameters:nil HTTPMethod:@"GET"];
        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                      NSDictionary* result,
                                                      NSError *error) {
            NSLog(@"finished facebook requiest: %i", (int)[[result objectForKey:@"data"] count]);
            if (error) {
                NSLog(@"error getting facebook friends: %@", error.description);
                success(nil);
            } else {
                NSArray* friends1 = (NSArray*)[result objectForKey:@"data"];
                NSLog(@"success facebook friends");
                
                NSMutableArray *fbIds = [NSMutableArray array];
                for (NSDictionary<FBGraphUser> *user in friends1) {
                    [fbIds addObject:user.objectID];
                }
                facebookFriendsIds = [NSArray arrayWithArray:fbIds];
                PFQuery *facebookFriends = [PFUser query];
                [facebookFriends whereKey:@"fbId" containedIn:facebookFriendsIds];
                [facebookFriends whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
                success(facebookFriends);
            }
            
        }];

    }
}

- (void)twitterParseFriendsQuery:(QueryBlock)success {
    if (twitterFriendIds) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"twitterId" containedIn:twitterFriendIds];
        [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
        success(query);
    } else {
        NSString *endpoint = [NSString stringWithFormat:@"https://api.twitter.com/1.1/friends/ids.json?stringify_ids=true&user_id=%@", [[PFUser currentUser] objectForKey:@"twitterId"]];
        NSError *clientError;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
        
        if (request) {
//            [[PFTwitterUtils twitter] signRequest:request];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if (data) {
                    // handle the response data e.g.
                    NSError *jsonError;
                    NSDictionary *json = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:0
                                          error:&jsonError];
                    twitterFriendIds = [json objectForKey:@"ids"];
                    PFQuery *query = [PFUser query];
                    [query whereKey:@"twitterId" containedIn:twitterFriendIds];
                    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
                    success(query);
                }
                else {
                    NSLog(@"Error: %@", error);
                    success(nil);
                }
            }];
        }
        else {
            NSLog(@"Error: %@", clientError);
            success(nil);
        }
    }
    
}

- (BOOL)userIsInArray:(PFUser *)user array:(NSArray *)array {
    BOOL contains = NO;
    for (PFUser *user2 in array) {
        if ([user.objectId isEqualToString:user2.objectId]) {
            contains = YES;
        }
    }
    return contains;
}

- (BOOL)stringIsInArray:(NSString *)string array:(NSArray *)array {
    BOOL contains = NO;
    for (NSString *str in array) {
        if ([str isEqualToString:string]) {
            contains = YES;
        }
    }
    return contains;
}

- (BOOL)userIsFriendsWithUser:(PFUser *)user {
    BOOL isFriends = NO;
    isFriends = [self userIsInArray:user array:friends];
    if (!isFriends && facebookFriendsIds && [user objectForKey:@"fbId"] && ![user[@"fbId"] isEqualToString:@""]) {
        isFriends = [self stringIsInArray:user[@"fbId"] array:facebookFriendsIds];
    }
    if (!isFriends && twitterFriendIds && [user objectForKey:@"twitterId"] && ![user[@"twitterId"] isEqualToString:@""]) {
        isFriends = [self stringIsInArray:user[@"twitterId"] array:twitterFriendIds];
    }
    return isFriends;
}

- (void)twitterGetNameImage:(NameImageBlock)success error:(ErrorBlock)errorBlock {
    NSString *endpoint = [NSString stringWithFormat:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    NSError *clientError;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
    
    if (request) {
//        [[PFTwitterUtils twitter] signRequest:request];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:0
                                      error:&jsonError];
                NSString *name = [json objectForKey:@"name"];
                NSString *userName = [json objectForKey:@"screen_name"];
                NSString *image = [json objectForKey:@"profile_image_url"];
                success(name, userName, image);
            }
            else {
                NSLog(@"Error: %@", error);
                errorBlock(error);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        errorBlock(nil);
    }

}

#pragma mark - Login

- (void)showLoginOnViewController:(UIViewController *)controller blocks:(PFLoginBlocks *)blocks {
    loginViewController = [[ScreenLogInViewController alloc] init];
    loginViewController.delegate = self;
    loginViewController.signUpController.delegate = self;
    loginBlocks = blocks;
    [controller presentViewController:loginViewController animated:YES completion:nil];
}

#pragma mark - Login Delegates

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [loginViewController dismissViewControllerAnimated:YES completion:nil];
    
    if ([self isFacebookConnected]) {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // Store the current user's Facebook ID on the user
                [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                         forKey:@"fbId"];
                if (![user objectForKey:@"hasExisted"]) {
                    [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"name"];
                    [[PFUser currentUser] setObject:[[result objectForKey:@"name"] lowercaseString] forKey:@"lowercaseName"];
                }
                [user setObject:[NSNumber numberWithBool:YES] forKey:@"hasExisted"];
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
//    if ([PFTwitterUtils isLinkedWithUser:user]) {
////        [user setObject:[PFTwitterUtils twitter].userId forKey:@"twitterId"];
//        [user saveInBackground];
//        [self twitterGetNameImage:^(NSString *name, NSString *userName, NSString *image) {
//            if (![user objectForKey:@"hasExisted"]) {
//                [user setObject:name forKey:@"name"];
//                [user setObject:[name lowercaseString] forKey:@"lowercaseName"];
//                [user setObject:userName forKey:@"username"];
//            }
//            [user setObject:[NSNumber numberWithBool:YES] forKey:@"hasExisted"];
//            [user setObject:image forKey:@"twitterImageUrl"];
//            [user saveInBackground];
//        }error:^(NSError *error) {
//            
//        }];
//    }
    
    if (loginBlocks.didLogInUser) {
        loginBlocks.didLogInUser(user);
    }
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    if (loginBlocks.errorLoggingIn) {
        loginBlocks.errorLoggingIn(error);
    }
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    if (loginBlocks.cancelLogIn) {
        loginBlocks.cancelLogIn();
    }
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [loginViewController.signUpController dismissViewControllerAnimated:NO completion:nil];
    [loginViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (loginBlocks.didSignUpUser) {
        loginBlocks.didSignUpUser(user);
    }
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    if (loginBlocks.errorSigningUp) {
        loginBlocks.errorSigningUp(error);
    }
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    if (loginBlocks.cancelSignUp) {
        loginBlocks.cancelSignUp();
    }
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    NSLog(@"should begin signup name: %@, email: %@, password: %@", signUpController.signUpView.usernameField.text, signUpController.signUpView.passwordField.text, signUpController.signUpView.emailField.text);
    
    PFUser *user = [PFUser user];
    user.username = signUpController.signUpView.passwordField.text;
    user[@"name"] = signUpController.signUpView.usernameField.text;
    user[@"lowercaseName"] = [signUpController.signUpView.usernameField.text lowercaseString];
    user.password = signUpController.signUpView.emailField.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PFSignUpCancelNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:PFSignUpSuccessNotification object:nil];
            [signUpController dismissViewControllerAnimated:NO completion:nil];
            [loginViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    return NO;
}

- (BOOL)isFacebookConnected
{
    return FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended;
}

- (void)logout {
    [PFUser logOut];
    userMovies = nil;
    seenMovies = nil;
    requestedUsers = nil;
    friends = nil;
    friendRequests = nil;
    facebookFriendsIds = nil;
    requestingObjectsForFriendRequested = nil;
    requestingObjectsForFriends = nil;
    requestingObjectsForSentFriendRequest = nil;
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    bgQueue = dispatch_queue_create("bgParseHelper", NULL);
    
    return self;
}

+ (ParseHelper *)sharedInstance {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

#pragma mark - EXPERIMENTAL

- (void)movieReccommendations:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    [self friendsQuery:^(PFQuery *friendsQuery) {
        
        PFQuery *moviesQuery = [self queryForFriendsWatchlistsNotOnMyWatchlist:friendsQuery];
        [moviesQuery findObjectsInBackgroundWithBlock:^(NSArray *movies, NSError *error) {
            if (error) {
                errorBlock(error);
            } else {
                success(movies);
            }
        }];

    }];
}

- (PFQuery *)queryForFriendsWatchlistsNotOnMyWatchlist:(PFQuery *)friendsQuery {
    PFQuery *query = [PFQuery queryWithClassName:@"Movie"];
    [query whereKey:@"users" matchesQuery:friendsQuery];
    
    PFRelation *myMovies = [[PFUser currentUser] relationForKey:@"movies"];
    [query whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:[myMovies query]];

    return query;
}

- (void)friendsWithSimilarRatings:(ArrayBlock) success error:(ErrorBlock)errorBlock {
    
}

@end
