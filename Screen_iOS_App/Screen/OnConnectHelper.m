//
//  OnConnectHelper.m
//  Screen
//
//  Created by Mason Wolters on 11/10/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "OnConnectHelper.h"
#import "PFMovie.h"
#import "RKXMLReaderSerialization.h"

@implementation VODAvailability

+ (VODAvailability *)vodAvailabilityWithHost:(NSString *)host link:(NSString *)link {
    VODAvailability *vod = [[VODAvailability alloc] init];
    
    vod.link = link;
    vod.service = [VODAvailability vodForHost:host];
    
    return vod;
}

+ (VOD)vodForHost:(NSString *)host {
    NSDictionary *mappings = @{
                               @"cinemanow": @(vodCinemaNow),
                               @"youtube": @(vodYoutube),
                               @"amazon.com": @(vodAmazon),
                               @"itunes store": @(vodItunes),
                               @"itunes": @(vodItunes),
                               @"vudu": @(vodVudu),
                               @"netflix": @(vodNetflix),
                               @"xfinity": @(vodXfinity),
                               @"fandor": @(vodFandor)
                               };
    if ([mappings objectForKey:[host lowercaseString]]) {
        return (VOD)[[mappings objectForKey:[host lowercaseString]] intValue];
    } else {
        return vodInvalid;
    }
}

@end

@implementation OnConnectHelper

const NSString *onConnectApiKey = @"rtm3db6gfrzt82tyt8pzsteu";

int numberOfDaysShowtimes = 6;

#pragma mark - Private

- (NSString *)path:(NSString *)path {
    return [NSString stringWithFormat:@"/v1%@", path];
}

