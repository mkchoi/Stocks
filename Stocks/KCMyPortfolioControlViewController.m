//
//  KCMyPortfolioControlViewController.m
//  Stocks
//
//  Created by Kevin Choi on 11/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCMyPortfolioControlViewController.h"
#import "KCTitleViewController.h"
#import "KCMyPortfolioTableViewController.h"
#import "KCPieChartViewController.h"
#import "KCDBUtility.h"
#import "KCStock.h"

enum KCPortfolioDisplayType {
    KCBuyPriceType = 1,
    KCBuyQtyType = 2,
    KCBuyAmtType = 3,
};

@interface KCMyPortfolioControlViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *displayTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *showInvTotalButton;
@property (weak, nonatomic) IBOutlet UIView *advertView;

@end

@implementation KCMyPortfolioControlViewController

- (IBAction)showInvestmentTotal:(id)sender {
    
    UIButton *showInvTotalButton = sender;
    
    if ([showInvTotalButton.titleLabel.text isEqualToString:NSLocalizedString(@"Show Investment Total", nil)]) {
        
        double invTotal = 0;
        
        KCMyPortfolioTableViewController *vc = nil;
        NSArray *childControllers = self.childViewControllers;
        for (UIViewController *childController in childControllers) {
            if (childController.title != nil && [childController.title isEqualToString:@"MyPortfolioTableView"]) {
                vc = (KCMyPortfolioTableViewController *) childController;
            }
        }
        
        for (int i=0; i<[vc.stocks count]; i++) {
            KCStock *stock = [vc.stocks objectAtIndex:i];
            
            invTotal += stock.avgPrice * stock.totalQty;
        }
        
        [self.showInvTotalButton setTitle:[NSString stringWithFormat:@"%@%.2lf", NSLocalizedString(@"Total: ", nil), invTotal] forState:UIControlStateNormal];
        
    } else {
        
        [self.showInvTotalButton setTitle:NSLocalizedString(@"Show Investment Total", nil) forState:UIControlStateNormal];
    }
    
}

- (IBAction)changeDisplayType:(id)sender {
    
    KCMyPortfolioTableViewController *vc = nil;
    NSArray *childControllers = self.childViewControllers;
    for (UIViewController *childController in childControllers) {
        if (childController.title != nil && [childController.title isEqualToString:@"MyPortfolioTableView"]) {
            vc = (KCMyPortfolioTableViewController *) childController;
        }
    }
    
    if (vc.currentDisplayType == 1) {
        vc.currentDisplayType++;
        [self.displayTypeButton setTitle:NSLocalizedString(@"Buy Qty", nil) forState:UIControlStateNormal];
    } else if (vc.currentDisplayType == 2) {
        vc.currentDisplayType++;
        [self.displayTypeButton setTitle:NSLocalizedString(@"Buy Cost", nil) forState:UIControlStateNormal];
    } else {
        vc.currentDisplayType = 1;
        [self.displayTypeButton setTitle:NSLocalizedString(@"Buy Price", nil) forState:UIControlStateNormal];
    }
    
    [vc.tableView reloadData];
    
}

- (IBAction)editMode:(id)sender {
    
    NSLog(@"set Edit mode");
    
    UIBarButtonItem *editButton = sender;
    
    KCMyPortfolioTableViewController *vc = nil;
    NSArray *childControllers = self.childViewControllers;
    for (UIViewController *childController in childControllers) {
        if (childController.title != nil && [childController.title isEqualToString:@"MyPortfolioTableView"]) {
            vc = (KCMyPortfolioTableViewController *) childController;
        }
    }
    
    if (vc.editing) {
        [editButton setTitle:NSLocalizedString(@"Edit", nil)];
        [vc setEditing:NO animated:YES];
        //[self refreshPortfolio];
        
    } else {
        [editButton setTitle:NSLocalizedString(@"Done", nil)];
        [vc setEditing:YES animated:YES];
    }
    
}


- (void)titleSingleTap {
    [self performSegueWithIdentifier:@"TitleSegue" sender:self];
}

- (void)refreshTitle
{
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectSql = [NSString stringWithFormat:@"select name from portfolio_table where id=1"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        self.navigationItem.title = [columns valueForKey:@"0"];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPortfolio" object:nil];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;
    
    [self.showInvTotalButton setTitle:NSLocalizedString(@"Show Investment Total", nil) forState:UIControlStateNormal];
    
    UITapGestureRecognizer *navSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleSingleTap)];
    navSingleTap.numberOfTapsRequired = 1;
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] setUserInteractionEnabled:YES];
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] addGestureRecognizer:navSingleTap];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTitle) name:@"refreshTitle" object:nil];
    
    
    
    [self refreshTitle];
    
    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    [self.advertView addSubview:adView];
    
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
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self performSegueWithIdentifier:@"PieChartSegue" sender:self];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"TitleSegue"]) {
        NSLog(@"## TitleSegue ##");
        KCTitleViewController *vc = [segue destinationViewController];
        vc.portfolioName = self.navigationItem.title;
        
    } else if ([[segue identifier] isEqualToString:@"PieChartSegue"]) {
        NSLog(@"## PieChartSegue ##");
        
        KCMyPortfolioTableViewController *vc = nil;
        NSArray *childControllers = self.childViewControllers;
        for (UIViewController *childController in childControllers) {
            if (childController.title != nil && [childController.title isEqualToString:@"MyPortfolioTableView"]) {
                vc = (KCMyPortfolioTableViewController *) childController;
            }
        }
        
        KCPieChartViewController *pcVc = [segue destinationViewController];
        pcVc.stocks = [vc.stocks copy];
        
    }
}



@end
