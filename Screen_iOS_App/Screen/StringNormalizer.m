//
//  StringNormalizer.m
//  Screen
//
//  Created by Mason Wolters on 12/4/14.
//  Copyright (c) 2014 Big Head Applications. All rights reserved.
//

#import "StringNormalizer.h"

//string NumberToText( int n)
//{
//    if ( n < 0 )
//        return "Minus " + NumberToText(-n);
//    else if ( n == 0 )
//        return "";
//    else if ( n <= 19 )
//        return new string[] {"One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight",
//            "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
//            "Seventeen", "Eighteen", "Nineteen"}[n-1] + " ";
//    else if ( n <= 99 )
//        return new string[] {"Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy",
//            "Eighty", "Ninety"}[n / 10 - 2] + " " + NumberToText(n % 10);
//    else if ( n <= 199 )
//        return "One Hundred " + NumberToText(n % 100);
//    else if ( n <= 999 )
//        return NumberToText(n / 100) + "Hundreds " + NumberToText(n % 100);
//    else if ( n <= 1999 )
//        return "One Thousand " + NumberToText(n % 1000);
//    else if ( n <= 999999 )
//        return NumberToText(n / 1000) + "Thousands " + NumberToText(n % 1000);
//    else if ( n <= 1999999 )
//        return "One Million " + NumberToText(n % 1000000);
//    else if ( n <= 999999999)
//        return NumberToText(n / 1000000) + "Millions " + NumberToText(n % 1000000);
//    else if ( n <= 1999999999 )
//        return "One Billion " + NumberToText(n % 1000000000);
//    else
//        return NumberToText(n / 1000000000) + "Billions " + NumberToText(n % 1000000000);
//}

@implementation StringNormalizer

