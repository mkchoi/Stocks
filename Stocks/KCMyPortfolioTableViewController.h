//
//  KCMyPortfolioTableViewController.h
//  Stocks
//
//  Created by Kevin Choi on 27/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KCStock.h"

@interface KCMyPortfolioTableViewController : UITableViewController

@property NSMutableArray *stocks;
@property KCStock *selectedStock;
@property int currentDisplayType;

@end
