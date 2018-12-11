//
//  KCHistoryDetailViewController.m
//  Stocks
//
//  Created by Kevin Choi on 12/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCHistoryDetailViewController.h"
#import "KCDBUtility.h"

@interface KCHistoryDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stockSymLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *marketCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionQtyLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionAmtLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

@property NSString *addTradingFee;

@end

@implementation KCHistoryDetailViewController

- (void)loadInitialData
{
    NSLog(@"%@", self.stockSym);
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectDisplaySql = [NSString stringWithFormat:@"select add_trading_fee from user_table where id=1"];
    
    NSMutableArray *displayResult = [dbUtility resultSQL:selectDisplaySql];
    for (int i=0; i<[displayResult count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[displayResult objectAtIndex:i];
        self.addTradingFee = [columns valueForKey:@"0"];
    }
    
    
    NSString *selectSql2 = [NSString stringWithFormat:@"select tran_cost, tax, commission, min_charge from cost_table"];
    
    NSMutableArray *result2 = [dbUtility resultSQL:selectSql2];
    for (int i=0; i<[result2 count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result2 objectAtIndex:i];
        self.tranCost = [[columns valueForKey:@"0"] doubleValue];
        self.tax = [[columns valueForKey:@"1"] doubleValue];
        self.commission = [[columns valueForKey:@"2"] doubleValue];
        self.minCharge = [[columns valueForKey:@"3"] doubleValue];
        
    }
    
    self.stockSymLabel.text = self.stockSym;
    self.stockNameLabel.text = self.stockName;
    self.marketCodeLabel.text = self.marketCode;
    self.actionPriceLabel.text = [NSString stringWithFormat:@"%.2lf", self.actionPrice];
    self.actionQtyLabel.text = [NSString stringWithFormat:@"%d", self.actionQty];
    
    if ([self.addTradingFee isEqualToString:@"YES"]) {
        self.actionAmtLabel.text = [NSString stringWithFormat:@"%.2lf", self.actionPrice*self.actionQty+self.tradingFee];
    } else {
        self.actionAmtLabel.text = [NSString stringWithFormat:@"%.2lf", self.actionPrice*self.actionQty];

    }
    
    self.actionLabel.text = NSLocalizedString(self.action, nil);
    
    if ([self.action isEqualToString:@"BUY"]) {
        [self.actionLabel setBackgroundColor:[UIColor colorWithRed:172.0/255.0 green:235.0/255.0 blue:136.0/255.0 alpha:1.0]];
    }
    
    if ([self.action isEqualToString:@"SELL"]) {
        [self.actionLabel setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:130.0/255.0 blue:132.0/255.0 alpha:1.0]];
    }
    
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
    
    [self loadInitialData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