- (NSString *)socialPath:(NSString *)path {
    return [NSString stringWithFormat:@"/v2%@", path];
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

#pragma mark - Public

- (NSURL *)urlForImageResource:(NSString *)image size:(NSString *)size {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?api_key=%@&%@", @"http://developer.tmsimg.com/", image, onConnectApiKey, size]];
}

- (void)moviesForSearch:(NSString *)search page:(int)page success:(SearchBlock)success error:(ErrorBlock)errorBlock {
    
    NSDictionary *queryParams = @{
                                  @"api_key": onConnectApiKey,
                                  @"q": [self percentEscapeString:search],
                                  @"queryFields": @"title",
                                  @"entityType": @"movie",
                                  @"titleLang": @"en",
                                  @"descriptionLang": @"en",
                                  @"limit": @"50"
                                  };
    
    [objectManager getObjectsAtPath:[self path:@"/programs/search"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSDictionary *myDic = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        success(result.array, [[myDic objectForKey:@"hitCount"] intValue]);
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

- (void)moviesPlayingInRadiusOfCurrentLocation:(float)radius success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    [[LocationHelper sharedInstance] getLocationUserWants:^(CLLocation *location) {
        
        NSDictionary *queryParams = @{
                                      @"api_key": onConnectApiKey,
                                      @"startDate": dateString,
                                      @"lat": [NSString stringWithFormat:@"%f", location.coordinate.latitude],
                                      @"lng": [NSString stringWithFormat:@"%f", location.coordinate.longitude],
                                      @"radius": [NSString stringWithFormat:@"%f", radius],
                                      @"numDays": @"6"
                                      };
        
        [objectManager getObjectsAtPath:[self path:@"/movies/showings"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            
        }failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
        }];
        
    }error:^(NSError *error) {
        
    }];

}

- (void)showtimesInRadiusOfCurrentLocation:(float)radius success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    [[LocationHelper sharedInstance] getLocationUserWants:^(CLLocation *location) {
        if ([self locationMatchesOld:location key:@"showtimes"] && [showtimesForRadius objectForKey:[NSNumber numberWithFloat:radius]]) {
            //don't fetch again
            success([showtimesForRadius objectForKey:[NSNumber numberWithFloat:radius]]);
        } else {
            //fetch
            if (![self locationMatchesOld:location key:@"showtimes"]) {
                showtimesForRadius = [NSMutableDictionary dictionary];
            }
            [lastLocations setObject:location forKey:@"showtimes"];
            
            NSDictionary *queryParams = @{
                                          @"api_key": onConnectApiKey,
                                          @"startDate": dateString,
                                          @"numDays": [NSString stringWithFormat:@"%i", numberOfDaysShowtimes],
                                          @"lat": [NSString stringWithFormat:@"%f", location.coordinate.latitude],
                                          @"lng": [NSString stringWithFormat:@"%f", location.coordinate.longitude],
                                          @"radius": [NSString stringWithFormat:@"%f", radius]
                                          };
            
            [objectManager getObjectsAtPath:[self path:@"/movies/showings"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                //                showtimes = result.array;
                [showtimesForRadius setObject:result.array forKey:[NSNumber numberWithFloat:radius]];
                success(result.array);
            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSLog(@"failed to get showtimes: %@", error.description);
                errorBlock(error);
            }];
        }

    }error:^(NSError *error) {
        errorBlock(error);
        NSLog(@"failed to get location: %@", error.description);
    }];
    
}

- (void)movieIsNowPlaying:(TMDBMovie *)movie success:(BoolBlock)success error:(ErrorBlock)errorBlock {
    [self showTimesForMovie:movie inRadiusOfCurrentLocation:[[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue] success:^(NSArray *showtimes) {
        success(showtimes.count > 0);
    }error:errorBlock];
}

- (void)ocMovieForTMDBMovieInNowPlaying:(TMDBMovie *)movie success:(OCMovieBlock)success error:(ErrorBlock)errorBlock {
    [self showtimesInRadiusOfCurrentLocation:[[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue] success:^(NSArray *showtimes) {
        OCMovie *match = nil;
        for (OCMovie *mov in showtimes) {
            if ([self ocMovie:mov matchesTMDBMovie:movie]) {
                match = mov;
            }
        }
        success(match);
    }error:errorBlock];
}

- (void)showTimesForMovie:(TMDBMovie *)movie inRadiusOfCurrentLocation:(float)radius success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    
    [self showtimesInRadiusOfCurrentLocation:radius success:^(NSArray *results) {
        [self showTimesForMovie:movie ocMovie:nil showtimes:results success:success error:errorBlock];
    }error:errorBlock];

}

- (void)showTimesForOCMovie:(OCMovie *)movie inRadiusOfCurrentLocation:(float)radius success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    
    [self showtimesInRadiusOfCurrentLocation:radius success:^(NSArray *results) {
        [self showTimesForMovie:nil ocMovie:movie showtimes:results success:success error:errorBlock];
    } error:errorBlock];
}

- (void)showTimesForMovie:(TMDBMovie *)movie ocMovie:(OCMovie *)ocMovie showtimes:(NSArray *)showtimes success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    NSMutableDictionary *timesForTheaters = [NSMutableDictionary dictionary];
    NSMutableDictionary *theatersForId = [NSMutableDictionary dictionary];
    
    for (OCMovie *mov in showtimes) {
        if (ocMovie && [mov.rootId isEqualToString:ocMovie.rootId]) {
            for (OCShowtime *showtime in mov.showtimes) {
                Showtime *time = [[Showtime alloc] init];
                time.timeString = showtime.dateTime;
                
                for (int i = 0; i < attributeKeys.count; i++) {
                    for (NSString *key in attributeKeys[i]) {
                        if ([[mov.title lowercaseString] hasSuffix:key]) {
                            time.attribute = attributeTitles[i];
                        }
                    }
                }
                
                if ([timesForTheaters objectForKey:showtime.theater.theaterId]) {
                    [[timesForTheaters objectForKey:showtime.theater.theaterId] addObject:time];
                } else {
                    [timesForTheaters setObject:[NSMutableArray arrayWithObject:time] forKey:showtime.theater.theaterId];
                    [theatersForId setObject:showtime.theater forKey:showtime.theater.theaterId];
                }
            }
        } else if (movie && [self ocMovie:mov matchesTMDBMovie:movie]) {
            for (OCShowtime *showtime in mov.showtimes) {
                Showtime *time = [[Showtime alloc] init];
                time.timeString = showtime.dateTime;
                
                for (int i = 0; i < attributeKeys.count; i++) {
                    for (NSString *key in attributeKeys[i]) {
                        if ([[mov.title lowercaseString] hasSuffix:key]) {
                            time.attribute = attributeTitles[i];
                        }
                    }
                }
                
                if ([timesForTheaters objectForKey:showtime.theater.theaterId]) {
                    [[timesForTheaters objectForKey:showtime.theater.theaterId] addObject:time];
                } else {
                    [timesForTheaters setObject:[NSMutableArray arrayWithObject:time] forKey:showtime.theater.theaterId];
                    [theatersForId setObject:showtime.theater forKey:showtime.theater.theaterId];
                }
            }
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
    
    NSMutableArray *organizedShowtimes = [NSMutableArray array];
    
    for (NSString *key in timesForTheaters) {
        NSMutableArray *times = [timesForTheaters objectForKey:key];
        
        NSMutableDictionary *days = [NSMutableDictionary dictionary];
        for (Showtime *show in times) {
            NSDate *date = [dateFormatter dateFromString:show.timeString];
            show.date = date;
            NSNumber *daysFromNow = [NSNumber numberWithInt:[self daysFromToday:date]];
            
            if (![days objectForKey:daysFromNow]) {
                [days setObject:[NSMutableArray array] forKey:daysFromNow];
            }
            [[days objectForKey:daysFromNow] addObject:show];
        }
        
        OCOrganizedShowtime *st = [[OCOrganizedShowtime alloc] init];
        st.theater = [theatersForId objectForKey:key];
        st.days = days;
        [organizedShowtimes addObject:st];
        
    }
    
    success([NSArray arrayWithArray:organizedShowtimes]);
}

- (BOOL)ocMovie:(OCMovie *)oc matchesTMDBMovie:(TMDBMovie *)tmdb {
    BOOL moviesMatch = YES;
#warning Has prefix will not suffice - just temporary
    if (![[StringNormalizer normalizeString:oc.title] hasPrefix:[StringNormalizer normalizeString:tmdb.title]]) moviesMatch = NO;
    
    if (tmdb.releaseDate && tmdb.releaseDate.length > 3) {
        NSString *movieYear = [tmdb.releaseDate substringToIndex:4];
        if (abs(movieYear.intValue - oc.releaseYear.intValue) > 1) moviesMatch = NO;
    }

    return moviesMatch;
}

- (BOOL)ocMovie:(OCMovie *)oc matchesPFMovie:(PFMovie *)pf {
    BOOL moviesMatch = YES;
#warning Has prefix will not suffice - just temporary
    if (![[StringNormalizer normalizeString:oc.title] hasPrefix:[StringNormalizer normalizeString:pf.title]]) moviesMatch = NO;

    if (pf.releaseDate && pf.releaseDate.length > 3) {
        NSString *movieYear = [pf.releaseDate substringToIndex:4];
        if (abs(movieYear.intValue - oc.releaseYear.intValue) > 1) moviesMatch = NO;
    }
    
    return moviesMatch;
}

- (void)theaterDetailsInRadiusOfCurrentLocation:(float)radius success:(ArrayBlock)success error:(ErrorBlock)errorBlock {

    [[LocationHelper sharedInstance] getLocationUserWants:^(CLLocation *location) {
        
        if ([self locationMatchesOld:location key:@"theaterDetails"] && [theatersForRadius objectForKey:[NSNumber numberWithFloat:radius]]) {
            //don't fetch again
            NSLog(@"USING CACHED THEATER DETAILS");
            success([theatersForRadius objectForKey:[NSNumber numberWithFloat:radius]]);
        } else {
            //fetch
            if (![self locationMatchesOld:location key:@"theaterDetails"]) {
                theatersForRadius = [NSMutableDictionary dictionary];
            }
            [lastLocations setObject:location forKey:@"theaterDetails"];
            
            NSDictionary *queryParams = @{
                                          @"api_key": onConnectApiKey,
                                          @"lat": [NSString stringWithFormat:@"%f", location.coordinate.latitude],
                                          @"lng": [NSString stringWithFormat:@"%f", location.coordinate.longitude],
                                          @"radius": [NSString stringWithFormat:@"%f", radius]
                                          };
            
            [objectManager getObjectsAtPath:[self path:@"/theatres"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                [theatersForRadius setObject:result.array forKey:[NSNumber numberWithFloat:radius]];
                success(result.array);
            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                errorBlock(error);
            }];
        }
        
    }error:^(NSError *error) {
        
    }];
    
//    [[LocationHelper sharedInstance] getCurrentLocation:^(CLLocation *location) {
//        
//        if (lastLocation == location && theaters) {
//            //don't fetch again
//            success(theaters);
//        } else {
//            //fetch
//            lastLocation = location;
//            
//            NSDictionary *queryParams = @{
//                                          @"api_key": onConnectApiKey,
//                                          @"lat": [NSString stringWithFormat:@"%f", location.coordinate.latitude],
//                                          @"lng": [NSString stringWithFormat:@"%f", location.coordinate.longitude],
//                                          @"radius": [NSString stringWithFormat:@"%f", radius]
//                                          };
//            
//            [objectManager getObjectsAtPath:[self path:@"/theatres"] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
//                theaters = result.array;
//                success(theaters);
//            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
//                errorBlock(error);
//            }];
//        }
//        
//    }error:^(NSError *error) {
//        errorBlock(error);
//    }];
    
    

}

- (NSDateFormatter *)showtimesDateFormatter {
    if (!showtimesDateFormatter) {
        showtimesDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [showtimesDateFormatter setLocale:enUSPOSIXLocale];
        [showtimesDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
    }
    
    return showtimesDateFormatter;
}

- (void)showTimesForTheatersNearby:(DictionaryBlock)success error:(ErrorBlock)errorBlock {
    NSLog(@"start showtimes for theaters nearby");
    [self showtimesInRadiusOfCurrentLocation:[[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue] success:^(NSArray *results) {
        NSLog(@"fetched showtimes nearby");
        // NSDictionary - {theaterId: NSDictionary}
            // NSDictionary - {timesForMovieId: NSDictionary, moviesForId: NSDictionary}
                // timesForMovieId: NSDictionary {movieId: NSArray[Showtime]}
                // moviesForId: NSDictionary {normalizedTitle: OCMovie}
        NSMutableDictionary *theaters = [NSMutableDictionary dictionary];
        for (OCMovie *movie in results) {
            for (OCShowtime *showtime in movie.showtimes) {
                if (![theaters objectForKey:showtime.theater.theaterId]) {
                    NSDictionary *theaterDict = @{
                                                  @"timesForMovieId": [NSMutableDictionary dictionary],
                                                  @"moviesForId": [NSMutableDictionary dictionary]
                                                  };
                    [theaters setObject:theaterDict forKey:showtime.theater.theaterId];
                }
                
                NSMutableDictionary *timesForMovieId = [[theaters objectForKey:showtime.theater.theaterId] objectForKey:@"timesForMovieId"];
                NSMutableDictionary *moviesForId = [[theaters objectForKey:showtime.theater.theaterId] objectForKey:@"moviesForId"];
                
                Showtime *show = [[Showtime alloc] init];
                show.timeString = showtime.dateTime;
                
                for (int i = 0; i < attributeKeys.count; i++) {
                    for (NSString *key in attributeKeys[i]) {
                        if ([[movie.title lowercaseString] hasSuffix:key]) {
                            show.attribute = attributeTitles[i];
                        }
                    }
                }
                
                NSString *normalizedTitle = [StringNormalizer normalizeString:movie.title];
                if (![timesForMovieId objectForKey:normalizedTitle]) {
                    [timesForMovieId setObject:[NSMutableArray arrayWithObject:show] forKey:normalizedTitle];
                    [moviesForId setObject:movie forKey:normalizedTitle];
                } else {
                    [[timesForMovieId objectForKey:normalizedTitle] addObject:show];
                }

            }
        }
        
        NSMutableDictionary *showtimesForTheaters = [NSMutableDictionary dictionary];
        for (NSString *theaterId in theaters) {
            NSArray *showtimes = [self organizedShowtimesForTimes:theaters[theaterId][@"timesForMovieId"] movies:theaters[theaterId][@"moviesForId"]];
            [showtimesForTheaters setObject:showtimes forKey:theaterId];
        }
        success(showtimesForTheaters);
        
    }error:errorBlock];
}

- (void)showTimesForTheater:(OCTheater *)theater success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    [self showtimesInRadiusOfCurrentLocation:[[[NSUserDefaults standardUserDefaults] objectForKey:@"theaterRadius"] floatValue] success:^(NSArray *results) {
        
        
        
        NSMutableDictionary *timesForMovieId = [NSMutableDictionary dictionary];
        NSMutableDictionary *moviesForId = [NSMutableDictionary dictionary];
        
        for (OCMovie *movie in results) {
            for (OCShowtime *showtime in movie.showtimes) {
                if ([showtime.theater.theaterId isEqualToString:theater.theaterId]) {
                    Showtime *show = [[Showtime alloc] init];
                    show.timeString = showtime.dateTime;
                    
                    for (int i = 0; i < attributeKeys.count; i++) {
                        for (NSString *key in attributeKeys[i]) {
                            if ([[movie.title lowercaseString] hasSuffix:key]) {
                                show.attribute = attributeTitles[i];
                            }
                        }
                    }
                    
                    NSString *normalizedTitle = [StringNormalizer normalizeString:movie.title];
                    if (![timesForMovieId objectForKey:normalizedTitle]) {
                        [timesForMovieId setObject:[NSMutableArray arrayWithObject:show] forKey:normalizedTitle];
                        [moviesForId setObject:movie forKey:normalizedTitle];
                    } else {
                        [[timesForMovieId objectForKey:normalizedTitle] addObject:show];
                    }
                }
            }
        }
        
        success([self organizedShowtimesForTimes:timesForMovieId movies:moviesForId]);
        
    }error:errorBlock];
}

- (NSArray *)organizedShowtimesForTimes:(NSDictionary *)timesForMovieId movies:(NSDictionary *)moviesForId {
    NSMutableArray *organizedShowtimes = [NSMutableArray array];
    
    for (NSString *key in timesForMovieId) {
        NSMutableArray *times = [timesForMovieId objectForKey:key];
        
        NSMutableDictionary *days = [NSMutableDictionary dictionary];
        for (Showtime *show in times) {
            NSString *time = show.timeString;
            NSDate *date = [[self showtimesDateFormatter] dateFromString:time];
            show.date = date;
            NSNumber *daysFromNow = [NSNumber numberWithInt:[self daysFromToday:date]];
            
            if (![days objectForKey:daysFromNow]) {
                [days setObject:[NSMutableArray array] forKey:daysFromNow];
            }
            [[days objectForKey:daysFromNow] addObject:show];
        }
        
        OCOrganizedShowtime *st = [[OCOrganizedShowtime alloc] init];
        st.movie = moviesForId[key];
        st.days = days;
        [organizedShowtimes addObject:st];
    }

    return organizedShowtimes;
}

- (NSString *)timesStringForTimes:(NSArray *)dates beforeNow:(BOOL)beforeNow {
    NSMutableString *times = [NSMutableString string];
    int i = 0;
    NSMutableArray *correctDates = [NSMutableArray array];
    for (Showtime *show in dates) {
        NSDate *time = show.date;
        if (([time compare:[NSDate date]] == ((beforeNow)?NSOrderedAscending:NSOrderedDescending)) || [time compare:[NSDate date]] == NSOrderedSame) {
            [correctDates addObject:show];
        }
    }
//    for (NSDate *time in dates) {
//        if (([time compare:[NSDate date]] == ((beforeNow)?NSOrderedAscending:NSOrderedDescending)) || [time compare:[NSDate date]] == NSOrderedSame) {
//            [correctDates addObject:time];
//        }
//    }
    
    i = 0;
    for (Showtime *show in correctDates) {
        NSDate *time = show.date;
        i++;
        [times appendString:[[self timeFormatter] stringFromDate:time]];
        if (i != [correctDates count]) {
            [times appendString:@", "];
        }
    }
//    for (NSDate *time in correctDates) {
//        i++;
//        [times appendString:[[self timeFormatter] stringFromDate:time]];
//        if (i != [correctDates count]) {
//            [times appendString:@", "];
//        }
//    }
    return [NSString stringWithString:times];
}

- (NSMutableAttributedString *)attributedStringForTimes:(NSArray *)times beforeColor:(UIColor *)beforeColor afterColor:(UIColor *)afterColor {
    NSMutableArray *noAttribute = [NSMutableArray array];
    NSMutableDictionary *showtimeAttributes = [NSMutableDictionary dictionary];
    
    for (Showtime *show in times) {
        if (show.attribute && ![show.attribute isEqualToString:@""]) {
            if (![showtimeAttributes objectForKey:show.attribute]) {
                [showtimeAttributes setObject:[NSMutableArray array] forKey:show.attribute];
            }
            [[showtimeAttributes objectForKey:show.attribute] addObject:show];
        } else {
            [noAttribute addObject:show];
        }
    }
    
    NSMutableAttributedString *string = [self attributedStringForOneSetOfTimes:noAttribute beforeColor:beforeColor afterColor:afterColor];
    
    UIColor *attributeColor = [UIColor redColor];
    
    for (NSString *key in showtimeAttributes) {
        NSString *newLine = @"";
        if (noAttribute.count != 0) newLine = @"\n";
        NSMutableAttributedString *separator = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ ", newLine, key] attributes:@{NSForegroundColorAttributeName: attributeColor}];
        NSMutableAttributedString *additional = [self attributedStringForOneSetOfTimes:showtimeAttributes[key] beforeColor:beforeColor afterColor:afterColor];
        
        [string appendAttributedString:separator];
        [string appendAttributedString:additional];
    }
    
    return string;
}

- (NSMutableAttributedString *)attributedStringForOneSetOfTimes:(NSArray *)times beforeColor:(UIColor *)beforeColor afterColor:(UIColor *)afterColor {
    NSString *before = [[OnConnectHelper sharedInstance] timesStringForTimes:times beforeNow:YES];
    NSString *after = [[OnConnectHelper sharedInstance] timesStringForTimes:times beforeNow:NO];
    
    NSMutableAttributedString *string;
    if (before.length == 0) {
        string = [[NSMutableAttributedString alloc] initWithString:after];
    } else if (after.length == 0) {
        string = [[NSMutableAttributedString alloc] initWithString:before];
    } else {
        string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@", before, after]];
    }
    [string addAttribute:NSForegroundColorAttributeName value:beforeColor range:NSMakeRange(0, (before.length == 0)?0:(after.length == 0)?before.length:before.length + 1)];
    
    return string;
}

- (NSString *)closestDatePlayingForShowtime:(OCOrganizedShowtime *)showtime {
    for (int i = 0; i < 10; i++) {
        if ([showtime timesDaysAfterToday:i].count != 0) {
            return [NSString stringWithFormat:@"Playing on %@", [[self dateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSinceNow:i*24*60*60]]];
        }
    }
    
    return @"No Showtimes";
}

- (BOOL)date:(NSDate *)date isDaysAwayFromToday:(int)days {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:date];
    
    NSDateComponents *todayComponents = [calendar components:NSCalendarUnitDay fromDate:[NSDate date]];
    
    return components.day - todayComponents.day == days;
}

- (int)daysFromToday:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:[NSDate date] toDate:date options:0];
    
    return (int)difference.day;
}

