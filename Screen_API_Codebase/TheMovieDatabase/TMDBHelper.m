//
//  TMDBHelper.m
//  Screen
//
//  Created by Mason Wolters on 11/7/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "TMDBHelper.h"
#import <Parse/Parse.h>

@implementation TMDBHelper

const NSString *tmdbApiKey = @"f1bdb4ea74c2a649771b073ccb1bc8fe";
const NSString *tmdbBaseUrl = @"/3";
const NSString *tmdbBaseImgUrl = @"http://image.tmdb.org/t/p/";

@synthesize dateFormatter = _dateFormatter;

#pragma mark - Private

- (NSString *)path:(NSString *)path {
    return [NSString stringWithFormat:@"%@%@", tmdbBaseUrl, path];
}

- (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyy-MM-dd"];
    }
    
    return _dateFormatter;
}

#pragma mark - Public Methods

- (NSURL *)urlForImageResource:(NSString *)image size:(NSString *)size {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", tmdbBaseImgUrl, size, image]];
}

- (void)moviesForSearch:(NSString *)search page:(int)page success:(SearchBlock)success error:(ErrorBlock)errorBlock {
    
    NSDictionary *queryParams = @{
                                  @"api_key": tmdbApiKey,
                                  @"query": [self percentEscapeString:search],
                                  @"page": [NSString stringWithFormat:@"%i", page],
                                  @"search_type": @"ngram"
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/search/movie"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSDictionary *myDic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        success(result.array, [[myDic objectForKey:@"total_pages"] intValue]);
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

- (void)peopleForSearch:(NSString *)search success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    NSDictionary *queryParams = @{
                                    @"api_key": tmdbApiKey,
                                    @"query": [self percentEscapeString:search],
                                    @"page": @"1",
                                    @"search_type": @"ngram"
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/search/person"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        success(result.array);
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

- (void)personForId:(NSString *)personId success:(PersonBlock)success error:(ErrorBlock)errorBlock {
    NSDictionary *queryParams = @{
                                  @"api_key": tmdbApiKey,
                                  @"append_to_response": @"movie_credits"
                                  };
    
    [objectManager getObjectsAtPath:[self path:[NSString stringWithFormat:@"/person/%@", personId]] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if (result.array.count > 0) {
            success(result.array[0]);
        } else {
            errorBlock(nil);
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

- (void)movieIsNowPlaying:(TMDBMovie *)movie success:(BoolBlock)success error:(ErrorBlock)errorBlock {
    if (nowPlayingMovieIds) {
        success([self array:nowPlayingMovieIds containsString:movie.tmdbId]);
    } else {
        [PFCloud callFunctionInBackground:@"nowPlayingMovieIds" withParameters:@{} block:^(NSArray *response, NSError *error) {
            nowPlayingMovieIds = response;
            success([self array:response containsString:movie.tmdbId]);
        }];
    }
}

- (void)movieForId:(NSString *)movieId success:(MovieBlock)success error:(ErrorBlock)errorBlock {
    
//    NSDictionary *queryParams = @{
//                                  @"api_key": tmdbApiKey,
//                                  @"append_to_response": @"trailers,credits"
//                                  };
    
    [objectManager getObjectsAtPath:[self path:[NSString stringWithFormat:@"/movie/%@?api_key=%@&append_to_response=trailers,credits,similar", movieId, tmdbApiKey]] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if (result.array.count > 0) {
            success(result.array[0]);
        } else {
            errorBlock(nil);
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

- (void)movieForImdbId:(NSString *)imdbId success:(MovieBlock)success error:(ErrorBlock)errorBlock {
    
    [objectManager getObjectsAtPath:[self path:[NSString stringWithFormat:@"/find/tt%@?api_key=%@&external_source=imdb_id", imdbId, tmdbApiKey]] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if (result.array.count > 0) {
            TMDBMovie *movie = result.array[0];
            [self movieForId:movie.tmdbId success:^(TMDBMovie *mov) {
                success(mov);
            }error:errorBlock];
        } else {
            errorBlock(nil);
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

- (void)movieForOCMovie:(OCMovie *)oc success:(MovieBlock)success error:(ErrorBlock)errorBlock {
    NSLog(@"title: %@", oc.title);
    NSDictionary *queryParams = @{
                                  @"api_key": tmdbApiKey,
                                  @"query": [self percentEscapeString:[StringNormalizer normalizeString:oc.title]]
//                                  @"year": (oc.releaseYear)?oc.releaseYear:@""
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/search/movie"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if (result.array.count == 1) {
            NSLog(@"1 result");
            success(result.array[0]);
        } else if (result.array.count > 1) {
            NSLog(@"multiple result");
            BOOL didFind = NO;
            for (TMDBMovie *movie in result.array) {
                if (!didFind) {
                    if ([[OnConnectHelper sharedInstance] ocMovie:oc matchesTMDBMovie:movie]) {
                        success(movie);
                        didFind = YES;
                    }
                }
            }
            if (!didFind) errorBlock(nil);
        } else {
            NSLog(@"no results");
            errorBlock(nil);
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];

}

#pragma mark - Date Formatting

- (NSDate *)dateFromString:(NSString *)string {
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [self.dateFormatter dateFromString:string];
}

- (NSString *)formattedDateFromString:(NSString *)string {
    NSDate *date = [self dateFromString:string];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)yearForString:(NSString *)string {
    NSDate *date = [self dateFromString:string];
    [self.dateFormatter setDateFormat:@"yyyy"];
    return [self.dateFormatter stringFromDate:date];
}

- (BOOL)array:(NSArray *)array containsString:(NSString *)string {
    BOOL contains = NO;
    
    for (NSNumber *num in array) {
        if ([[NSString stringWithFormat:@"%i", num.intValue] isEqualToString:string]) {
            contains = YES;
        }
    }
    
    return contains;
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    NSURL *base = [NSURL URLWithString:@"http://api.themoviedb.org"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:base];
    
    objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[TMDBMovie searchMapping] method:RKRequestMethodGET pathPattern:[self path:@"/search/movie"] keyPath:@"results" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *fullMovieDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[TMDBMovie fullMapping] method:RKRequestMethodGET pathPattern:[self path:@"/movie/:id"] keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *findMovieDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[TMDBMovie searchMapping] method:RKRequestMethodGET pathPattern:[self path:@"/find/:id"] keyPath:@"movie_results" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *nowPlayingDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[TMDBMovie searchMapping] method:RKRequestMethodGET pathPattern:[self path:@"/movie/now_playing"] keyPath:@"results" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *searchPeopleDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[TMDBPerson mapping] method:RKRequestMethodGET pathPattern:[self path:@"/search/person"] keyPath:@"results" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *fullPersonDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[TMDBPerson fullMapping] method:RKRequestMethodGET pathPattern:[self path:@"/person/:id"] keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager addResponseDescriptor:fullMovieDescriptor];
    [objectManager addResponseDescriptor:findMovieDescriptor];
    [objectManager addResponseDescriptor:nowPlayingDescriptor];
    [objectManager addResponseDescriptor:searchPeopleDescriptor];
    [objectManager addResponseDescriptor:fullPersonDescriptor];
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/javascript"];
    
    return self;
}

+ (TMDBHelper *)sharedInstance {
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

@end
