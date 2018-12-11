//
//  KCPieChartViewController.h
//  Stocks
//
//  Created by Kevin Choi on 17/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart/XYPieChart.h"

@interface KCPieChartViewController : UIViewController<XYPieChartDelegate, XYPieChartDataSource>

@property NSMutableArray *stocks;

@end
