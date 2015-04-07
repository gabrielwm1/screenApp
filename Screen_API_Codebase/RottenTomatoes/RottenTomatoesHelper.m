//
//  RottenTomatoesAPI.m
//  Screen
//
//  Created by Mason Wolters on 11/6/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "RottenTomatoesHelper.h"

@implementation RottenTomatoesHelper

const NSString *apiKey = @"mpkbeqwbsus5zhd4phvdc6zp";
const NSString *baseURL = @"/api/public/v1.0";

#pragma mark - Private

- (NSString *)path:(NSString *)path {
    return [NSString stringWithFormat:@"%@%@", baseURL, path];
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

#pragma mark - Public Methods

- (void)loadMovies:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    
    NSDictionary *queryParams = @{
                                  @"apikey": apiKey,
                                  @"limit": @"10",
                                  @"country": @"us"
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/lists/movies/box_office.json"] parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                                                  success(result.array);
                                              }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  errorBlock(error);
                                                  NSLog(@"rotten tomatoes fail: %@", error);
                                              }];
}

- (void)moviesForSearch:(NSString *)search page:(int)page success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    
    NSDictionary *queryParams = @{
                                  @"apikey": apiKey,
                                  @"page": [NSString stringWithFormat:@"%i", page],
                                  @"q": [self percentEscapeString:search]
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/movies.json"] parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                                                  success(result.array);
                                              }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  errorBlock(error);
                                              }];
    
}

- (void)movieForIMDBId:(NSString *)imdbId success:(RTMovieBlock)success error:(ErrorBlock)errorBlock {
    
    if (!imdbId || [imdbId isEqualToString:@""]) {
        errorBlock(nil);
        return;
    }
    
    NSDictionary *queryParams = @{
                                  @"apikey": apiKey,
                                  @"type": @"imdb",
                                  @"id": imdbId
                                  };
    NSLog(@"movie for imdb id");
    [objectManager getObjectsAtPath:[self path:@"/movie_alias.json"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSLog(@"in success");
        if (result.array.count > 0) {
            success(result.array[0]);
        } else {
            errorBlock(nil);
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"in error");
        errorBlock(error);
    }];
}

- (void)boxOfficeMovies:(ArrayBlock)success errorBlock:(ErrorBlock)errorBlock {
    
    NSDictionary *queryParams = @{
                                  @"apikey": apiKey,
                                  @"limit": @"50",
                                  @"country": @"us"
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/lists/movies/box_office.json"] parameters:queryParams
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                                success(result.array);
                            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                errorBlock(error);
                                NSLog(@"rotten tomatoes fail: %@", error);
                            }];
}

- (void)moviesInTheatersPage:(int)page success:(ArrayAndCountBlock)success errorBlock:(ErrorBlock)errorBlock {
    
    NSDictionary *queryParams = @{
                                  @"apikey": apiKey,
                                  @"page_limit": @"50",
                                  @"page": [NSString stringWithFormat:@"%i", page],
                                  @"country": @"us"
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/lists/movies/in_theaters.json"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSDictionary *myDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        int totalCount = [myDict[@"total"] intValue];
        int totalPages = ceilf((float)totalCount/50.0f);
        success(result.array, totalPages);
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
    
}

- (void)openingMovies:(ArrayBlock)success errorBlock:(ErrorBlock)errorBlock {
    
    NSDictionary *queryParams = @{
                                  @"apikey": apiKey,
                                  @"limit": @"50",
                                  @"country": @"us"
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/lists/movies/opening.json"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        success(result.array);
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    NSURL *base = [NSURL URLWithString:@"http://api.rottentomatoes.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:base];
    
    objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
//    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RTMovie mapping] method:RKRequestMethodGET pathPattern:[self path:@"/lists/movies/box_office.json"] keyPath:@"movies" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *searchDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RTMovie mapping] method:RKRequestMethodGET pathPattern:[self path:@"/movies.json"] keyPath:@"movies" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *boxOfficeDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RTMovie mapping] method:RKRequestMethodGET pathPattern:[self path:@"/lists/movies/box_office.json"] keyPath:@"movies" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *inTheatersDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RTMovie mapping] method:RKRequestMethodGET pathPattern:[self path:@"/lists/movies/in_theaters.json"] keyPath:@"movies" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *openingDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RTMovie mapping] method:RKRequestMethodGET pathPattern:[self path:@"/lists/movies/opening.json"] keyPath:@"movies" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *imdbDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RTMovie mapping] method:RKRequestMethodGET pathPattern:[self path:@"/movie_alias.json"] keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
//    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager addResponseDescriptor:searchDescriptor];
    [objectManager addResponseDescriptor:boxOfficeDescriptor];
    [objectManager addResponseDescriptor:inTheatersDescriptor];
    [objectManager addResponseDescriptor:openingDescriptor];
    [objectManager addResponseDescriptor:imdbDescriptor];
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/javascript"];
    
    return self;
}

+ (RottenTomatoesHelper *)sharedInstance {
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
