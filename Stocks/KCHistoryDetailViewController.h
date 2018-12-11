//
//  KCHistoryDetailViewController.h
//  Stocks
//
//  Created by Kevin Choi on 12/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCHistoryDetailViewController : UIViewController

@property NSString *stockSym;
@property NSString *stockName;
@property NSString *marketCode;
@property NSString *action;
@property NSString *actionTime;
@property double actionPrice;
@property int actionQty;
@property double tradingFee;

@property double tranCost;
@property double tax;
@property double commission;
@property double minCharge;

@end
