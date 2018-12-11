//
//  KCAppDelegate.m
//  Stocks
//
//  Created by Kevin Choi on 31/10/13.
//  Copyright (c) 2013 Kevin Choi. All rights reserved.
//

#import "KCAppDelegate.h"
#import "KCDBUtility.h"
#import "KCUtility.h"
#import "KCEnvVar.h"

@implementation KCAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor whiteColor];
    //[self.window makeKeyAndVisible];
    
    // initial data
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectSql = [NSString stringWithFormat:@"select count(*) from user_table"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        if ([[columns valueForKey:@"0"] intValue] == 0) {
            NSString *insertSql = [NSString stringWithFormat:@"insert into user_table (name, share, add_trading_fee, green_as_rise, create_time) values ('%@', '%@', '%@', '%@', '%@')", @"ANONYMOUS", @"NO", @"YES", @"YES", [KCUtility getTodayStr]];
            
            [dbUtility executeSQL:insertSql];
        }
    }
    
    selectSql = [NSString stringWithFormat:@"select count(*) from portfolio_table"];
    
    result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        if ([[columns valueForKey:@"0"] intValue] == 0) {
            NSString *insertSql = [NSString stringWithFormat:@"insert into portfolio_table (name, share, create_time) values ('%@', '%@', '%@')", @"My Portfolio", @"NO", [KCUtility getTodayStr]];
            
            [dbUtility executeSQL:insertSql];
        }
    }

    selectSql = [NSString stringWithFormat:@"select count(*) from user_portfolio_table"];
    
    result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        if ([[columns valueForKey:@"0"] intValue] == 0) {
            NSString *insertSql = [NSString stringWithFormat:@"insert into user_portfolio_table (user_id, portfolio_id, create_time) values (%d, %d, '%@')", 1, 1, [KCUtility getTodayStr]];
            
            [dbUtility executeSQL:insertSql];        }
    }
    
    
    selectSql = [NSString stringWithFormat:@"select count(*) from cost_table"];
    
    result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        if ([[columns valueForKey:@"0"] intValue] == 0) {
            NSString *insertSql = [NSString stringWithFormat:@"insert into cost_table (tran_cost, tax, commission, min_charge) values (%g, %g, %g, %g)", 0.0, 0.0, 0.0, 0.0];
            
            [dbUtility executeSQL:insertSql];
        }
    }
    
    
    KCEnvVar *obj = [KCEnvVar getInstance];
    
    NSString *selectSql2 = [NSString stringWithFormat:@"select name, email, share from user_table where id=1"];
    
    NSMutableArray *result2 = [dbUtility resultSQL:selectSql2];
    for (int i=0; i<[result2 count]; i++) {
        NSMutableDictionary *columns2 = (NSMutableDictionary *)[result2 objectAtIndex:i];
        obj.userName = [columns2 valueForKey:@"0"];
        obj.userEmail = [columns2 valueForKey:@"1"];
        obj.syncWithServer = [columns2 valueForKey:@"2"];
    }
    
    NSString *selectSql3 = [NSString stringWithFormat:@"select share from portfolio_table where id=1"];
    
    NSMutableArray *result3 = [dbUtility resultSQL:selectSql3];
    for (int i=0; i<[result3 count]; i++) {
        NSMutableDictionary *columns3 = (NSMutableDictionary *)[result3 objectAtIndex:i];
        obj.sharePortfolio = [columns3 valueForKey:@"0"];
    }

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Stocks" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Stocks.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
