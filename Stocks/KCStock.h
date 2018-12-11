//
//  KCStock.h
//  Stocks
//
//  Created by Kevin Choi on 27/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCStock : NSObject

@property int rowId;
@property NSString *sequence;
@property NSString *stockSym;
@property NSString *stockName;
@property NSString *marketCode;
@property NSString *action;

@property double actionPrice;
@property int actionQty;
@property NSString *actionTime;
@property NSDate *actionDate;

@property double tradingFee;
@property int portfolioId;

@property double avgPrice;
@property int totalQty;

@property double profit;

@end
