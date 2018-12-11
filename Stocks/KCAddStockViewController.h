//
//  KCAddStockViewController.h
//  Stocks
//
//  Created by Kevin Choi on 9/3/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCAddStockViewController : UIViewController<UITextFieldDelegate>

@property NSString *stockSym;
@property NSString *stockName;
@property NSString *marketCode;
@property double buyPrice;
@property int buyQty;
@property double tranCost;
@property double tax;
@property double commission;
@property double minCharge;
@property double tradingFee;


@end
