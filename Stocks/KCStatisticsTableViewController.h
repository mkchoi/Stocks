//
//  KCStatisticsTableViewController.h
//  Stocks
//
//  Created by Kevin Choi on 12/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KCStock.h"

@interface KCStatisticsTableViewController : UITableViewController

@property NSString *year;
@property NSMutableArray *stocks;
@property KCStock *selectedStock;

@end