+ (NSString *)normalizeString:(NSString *)original {
    NSString *string = [NSString stringWithString:original];
   
// 1   Remove leading and trailing whitespace.
    string = [StringNormalizer removeLeadingTrailingWhitespace:string];
    
// 2   Uppercase the entire string.
    string = [StringNormalizer uppercaseString:string];
    
// 3   Move any of the following articles to the front of the string from the end : {,_A|,_AN|,_THE}. (Note: Only one occurence is checked) Exe. Dark Knight, the becomes the dark knight.
    string = [StringNormalizer moveFromEndToBeginningOnce:@[@", A", @", AN", @", THE"] string:string];
    
// 4   Remove any of the following leading articles, {,_A|,_AN|,_THE} Exe. The Dark Knight becomes Dark Knight
    string = [StringNormalizer replace:@[@", A", @", AN", @", THE"] with:@"" string:string];
    
// 5   Lowercase the entire string
    string = [StringNormalizer lowercaseString:string];
    
// 6   For each of the following pairs:If
//      The string contains both parts of the pair and
//      The last occurrence of the left pair comes before the last occurrence of the right pair then
//      Return the base string starting from leftmost character and ending one character from last occurrence of leftmost pair.
//      The pairs are, 1. [ ] 2.( ) 3.{ } Exe. Hi[5][6] returns Hi[5]
//      Exe. Hello[] returns Hello
    
// 7   Append a space in front and back of the word to account for trimming.
    string = [string stringByAppendingString:@" "];
    string = [NSString stringWithFormat:@" %@", string];
    
// 8       Remove the following phrases from the string,
//    {_an_imax_3d_experience_| _an_imax_experience_ | _the_imax_experience_|_imax_3d_experience_|_imax_3d_}
    string = [StringNormalizer replace:@[@" an imax 3d experience ", @" an imax experience ", @" the imax experience ", @" imax 3d experience ", @" imax 3d "] with:@"" string:string];
    
// 8.5  Remove the following,
//     {_3d}
    string = [StringNormalizer replace:@[@" 3d"] with:@"" string:string];
    
// 9   Replace character & with string and.
    string = [StringNormalizer replace:@[@"&"] with:@"and" string:string];
    
// 10   Remove leading and trailing whitespace.
    string = [StringNormalizer removeLeadingTrailingWhitespace:string];
    
// 11  Uppercase the string.
    string = [StringNormalizer uppercaseString:string];
    
// 12   Repeat Step 3
//    Move any of the following articles to the front of the string from the end : {,_A|,_AN|,_THE}. (Note: Only one occurence is checked) Exe. Dark Knight, the becomes the dark knight.
    string = [StringNormalizer moveFromEndToBeginningOnce:@[@", A", @", AN", @", THE"] string:string];
    
// 13   Repeat step 4
//    Remove any of the following leading articles, {,_A|,_AN|,_THE} Exe. The Dark Knight becomes Dark Knight
    string = [StringNormalizer replace:@[@", A", @", AN", @", THE"] with:@"" string:string];
    
// 14   LowerCase the string.
    string = [StringNormalizer lowercaseString:string];
    
// 15   Replace any occurence of the following strings
//    {_i:|_ii:|_iii:|_iv:|_v:|_vi|_vii:|_viii|_ix:|_x:|_xi:|_xii:|} with their equivalent counterparts
//    {_1:|_2:|_3:|_4:|_5:|_6:|_7:|_8:|_9:|_10:|_11:|_12:|}
    string = [StringNormalizer replaceWithCounterpart:@[@" i:", @" ii:", @" iii:", @" iv:", @" v:", @" vi:", @" vii:", @" viii:", @" ix:", @" x:", @" xi:", @" xii:"]
                                counterparts:@[@" 1:", @" 2:", @" 3:", @" 4:", @" 5:", @" 6:", @" 7:", @" 8:", @" 9:", @" 10:", @" 11:", @" 12:"] string:string];
    
// 16   Using the following list of characters,
//    { !| @| #| $| %| ^| *| _| +| =| ‘{‘| ‘}’| [| ]| ‘|’ | <| >| `| :| -| (| )| ?| /| \| & | ~| .| ,|single quote|double quote } **NOTE**: single quote means ‘ and double quote means ” respectively.
//    Replace any occurence of the above characters with a blank space, exe. A string, Blink_182 becomes Blink 182
    string = [StringNormalizer replace:@[@"!", @"@", @"#", @"$", @"%", @"^", @"*", @"_", @"+", @"=", @"{", @"}", @"[", @"]", @"|", @"<", @">", @"`", @":", @"-", @"(", @")", @"?", @"/", @"\\", @"&", @"~", @".", @",", @"'", @"\""] with:@" " string:string];
    
// 17   Replace any numeric text to its string equivalent. For example, 1000 changes to One_Thousand ,
//    6010 turns into Six_Thousand_Ten . Link to equivalent article,http://stackoverflow.com/questions/794663/net-convert-number-to-string-representation-1-to-one-2-to-two-etc
    string = [StringNormalizer changeNumericToString:string];
    
// 18   LowerCase the entire string.
    string = [StringNormalizer lowercaseString:string];
    
// 19   Remove leading and trailing whitespace.
    string = [StringNormalizer removeLeadingTrailingWhitespace:string];
    
// 20   Replace any occurence of the following string, {,} (comma) to a empty space. Exe. Hello, John becomes Hello John
    string = [StringNormalizer replace:@[@","] with:@" " string:string];
    
// 21   If your string ends with the following strings
//    {_i|_ii|_iii|_iv|_v|_vi|_vii|_viii|_ix|_x|_xi|_xii|}, replace them with their equivalent counterparts
//    {_1|_2|_3|_4|_5|_6|_7|_8|_9|_10|_11|_12|}
    string = [StringNormalizer replaceAtEnd:@[@" i", @" ii", @" iii", @" iv", @" v", @" vi", @" vii", @" viii", @" ix", @" x", @" xi", @" xii"]
                  withCounterparts:@[@" 1", @" 2", @" 3", @" 4", @" 5", @" 6", @" 7", @" 8", @" 9", @" 10", @" 11", @" 12"] string:string];
    
// 22   Repeat step 17
    string = [StringNormalizer changeNumericToString:string];
    
// 23   Lowercase the string
    string = [StringNormalizer lowercaseString:string];
    
// 24   Replace Diacritics from the string with their correct counterpart. For example, strings such as é, è, ë, ê, É would all be replaced with e,e,e,e,E respectively.
    string = [StringNormalizer replaceDiacritics:string];
    
// 25   Remove leading and trailing whitespace.
    string = [StringNormalizer removeLeadingTrailingWhitespace:string];
    
// 26   Remove the following occurences from the string, between any two characters remove any number of blank spaces and keep just one. For example, two____times will be replaced with two_times.
    string = [StringNormalizer replace:@[@"    ", @"   ", @"  ", @" "] with:@" " string:string];
    
    return string;
}

+ (NSString *)removeLeadingTrailingWhitespace:(NSString *)string {
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return string;
}

+ (NSString *)lowercaseString:(NSString *)string {
    string = [string lowercaseString];
    return string;
}

+ (NSString *)uppercaseString:(NSString *)string {
    string = [string uppercaseString];
    return string;
}

+ (NSString *)replace:(NSArray *)replace with:(NSString *)rep string:(NSString *)string {
    for (NSString *str in replace) {
        string = [string stringByReplacingOccurrencesOfString:str withString:rep];
    }
    return string;
}

+ (NSString *)replaceWithCounterpart:(NSArray *)replace counterparts:(NSArray *)counterparts string:(NSString *)string {
    int i = 0;
    for (NSString *str in replace) {
        string = [string stringByReplacingOccurrencesOfString:str withString:counterparts[i]];
        i++;
    }
    return string;
}

+ (NSString *)changeNumericToString:(NSString *)string {
    
    return string;
}

+ (NSString *)replaceDiacritics:(NSString *)string {
    string = [string stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    return string;
}

+ (NSString *)moveFromEndToBeginningOnce:(NSArray *)move string:(NSString *)string {
    BOOL alreadyDid = NO;
    
    for (NSString *str in move) {
        if (!alreadyDid) {
            if ([string hasSuffix:str]) {
                string = [string substringToIndex:string.length - str.length];
                string = [NSString stringWithFormat:@"%@ %@", str, string];
                //Might need a -1
                alreadyDid = YES;
            }
        }
    }
    return string;
}

+ (NSString *)replaceAtEnd:(NSArray *)replace withCounterparts:(NSArray *)counterparts string:(NSString *)string {
    
    return string;
}



@end
