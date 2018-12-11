//
//  KCDBUtility.m
//  Stocks
//
//  Created by Kevin Choi on 09/03/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCDBUtility.h"
#import "KCUtility.h"

@interface KCDBUtility()


@end

static KCDBUtility *instance;

static NSString *dbName = @"stocks";
static NSString *dbContent =@"Initial DB";
static int dbVersion = 10;
static sqlite3 *database;

static NSString *createDbVerTable = {
    @"CREATE TABLE IF NOT EXISTS dbver_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"content TEXT, "
    @"dbver INTEGER, "
    @"alter_num INTEGER DEFAULT 0, "
    @"create_time DATETIME)"
};

static NSString *createPortfolioTable = {
    @"CREATE TABLE IF NOT EXISTS portfolio_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"name TEXT, "
    @"share TEXT, "
    @"create_time DATETIME)"
};

static NSString *createUserTable = {
    @"CREATE TABLE IF NOT EXISTS user_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"name TEXT, "
    @"photo TEXT, "
    @"type TEXT, "
    @"email TEXT, "
    @"share TEXT, "
    @"add_trading_fee TEXT, "
    @"green_as_rise TEXT, "
    @"create_time DATETIME)"
};

static NSString *createUserPortfolioTable = {
    @"CREATE TABLE IF NOT EXISTS user_portfolio_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"user_id INTEGER, "
    @"portfolio_id INTEGER, "
    @"create_time DATETIME)"
};

static NSString *createPortfolioDetailTable = {
    @"CREATE TABLE IF NOT EXISTS portfolio_detail_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"sequence INTEGER, "
    @"stock_sym TEXT, "
    @"stock_name TEXT, "
    @"market_code TEXT, "
    @"action TEXT, "
    @"action_price REAL, "
    @"action_qty INTEGER, "
    @"action_time DATETIME, "
    @"trading_fee REAL, "
    @"portfolio_id INTEGER)"
};

static NSString *createCostTable = {
    @"CREATE TABLE IF NOT EXISTS cost_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"tran_cost REAL, "
    @"tax REAL, "
    @"commission REAL, "
    @"min_charge REAL)"
};

static NSString *createStockExchangeTable = {
    @"CREATE TABLE IF NOT EXISTS stock_exchange_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"market TEXT, "
    @"area TEXT, "
    @"code TEXT)"
};

static NSString *createProfitLossTable = {
    @"CREATE TABLE IF NOT EXISTS profit_loss_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"user_id INTEGER, "
    @"portfolio_id INTEGER, "
    @"amount REAL, "
    @"status TEXT, "
    @"update_time DATETIME)"
};

static NSString *createUploadTable = {
    @"CREATE TABLE IF NOT EXISTS upload_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"table_name TEXT, "
    @"row_id INTEGER, "
    @"retry INTEGER DEFAULT 0, "
    @"create_time DATETIME)"
};

static NSString *createForumTopicTable = {
    @"CREATE TABLE IF NOT EXISTS forum_topic_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"topic_name TEXT, "
    @"user_email TEXT, "
    @"create_time DATETIME)"
};

static NSString *createForumMessageTable = {
    @"CREATE TABLE IF NOT EXISTS forum_message_table "
    @"(id INTEGER PRIMARY KEY AUTOINCREMENT, "
    @"topic_id INTEGER, "
    @"message TEXT, "
    @"user_email TEXT, "
    @"create_time DATETIME)"
};


static NSString *deleteDbVerTable = @"delete from dbver_table";
static NSString *deletePortfolioTable = @"delete from portfolio_table";
static NSString *deleteUserTable = @"delete from user_table";
static NSString *deleteUserPortfolioTable = @"delete from user_portfolio_table";
static NSString *deletePortfolioDetailTable = @"delete from portfolio_detail_table";
static NSString *deleteCostTable = @"delete from cost_table";
static NSString *deleteStockExchangeTable = @"delete from stock_exchange_table";
static NSString *deleteProfitLossTable = @"delete from profit_loss_table";
static NSString *deleteUploadTable = @"delete from upload_table";
static NSString *deleteForumTopicTable = @"delete from forum_topic_table";
static NSString *deleteForumMessageTable = @"delete from forum_message_table";

