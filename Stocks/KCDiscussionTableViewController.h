//
//  KCDiscussionTableViewController.h
//  Stocks
//
//  Created by Kevin Choi on 16/2/15.
//  Copyright (c) 2015 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KCTopic.h"

@interface KCDiscussionTableViewController : UITableViewController

@property NSMutableArray *topics;
@property KCTopic *selectedTopic;

@end
