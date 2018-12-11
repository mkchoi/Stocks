//
//  KCUtility.h
//  Stocks
//
//  Created by Kevin Choi on 09/03/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface KCUtility : NSObject

+ (int)getCurrentDay;
+ (NSString *)getTodayStr;
+ (NSString *) getEscapedString:(NSString *)originalString;

@end
