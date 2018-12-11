//
//  KCBarChartViewController.h
//  Stocks
//
//  Created by Kevin Choi on 20/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBChartView/JBBarChartView.h"

@interface KCBarChartViewController : UIViewController<JBBarChartViewDataSource, JBBarChartViewDelegate>

@property NSString *year;
@property NSMutableArray *stocks;

@end
