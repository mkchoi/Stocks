//
//  KCAppDelegate.h
//  Stocks
//
//  Created by Kevin Choi on 31/10/13.
//  Copyright (c) 2013 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