- (void)voidShowtimes {
    
//    showtimes = nil;
//    theaters = nil;
}

#pragma mark - VOD Availability

- (void)ocMovieForTMDBMovie:(TMDBMovie *)tmdb success:(OCMovieBlock)success error:(ErrorBlock)errorBlock {
    [self moviesForSearch:[StringNormalizer normalizeString:tmdb.title] page:1 success:^(NSArray *results, int totalPages) {
        OCMovie *match = nil;
        for (OCMovie *mov in results) {
            if ([self ocMovie:mov matchesTMDBMovie:tmdb]) {
                match = mov;
            }
        }
        if (match) {
            success(match);
        } else {
            errorBlock(nil);
        }
    }error:errorBlock];
}

- (void)vodAvailabilityForTMDBMovie:(TMDBMovie *)tmdb success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    [self ocMovieForTMDBMovie:tmdb success:^(OCMovie *oc) {
        [self vodAvaiabilityForOCMovie:oc success:success error:errorBlock];
    }error:errorBlock];
}

- (void)vodAvaiabilityForOCMovie:(OCMovie *)oc success:(ArrayBlock)success error:(ErrorBlock)errorBlock {
    NSDictionary *queryParams = @{
                                  @"api_key": onConnectApiKey
                                  };
    
    [socialObjectManager getObjectsAtPath:[self socialPath:[NSString stringWithFormat:@"/movies/%@.xml", oc.rootId]] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if (result.array.count > 0) {
            NSArray *videos = [(OCMovie*)result.array[0] videos];
            
            NSMutableArray *vod = [NSMutableArray array];
            NSMutableDictionary *typesAlready = [NSMutableDictionary dictionary];
            for (OCVideo *vid in videos) {
                NSLog(@"VOD: %@", vid.host);
                if (![typesAlready objectForKey:[NSNumber numberWithInt:[VODAvailability vodForHost:vid.host]]] && [VODAvailability vodForHost:vid.host] != vodInvalid) {
                    [vod addObject:[VODAvailability vodAvailabilityWithHost:vid.host link:vid.url]];
                    [typesAlready setObject:@1 forKey:[NSNumber numberWithInt:[VODAvailability vodForHost:vid.host]]];
                }
            }
            
            if (vod.count == 1 && [vod[0] service] == vodYoutube) {
                [vod removeObjectAtIndex:0];
            }
            
            success([vod sortedArrayUsingComparator:^NSComparisonResult(VODAvailability *a, VODAvailability *b) {
                if (b.service > a.service) {
                    return NSOrderedAscending;
                } else if (b.service < a.service) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }]);
        } else {
            errorBlock(nil);
        }
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock(error);
    }];
}

