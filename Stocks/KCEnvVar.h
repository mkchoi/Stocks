//
//  KCEnvVar.h
//  Stocks
//
//  Created by Kevin Choi on 16/2/15.
//  Copyright (c) 2015 Kevin Choi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCEnvVar : NSObject

@property NSString *appVersion;

@property NSString *deviceId;
@property long *userId;

@property NSString *userName;
@property NSString *userEmail;
@property NSString *syncWithServer;
@property NSString *sharePortfolio;

+(KCEnvVar*)getInstance;

@end
