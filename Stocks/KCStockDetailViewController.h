//
//  KCStockDetailViewController.h
//  Stocks
//
//  Created by Kevin Choi on 29/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCStockDetailViewController : UIViewController<UIAlertViewDelegate, UITextFieldDelegate>

@property NSString *stockSym;
@property NSString *stockName;
@property NSString *marketCode;
@property double buyPrice;
@property int buyQty;
@property double tradingFee;
/*
@property double sellPrice;
@property int sellQty;
@property double buyMorePrice;
@property int buyMoreQty;
*/
@property double tranCost;
@property double tax;
@property double commission;
@property double minCharge;

@property double sellTradingFee;
@property double buyMoreTradingFee;
@end
