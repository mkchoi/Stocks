//
//  KCDBUtility.h
//  Stocks
//
//  Created by Kevin Choi on 09/03/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface KCDBUtility : NSObject

+(KCDBUtility *) newInstance;
-(void) openDB;
-(void) createDB;
-(NSMutableArray *) resultSQL:(NSString *) sql;
/*
-(sqlite3_stmt *) querySQL:(NSString *) sql;
-(void) finalizeStatement:(sqlite3_stmt *) statement;
*/
-(BOOL) executeSQL:(NSString *) sql;
-(void) closeDB;
-(BOOL) clearDB;
-(BOOL) dropDB;
-(BOOL) alterTable:(NSString *)sql withSQLNum:(int)number;

@end