static NSString *dropDbVerTable = @"drop table dbver_table";
static NSString *dropPortfolioTable = @"drop table portfolio_table";
static NSString *dropUserTable = @"drop table user_table";
static NSString *dropUserPortfolioTable = @"drop table user_portfolio_table";
static NSString *dropPortfolioDetailTable = @"drop table portfolio_detail_table";
static NSString *dropCostTable = @"drop table cost_table";
static NSString *dropStockExchangeTable = @"drop table stock_exchange_table";
static NSString *dropProfitLossTable = @"drop table profit_loss_table";
static NSString *dropUploadTable = @"drop table upload_table";
static NSString *dropForumTopicTable = @"drop table forum_topic_table";
static NSString *dropForumMessageTable = @"drop table forum_message_table";

@implementation KCDBUtility

+(KCDBUtility *) newInstance {
    
    if (instance == nil) {
        instance = [[KCDBUtility alloc] init];
        [instance openDB];
        //[instance dropDB];
        [instance createDB];
        [instance upgradeDB];
        //[instance alterTable:alterSQL1 withSQLNum:1];
        //[instance alterTable:alterSQL2 withSQLNum:2];
        //[instance alterTable:alterSQL3 withSQLNum:3];
    }
    
    return instance;
}

-(void) openDB {
    
    
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:dbName];
    
    NSLog(@"%s", [databaseFilePath UTF8String]);
    
    if (sqlite3_open([databaseFilePath UTF8String], &database)==SQLITE_OK) {
        NSLog(@"open sqlite db ok");
        
    }
    
}

