//
//  PFMovie.m
//  Screen
//
//  Created by Mason Wolters on 11/9/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "PFMovie.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFMovie

@dynamic adult;
@dynamic backdropPath;
@dynamic tmdbId;
@dynamic originalTitle;
@dynamic releaseDate;
@dynamic posterPath;
@dynamic popularity;
@dynamic title;
@dynamic voteAverage;
@dynamic voteCount;
@dynamic budget;
@dynamic genres;
@dynamic homepage;
@dynamic imdbId;
@dynamic overview;
@dynamic productionCompanies;
@dynamic productionCountries;
@dynamic revenue;
@dynamic runtime;
@dynamic spokenLanguages;
@dynamic status;
@dynamic tagline;
@dynamic youtubeTrailers;
@dynamic cast;
@dynamic crew;
@dynamic userCount;
@dynamic rottenTomatoesScore;

+ (NSString *)parseClassName {
    return @"Movie";
}

+ (void)load {
    [self registerSubclass];
}

- (id)officialTrailer {
    return nil;
}

- (NSString *)displayTitle {
    if (self.originalTitle && ![self.originalTitle isEqualToString:self.title]) {
        return [NSString stringWithFormat:@"%@ (%@)", self.title, self.originalTitle];
    } else {
        return self.title;
    }
}

@end
