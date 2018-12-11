//
//  KCUtility.m
//  Stocks
//
//  Created by Kevin Choi on 09/03/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCUtility.h"

@implementation KCUtility

+ (int)getCurrentDay
{
    int currentSec = [[NSDate date] timeIntervalSince1970];
    return currentSec / (60 * 60 * 24);
}

+ (NSString *)getTodayStr
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    return dateString;
}

+ (NSString *) getEscapedString:(NSString *)originalString
{
    NSString *escaped = [originalString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    return escaped;
}

@end
