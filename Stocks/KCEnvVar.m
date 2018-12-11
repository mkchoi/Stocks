//
//  KCEnvVar.m
//  Stocks
//
//  Created by Kevin Choi on 16/2/15.
//  Copyright (c) 2015 Kevin Choi. All rights reserved.
//

#import "KCEnvVar.h"

#define APP_VERSION @"1.0"

@implementation KCEnvVar

static KCEnvVar *instance = nil;

+(KCEnvVar *)getInstance
{
    if (instance != nil)
    {
        return instance;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        instance = [[KCEnvVar alloc] init];
        instance.appVersion = APP_VERSION;
    });
    
    return instance;
}



@end
