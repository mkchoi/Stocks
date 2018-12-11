//
//  KCTradingFeeViewController.h
//  Stocks
//
//  Created by Kevin Choi on 22/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCTradingFeeViewController : UIViewController<UITextFieldDelegate>

@property double tranCost;
@property double tax;
@property double commission;
@property double minCharge;

@end
