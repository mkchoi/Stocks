//
//  KCPieChartViewController.m
//  Stocks
//
//  Created by Kevin Choi on 17/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCPieChartViewController.h"
#import "KCStock.h"

@interface KCPieChartViewController ()

@property (weak, nonatomic) IBOutlet UIView *pieChartView;
@property XYPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@end

@implementation KCPieChartViewController

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
    [self.pieChart reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.pieChartView.center = CGPointMake(self.view.bounds.size.height/2, self.view.bounds.size.width/2);
    
    //NSLog(@"x=%f", self.pieChartView.center.x);
    //NSLog(@"y=%f", self.pieChartView.center.y);
    
    self.pieChart = [[XYPieChart alloc] initWithFrame:self.pieChartView.bounds];
    [self.pieChart setDelegate:self];
    [self.pieChart setDataSource:self];
    //[self.pieChart setStartPieAngle:M_PI_2];	//optional
    [self.pieChart setAnimationSpeed:1.0];	//optional
    //[self.pieChart setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];	//optional
    [self.pieChart setLabelColor:[UIColor blackColor]];	//optional, defaults to white
    //[self.pieChart setLabelShadowColor:[UIColor blackColor]];	//optional, defaults to none (nil)
    [self.pieChart setLabelRadius:80];	//optional
    [self.pieChart setShowPercentage:NO];	//optional
    [self.pieChart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];	//optional
    //[self.pieChart setPieCenter:CGPointMake()];	//optional
    
    [self.pieChartView addSubview:self.pieChart];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
    double invTotal = 0;
    
    for (int i=0; i<[self.stocks count]; i++) {
        KCStock *stock = [self.stocks objectAtIndex:i];
        
        invTotal += stock.avgPrice * stock.totalQty;
    }
    
    UILabel *stockInfo = [[UILabel alloc] initWithFrame:self.infoView.bounds];
    [stockInfo setTextAlignment:NSTextAlignmentCenter];
    [stockInfo setFont:[UIFont systemFontOfSize:14]];
    [stockInfo setText:[NSString stringWithFormat:@"%@%.2lf", NSLocalizedString(@"Total: ", nil), invTotal]];
    [self.infoView addSubview:stockInfo];
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

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return [self.stocks count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    KCStock *stock = [self.stocks objectAtIndex:index];

    return stock.avgPrice * stock.totalQty;
}

/*
- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    
}
*/

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
    KCStock *stock = [self.stocks objectAtIndex:index];
    
    return [NSString stringWithFormat:@"%@", stock.stockName];
}

- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will select slice at index %d", (int)index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %d", (int)index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did deselect slice at index %d", (int)index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %d", (int)index);
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
