//
//  KCStockExchangeViewController.h
//  Stocks
//
//  Created by Kevin Choi on 22/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCStockExchangeViewController : UIViewController<UIPickerViewDelegate>

@property NSString *area;
@property NSString *market;
@property NSString *code;

@end