-(void) createDB {
    
    @synchronized(self) {
    
        char *errorMsg;
        if (sqlite3_exec(database, [createDbVerTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [createPortfolioTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [createUserTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [createUserPortfolioTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [createPortfolioDetailTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [createCostTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [createStockExchangeTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [createProfitLossTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [createUploadTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [createForumTopicTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [createForumMessageTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
            
            NSLog(@"create tables OK");
            
            NSString *query = @"select count(*) from dbver_table";
            sqlite3_stmt *statement;
            int errCode = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
            
            if (errCode == SQLITE_OK) {
                if (sqlite3_step(statement) == SQLITE_ROW) {
                    int count = sqlite3_column_int(statement, 0);
                    
                    if (count == 0) {
                        NSString *sql = [NSString stringWithFormat: @"insert into dbver_table (content, dbver, create_time) values ('%@', '%d', '%@')", dbContent, dbVersion, [KCUtility getTodayStr]];
                        
                        char *errorMsg;
                        
                        if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
                            NSLog(@"insert dbver ok");
                        } else {
                            NSLog(@"cannot insert dbver - %@", [NSString stringWithUTF8String:errorMsg]);
                            //sqlite3_free(errorMsg);
                            [self closeDB];
                        }
                        
                    }
                }
            }
            
            sqlite3_finalize(statement);
            
        } else {
            NSLog(@"error: %s",errorMsg);
            //sqlite3_free(errorMsg);
            //[self closeDB];
        }
    }
    
    NSLog(@"createDB end");
    
}

-(void) upgradeDB {
    
    int dbVer = 0;
    
    @synchronized(self) {
        
        NSString *query = @"select dbver from dbver_table";
        sqlite3_stmt *statement;
        int errCode = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if (errCode==SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                dbVer = sqlite3_column_int(statement, 0);
            }
        }
        sqlite3_finalize(statement);
    }
    
    if (dbVer < dbVersion) {
        [self dropDB];
        [self createDB];
        
    }
    
}

-(NSMutableArray *) resultSQL:(NSString *) sql {
    
    NSMutableArray *resultSet = [[NSMutableArray alloc] init];
    
    @synchronized(self) {
        
        sqlite3_stmt *statement;
        
        NSLog(@"%s", [sql UTF8String]);
        
        int errCode = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
        
        if (errCode == SQLITE_OK) {
            NSLog(@"select ok");
            
            int colCount = sqlite3_column_count(statement);
            
            //NSLog(@"column count=%d", colCount);
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSMutableDictionary *eachRow = [[NSMutableDictionary alloc] init];
                
                for (int i=0; i<colCount; i++) {
                    int colType = sqlite3_column_type(statement, i);
                    
                    if (colType == SQLITE_TEXT) {
                        //NSLog(@"column %d=TEXT", i);
                        
                        char *strValue = (char *)sqlite3_column_text(statement, i);
                        if (strValue != nil) {
                            [eachRow setObject:[NSString stringWithUTF8String:strValue] forKey:[NSString stringWithFormat:@"%d", i]];
                        } else {
                            [eachRow setObject:@"" forKey:[NSString stringWithFormat:@"%d", i]];
                        }
                        
                    } else if (colType == SQLITE_INTEGER) {
                        //NSLog(@"column %d=INTEGER", i);
                        
                        int intValue = sqlite3_column_int(statement, i);
                        
                        [eachRow setObject:[NSString stringWithFormat:@"%d", intValue] forKey:[NSString stringWithFormat:@"%d", i]];
                        
                    } else if (colType == SQLITE_FLOAT) {
                        //NSLog(@"column %d=FLOAT", i);
                        
                        double doubleValue = sqlite3_column_double(statement, i);
                        
                        [eachRow setObject:[NSString stringWithFormat:@"%g", doubleValue] forKey:[NSString stringWithFormat:@"%d", i]];
                        
                    }

                }
                
                [resultSet addObject:eachRow];
                
            }
            
            
        } else {
            NSLog(@"%d, %s", errCode, sqlite3_errmsg(database));
        }
        
        sqlite3_finalize(statement);
    }
    
    return resultSet;
}


-(BOOL) executeSQL:(NSString *) sql {
 
    BOOL ok = FALSE;
    
    NSLog(@"%s", [sql UTF8String]);
    
    @synchronized(self) {
        char *errorMsg;
        
        if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
            NSLog(@"execute ok");
            
            ok = TRUE;
            
        } else {
            NSLog(@"%@", [NSString stringWithUTF8String:errorMsg]);
            
            ok = FALSE;
        }

    }
    
    return ok;
    
}


-(void) closeDB {
    
    sqlite3_close(database);
    instance = nil;
    
}

-(BOOL) clearDB {
    
    BOOL ok = FALSE;
    
    @synchronized(self) {
        char *errorMsg;
        
        if (sqlite3_exec(database, [deletePortfolioTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [deleteUserTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [deleteUserPortfolioTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [deletePortfolioDetailTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [deleteCostTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [deleteStockExchangeTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [deleteProfitLossTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [deleteUploadTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [deleteForumTopicTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [deleteForumMessageTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
            
            NSLog(@"clear tables ok");
            
            ok = TRUE;
            
        } else {
            NSLog(@"%@", [NSString stringWithUTF8String:errorMsg]);
            
            ok = FALSE;
        }
    }
    
    return ok;
    
}

-(BOOL) dropDB {
    
    BOOL ok = FALSE;
    
    @synchronized(self) {
        char *errorMsg;
        
        if (sqlite3_exec(database, [dropDbVerTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [dropPortfolioTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [dropUserTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [dropUserPortfolioTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [dropPortfolioDetailTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [dropCostTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [dropStockExchangeTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [dropProfitLossTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [dropUploadTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [dropForumTopicTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK
            && sqlite3_exec(database, [dropForumMessageTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
            
            NSLog(@"drop tables ok");
            
            
            ok = TRUE;
            
        } else {
            NSLog(@"%@", [NSString stringWithUTF8String:errorMsg]);
            
            
            ok = FALSE;
        }

    }
    
    return ok;
    
}

-(BOOL) alterTable:(NSString *)sql withSQLNum:(int)number
{
    BOOL ok = FALSE;
    
    @synchronized(self) {
    
        int alterNum = 0;
        NSString *query = @"select alter_num from dbver_table";
        sqlite3_stmt *statement;
        int errCode = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if (errCode == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                alterNum = sqlite3_column_int(statement, 0);
            }
        }
        sqlite3_finalize(statement);
        
        char *errorMsg;
        NSString *updateSQL = [NSString stringWithFormat:@"update dbver_table set alter_num=%d", number];
        
        if (alterNum < number) {
            if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
                NSLog(@"%@ OK", sql);
                
                if (sqlite3_exec(database, [updateSQL UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
                    NSLog(@"update alter_num ok");
                    
                    ok = TRUE;
                    
                } else {
                    NSLog(@"alterTable: %@", [NSString stringWithUTF8String:errorMsg]);
                    
                    ok = FALSE;
                }
            } else {
                NSLog(@"alterTable: %@", [NSString stringWithUTF8String:errorMsg]);
                
                ok = FALSE;
            }
        } else {
            
            ok = TRUE;
        }
        
    }
    
    return ok;
}

@end
