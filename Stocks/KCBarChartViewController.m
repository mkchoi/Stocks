//
//  KCBarChartViewController.m
//  Stocks
//
//  Created by Kevin Choi on 20/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCBarChartViewController.h"
#import "KCStock.h"
#import "KCDBUtility.h"

@interface KCBarChartViewController ()

@property (weak, nonatomic) IBOutlet UIView *barChartView;
@property (weak, nonatomic) IBOutlet UIView *upperInfoView;
@property (weak, nonatomic) IBOutlet UIView *lowerInfoView;

@property JBBarChartView *barChart;
@property NSString *greenAsRise;
@property NSMutableArray *data;

@end

@implementation KCBarChartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.data = [[NSMutableArray alloc] init];
    
    if (self.year == nil || [self.year isEqualToString:@"--Please Select --"]) {
    
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy"];
        
        NSMutableDictionary *yearProfitDict = [[NSMutableDictionary alloc] init];
        
        for (KCStock *stock in self.stocks) {
            
            NSString *yearStr = [dateFormat stringFromDate:stock.actionDate];

            KCStock *eachStock = [yearProfitDict objectForKey:yearStr];
            if (eachStock == nil) {
                eachStock = [[KCStock alloc] init];
                eachStock.profit = 0;
            }
            
            eachStock.profit += stock.profit;
            [yearProfitDict setObject:eachStock forKey:yearStr];
            
        }
        
        
        NSDate *curDate = [[NSDate alloc] init];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // Extract date components into components1
        NSDateComponents *components1 = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:curDate];
        
        for (long i=components1.year; i>components1.year-10; i--) {
            KCStock *yearProfit = [yearProfitDict objectForKey:[NSString stringWithFormat:@"%ld", i]];
            if (yearProfit != nil) {
                yearProfit.actionDate = [dateFormat dateFromString:[NSString stringWithFormat:@"%ld", i]];
                [self.data addObject:yearProfit];
            } else {
                yearProfit = [[KCStock alloc] init];
                yearProfit.profit = 0;
                yearProfit.actionDate = [dateFormat dateFromString:[NSString stringWithFormat:@"%ld", i]];
                [self.data addObject:yearProfit];
            }
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"actionDate" ascending:YES];
        [self.data sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
    } else {
        [self.data addObjectsFromArray:self.stocks];
    }
    
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectSql = [NSString stringWithFormat:@"select green_as_rise from user_table where id=1"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        self.greenAsRise = [columns valueForKey:@"0"];
    }
    
    // draw X-axis, Y-axis, zero
    
    UIBezierPath *pathX = [UIBezierPath bezierPath];
    
    [pathX moveToPoint:CGPointMake(self.barChartView.frame.origin.x - 30.0, self.barChartView.frame.origin.y + 140.0)];
    [pathX addLineToPoint:CGPointMake(self.barChartView.frame.origin.x + 320.0, self.barChartView.frame.origin.y + 140.0)];
    
    CAShapeLayer *shapeLayerX = [CAShapeLayer layer];
    shapeLayerX.path = [pathX CGPath];
    shapeLayerX.strokeColor = [[UIColor blackColor] CGColor];
    shapeLayerX.lineWidth = 1.0;
    shapeLayerX.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayerX];
    
    UIBezierPath *pathY = [UIBezierPath bezierPath];

    [pathY moveToPoint:CGPointMake(self.barChartView.frame.origin.x - 10.0, self.barChartView.frame.origin.y)];
    [pathY addLineToPoint:CGPointMake(self.barChartView.frame.origin.x - 10.0, self.barChartView.frame.origin.y + 280.0)];
    
    CAShapeLayer *shapeLayerY = [CAShapeLayer layer];
    shapeLayerY.path = [pathY CGPath];
    shapeLayerY.strokeColor = [[UIColor blackColor] CGColor];
    shapeLayerY.lineWidth = 1.0;
    shapeLayerY.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayerY];
    
    UILabel *zero = [[UILabel alloc] initWithFrame:CGRectMake(self.barChartView.frame.origin.x - 25.0, self.barChartView.frame.origin.y + 140.0, 15.0, 15.0)];
    [zero setFont:[UIFont systemFontOfSize:12]];
    [zero setText:@"0"];
    
    [self.view addSubview:zero];
    
    
    //
    
    if ([self.data count] > 0) {
        NSArray *sortedArray = [self.data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            KCStock *stock1 = (KCStock *) obj1;
            KCStock *stock2 = (KCStock *) obj2;
            
            if (stock1.profit > stock2.profit)
                return NSOrderedDescending;
            else if (stock1.profit < stock2.profit)
                return NSOrderedAscending;
            return NSOrderedSame;
        }];
        
        KCStock *minStock = [sortedArray objectAtIndex:0];
        KCStock *maxStock = [sortedArray objectAtIndex:[sortedArray count]-1];
        
        
        if (minStock.profit > 0) {
            [self.barChart setMinimumValue:0-maxStock.profit];
        } else {
            if (fabs(minStock.profit) > fabs(maxStock.profit)) {
                [self.barChart setMinimumValue:minStock.profit];
            } else {
                [self.barChart setMinimumValue:0-maxStock.profit];
            }
        }
        
        if (maxStock.profit < 0) {
            [self.barChart setMaximumValue:0-minStock.profit];
        } else {
            if (fabs(minStock.profit) > fabs(maxStock.profit)) {
                [self.barChart setMaximumValue:0-minStock.profit];
            } else {
                [self.barChart setMaximumValue:maxStock.profit];
            }
        }

    }
    
    
    
    [self.barChart reloadData];
    
    [self.barChart setState:JBChartViewStateExpanded animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.barChartView.center = CGPointMake(self.view.bounds.size.height/2, self.view.bounds.size.width/2);
    
    self.barChart = [[JBBarChartView alloc] initWithFrame:self.barChartView.bounds];
    self.barChart.delegate = self;
    self.barChart.dataSource = self;
    self.barChart.backgroundColor = [UIColor whiteColor];
    [self.barChartView addSubview:self.barChart];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation))
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return [self.data count];
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index
{
    KCStock *stock = [self.data objectAtIndex:index];
    
    return stock.profit;
}

- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    KCStock *stock = [self.data objectAtIndex:index];
    
    if ([self.greenAsRise length] > 0 && [self.greenAsRise isEqualToString:@"YES"]) {
        if (stock.profit > 0) {
            return [UIColor greenColor];
        } else {
            return [UIColor redColor];
        }
    } else {
        if (stock.profit < 0) {
            return [UIColor greenColor];
        } else {
            return [UIColor redColor];
        }
    }
}

- (UILabel *)barChartView:(JBBarChartView *)barChartView barTextAtIndex:(NSUInteger)index
{
    KCStock *stock = [self.data objectAtIndex:index];
    
    UILabel *label = [[UILabel alloc] init];
    
    if (self.year == nil || [self.year isEqualToString:@"--Please Select --"]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy"];
        
        label.text = [dateFormat stringFromDate:stock.actionDate];
    
    } else {
        label.text = stock.stockName;
    }
    
    return label;
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    // Update view
    
    KCStock *stock = [self.data objectAtIndex:index];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy"];

    if ([self.upperInfoView isHidden] && [self.lowerInfoView isHidden]) {
        if (stock.profit > 0) {
            UILabel *stockInfo = [[UILabel alloc] initWithFrame:self.upperInfoView.bounds];
            [stockInfo setTextAlignment:NSTextAlignmentCenter];
            [stockInfo setFont:[UIFont systemFontOfSize:14]];
            if (self.year == nil || [self.year isEqualToString:@"--Please Select --"]) {
                [stockInfo setText:[NSString stringWithFormat:@"%@ (%.2lf)", [dateFormat stringFromDate:stock.actionDate], stock.profit]];
            } else {
                [stockInfo setText:[NSString stringWithFormat:@"%@ (%.2lf)", stock.stockName, stock.profit]];
            }
            [self.upperInfoView addSubview:stockInfo];
            [self.upperInfoView setHidden:NO];
        } else {
            UILabel *stockInfo = [[UILabel alloc] initWithFrame:self.lowerInfoView.bounds];
            [stockInfo setTextAlignment:NSTextAlignmentCenter];
            [stockInfo setFont:[UIFont systemFontOfSize:14]];
            if (self.year == nil || [self.year isEqualToString:@"--Please Select --"]) {
                [stockInfo setText:[NSString stringWithFormat:@"%@ (%.2lf)", [dateFormat stringFromDate:stock.actionDate], stock.profit]];
            } else {
                [stockInfo setText:[NSString stringWithFormat:@"%@ (%.2lf)", stock.stockName, stock.profit]];
            }
            [self.lowerInfoView addSubview:stockInfo];
            [self.lowerInfoView setHidden:NO];
        }
    }
    
}

- (void)didUnselectBarChartView:(JBBarChartView *)barChartView
{
    // Update view
    
    if (![self.upperInfoView isHidden]) {
        NSArray *viewsToRemove = [self.upperInfoView subviews];
        for (UIView *v in viewsToRemove) {
            [v removeFromSuperview];
        }
        [self.upperInfoView setHidden:YES];
    }
    
    if (![self.lowerInfoView isHidden]) {
        NSArray *viewsToRemove = [self.lowerInfoView subviews];
        for (UIView *v in viewsToRemove) {
            [v removeFromSuperview];
        }
        [self.lowerInfoView setHidden:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight)
        return YES;
    else
        return NO;
}

@end