#pragma mark - Private

- (BOOL)locationMatchesOld:(CLLocation *)location key:(NSString *)key {
    CLLocation *last = [lastLocations objectForKey:key];
    if (last && location.coordinate.latitude == last.coordinate.latitude && location.coordinate.longitude == last.coordinate.longitude) {
        return YES;
    }
    return NO;
}

- (NSDateFormatter *)timeFormatter {
    if (!timeFormatter) {
        timeFormatter = [[NSDateFormatter alloc] init];
        NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        timeFormatter.locale = twelveHourLocale;
        [timeFormatter setDateFormat:@"h:mm"];
    }
    
    return timeFormatter;
}

- (NSDateFormatter *)dateFormatter {
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    return dateFormatter;
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    showtimesForRadius = [NSMutableDictionary dictionary];
    theatersForRadius = [NSMutableDictionary dictionary];
    lastLocations = [NSMutableDictionary dictionary];
    
    attributeKeys = @[@[@"3d"], @[@"imax", @"imax experience"], @[@"imax 3d experience", @"imax 3d"]];
    attributeTitles = @[@"3D", @"IMAX", @"IMAX 3D"];
    
    NSURL *base = [NSURL URLWithString:@"http://data.tmsapi.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:base];
    
    objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKResponseDescriptor *searchDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[OCMovie searchMapping] method:RKRequestMethodGET pathPattern:[self path:@"/programs/search"] keyPath:@"hits" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:searchDescriptor];
    
    RKResponseDescriptor *nowPlayingDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[OCMovie nowPlayingMapping] method:RKRequestMethodGET pathPattern:[self path:@"/movies/showings"] keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:nowPlayingDescriptor];
    
    RKResponseDescriptor *theaterDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[OCTheater searchMapping] method:RKRequestMethodGET pathPattern:[self path:@"/theatres"] keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:theaterDescriptor];
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/javascript"];

    
    
    NSURL *socialBase = [NSURL URLWithString:@"http://feeds.tmsapi.com"];
    AFHTTPClient *socialClient = [[AFHTTPClient alloc] initWithBaseURL:socialBase];
    
    socialObjectManager = [[RKObjectManager alloc] initWithHTTPClient:socialClient];
    
    RKResponseDescriptor *vodDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[OCMovie vodMapping] method:RKRequestMethodGET pathPattern:nil keyPath:@"ovd.movie" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [socialObjectManager addResponseDescriptor:vodDescriptor];
    
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"application/xml"];
    [socialObjectManager setAcceptHeaderWithMIMEType:RKMIMETypeTextXML];
    
    return self;
}

+ (OnConnectHelper *)sharedInstance {
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
