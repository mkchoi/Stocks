//
//  KCHistoryTableViewController.h
//  Stocks
//
//  Created by Kevin Choi on 6/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KCStock.h"

@interface KCHistoryTableViewController : UITableViewController

@property NSString *year;
@property NSString *month;
@property KCStock *selectedAction;

@end
