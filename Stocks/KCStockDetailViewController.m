//
//  KCStockDetailViewController.m
//  Stocks
//
//  Created by Kevin Choi on 29/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCStockDetailViewController.h"
#import "KCDBUtility.h"
#import "KCUtility.h"

@interface KCStockDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stockSymLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *marketLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyQtyLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmtLabel;

@property UIAlertView *sellAlertView;
@property UITextField *sellPriceTextField;
@property UITextField *sellQtyTextField;

@property UIAlertView *buyAlertView;
@property UITextField *buyPriceTextField;
@property UITextField *buyQtyTextField;

@property NSString *addTradingFee;

@end

@implementation KCStockDetailViewController

- (IBAction)sellStock:(id)sender {
    
    self.sellAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sell", nil)
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), NSLocalizedString(@"Cancel", nil), nil];
    
    self.sellAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    self.sellAlertView.tag = 1;
    
    self.sellPriceTextField = [self.sellAlertView textFieldAtIndex:0];
    self.sellPriceTextField.delegate = self;
    self.sellPriceTextField.placeholder = NSLocalizedString(@"Sell Price", nil);
    [self.sellPriceTextField setSecureTextEntry:NO];
    [self.sellPriceTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    
    self.sellQtyTextField = [self.sellAlertView textFieldAtIndex:1];
    self.sellPriceTextField.delegate = self;
    self.sellQtyTextField.placeholder = NSLocalizedString(@"Sell Qty", nil);
    [self.sellQtyTextField setSecureTextEntry:NO];
    [self.sellQtyTextField setKeyboardType:UIKeyboardTypeDecimalPad];
   
    
    [self.sellAlertView show];
    
    //[self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)buyMore:(id)sender {
    
    self.buyAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Buy More", nil)
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), NSLocalizedString(@"Cancel", nil), nil];
    
    self.buyAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    self.buyAlertView.tag = 2;
    
    self.buyPriceTextField = [self.buyAlertView textFieldAtIndex:0];
    self.buyPriceTextField.delegate = self;
    self.buyPriceTextField.placeholder = NSLocalizedString(@"Buy Price", nil);
    [self.buyPriceTextField setSecureTextEntry:NO];
    [self.buyPriceTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    
    self.buyQtyTextField = [self.buyAlertView textFieldAtIndex:1];
    self.buyQtyTextField.delegate = self;
    self.buyQtyTextField.placeholder = NSLocalizedString(@"Buy Qty", nil);
    [self.buyQtyTextField setSecureTextEntry:NO];
    [self.buyQtyTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    
    
    [self.buyAlertView show];

    
    //[self.navigationController popViewControllerAnimated:YES];

}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1) {
        NSLog(@"Sell Price=%@", [alertView textFieldAtIndex:0].text);
        NSLog(@"Sell Qty=%@", [alertView textFieldAtIndex:1].text);
        
        if (buttonIndex == 0) {
            NSLog(@"OK to sell!");
            
            if ([self.sellPriceTextField.text length] > 0 && [self.sellPriceTextField.text doubleValue] > 0
                && [self.sellQtyTextField.text length] > 0 && [self.sellQtyTextField.text intValue] > 0) {
            
                double tmpSellPrice = 0;
                if ([self.sellPriceTextField.text length] > 0) {
                    tmpSellPrice = [self.sellPriceTextField.text doubleValue];
                    NSLog(@"tmpSellPrice=%g", tmpSellPrice);
                }
                int tmpSellQty = 0;
                if ([self.sellQtyTextField.text length] > 0) {
                    tmpSellQty = [self.sellQtyTextField.text intValue];
                    NSLog(@"tmpSellQty=%d", tmpSellQty);
                }
                
                double tradingFee = 0.0;
                
                tradingFee += tmpSellPrice * tmpSellQty * (self.tranCost / 100);
                tradingFee += tmpSellPrice * tmpSellQty * (self.tax / 100);
                
                if (tmpSellPrice * tmpSellQty * (self.commission / 100) < self.minCharge) {
                    tradingFee += self.minCharge;
                } else {
                    tradingFee += tmpSellPrice * tmpSellQty * (self.commission / 100);
                }
                
                self.sellTradingFee = tradingFee;
                
                KCDBUtility *dbUtility = [KCDBUtility newInstance];
                
                NSString *insertSql = nil;
                
                if ([self.marketCode length] > 0) {
                    insertSql = [NSString stringWithFormat:@"insert into portfolio_detail_table (sequence, stock_sym, stock_name, market_code, action, action_price, action_time, action_qty, trading_fee, portfolio_id) values (0, '%@', '%@', '%@', '%@', %g, '%@', %d, %g, %d)", self.stockSym, self.stockName, self.marketCode, @"SELL", tmpSellPrice, [KCUtility getTodayStr], tmpSellQty, self.sellTradingFee, 1];
                } else {
                    insertSql = [NSString stringWithFormat:@"insert into portfolio_detail_table (sequence, stock_sym, stock_name, action, action_price, action_time, action_qty, trading_fee, portfolio_id) values (0, '%@', '%@', '%@', %g, '%@', %d, %g, %d)", self.stockSym, self.stockName, @"SELL", tmpSellPrice, [KCUtility getTodayStr], tmpSellQty, self.sellTradingFee, 1];
                }
                
                [dbUtility executeSQL:insertSql];
                
                
                NSString *msg = nil;
                
                if ([self.addTradingFee isEqualToString:@"YES"]) {
                    msg = [NSString stringWithFormat:@"%@%.2lf", NSLocalizedString(@"Amt returned: ", nil), tmpSellPrice*tmpSellQty-tradingFee];
                } else {
                    msg = [NSString stringWithFormat:@"%@%.2lf", NSLocalizedString(@"Amt returned: ", nil), tmpSellPrice*tmpSellQty];
                }
                
                UIAlertView *completeView = [[UIAlertView alloc] initWithTitle:nil
                                                                       message:msg
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                             otherButtonTitles: nil];
                completeView.tag = 3;
                
                [completeView show];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshHistory" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatistics" object:nil];
                
            } else {
                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:nil
                                                                       message:NSLocalizedString(@"Please enter Sell Price & Sell Qty.", nil)
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                             otherButtonTitles: nil];
                errorView.tag = 4;
                
                [errorView show];

            }
            
            
        } else {
            NSLog(@"Not sell!");
            
        }
        
    }
    
    if (alertView.tag == 2) {
        NSLog(@"Buy Price=%@", [alertView textFieldAtIndex:0].text);
        NSLog(@"Buy Qty=%@", [alertView textFieldAtIndex:1].text);
        
        if (buttonIndex == 0) {
            NSLog(@"OK to buy!");
            
            if ([self.buyPriceTextField.text length] > 0 && [self.buyPriceTextField.text doubleValue] > 0
                && [self.buyQtyTextField.text length] > 0 && [self.buyQtyTextField.text intValue] > 0) {
                
                double tmpBuyPrice = 0;
                if ([self.buyPriceTextField.text length] > 0) {
                    tmpBuyPrice = [self.buyPriceTextField.text doubleValue];
                    NSLog(@"tmpBuyPrice=%g", tmpBuyPrice);
                }
                int tmpBuyQty = 0;
                if ([self.buyQtyTextField.text length] > 0) {
                    tmpBuyQty = [self.buyQtyTextField.text intValue];
                    NSLog(@"tmpBuyQty=%d", tmpBuyQty);
                }
                
                double tradingFee = 0.0;
                
                tradingFee += tmpBuyPrice * tmpBuyQty * (self.tranCost / 100);
                tradingFee += tmpBuyPrice * tmpBuyQty * (self.tax / 100);
                
                if (tmpBuyPrice * tmpBuyQty * (self.commission / 100) < self.minCharge) {
                    tradingFee += self.minCharge;
                } else {
                    tradingFee += tmpBuyPrice * tmpBuyQty * (self.commission / 100);
                }
                
                self.buyMoreTradingFee = tradingFee;
                
                KCDBUtility *dbUtility = [KCDBUtility newInstance];
                
                NSString *insertSql = nil;
                
                if ([self.marketCode length] > 0) {
                    insertSql = [NSString stringWithFormat:@"insert into portfolio_detail_table (sequence, stock_sym, stock_name, market_code, action, action_price, action_time, action_qty, trading_fee, portfolio_id) values (0, '%@', '%@', '%@', '%@', %g, '%@', %d, %g, %d)", self.stockSym, self.stockName, self.marketCode, @"BUY", tmpBuyPrice, [KCUtility getTodayStr], tmpBuyQty, self.buyMoreTradingFee, 1];
                } else {
                    insertSql = [NSString stringWithFormat:@"insert into portfolio_detail_table (sequence, stock_sym, stock_name, action, action_price, action_time, action_qty, trading_fee, portfolio_id) values (0, '%@', '%@', '%@', %g, '%@', %d, %g, %d)", self.stockSym, self.stockName, @"BUY", tmpBuyPrice, [KCUtility getTodayStr], tmpBuyQty, self.buyMoreTradingFee, 1];
                }
                
                [dbUtility executeSQL:insertSql];
                
                NSString *msg = nil;
                
                if ([self.addTradingFee isEqualToString:@"YES"]) {
                    msg = [NSString stringWithFormat:@"%@%.2lf", NSLocalizedString(@"Amt spent: ", nil), tmpBuyPrice*tmpBuyQty+tradingFee];
                } else {
                    msg = [NSString stringWithFormat:@"%@%.2lf", NSLocalizedString(@"Amt spent: ", nil), tmpBuyPrice*tmpBuyQty];
                }

                
                UIAlertView *completeView = [[UIAlertView alloc] initWithTitle:nil
                                                                       message:msg
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                             otherButtonTitles: nil];
                completeView.tag = 3;
                
                [completeView show];
                
            } else {
                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"Please enter Buy Price & Buy Qty.", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                          otherButtonTitles: nil];
                errorView.tag = 4;
                
                [errorView show];
                
            }

            
        } else {
            NSLog(@"Not buy!");
            
        }
        
    }
    
    if (alertView.tag == 3) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPortfolio" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dismissKeyboard
{
    if ([self.sellPriceTextField isFirstResponder]) {
        [self.sellPriceTextField resignFirstResponder];
    }
    if ([self.sellQtyTextField isFirstResponder]) {
        [self.sellQtyTextField resignFirstResponder];
    }
    if ([self.buyPriceTextField isFirstResponder]) {
        [self.buyPriceTextField resignFirstResponder];
    }
    if ([self.buyQtyTextField isFirstResponder]) {
        [self.buyQtyTextField resignFirstResponder];
    }
    
}


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

    
    self.stockSymLabel.text = self.stockSym;
    self.stockNameLabel.text = self.stockName;
    self.marketLabel.text = self.marketCode;
    self.buyPriceLabel.text = [NSString stringWithFormat:@"%.2lf", self.buyPrice];
    self.buyQtyLabel.text = [NSString stringWithFormat:@"%d", self.buyQty];
    self.totalAmtLabel.text = [NSString stringWithFormat:@"%.2lf", self.buyPrice*self.buyQty];
    
    /*
    NSString *selectSql = [NSString stringWithFormat:@"select code from stock_exchange_table"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        self.marketCode = [columns valueForKey:@"0"];
        
    }
    */
    
    NSString *selectSql2 = [NSString stringWithFormat:@"select tran_cost, tax, commission, min_charge from cost_table"];
    
    NSMutableArray *result2 = [dbUtility resultSQL:selectSql2];
    for (int i=0; i<[result2 count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result2 objectAtIndex:i];
        self.tranCost = [[columns valueForKey:@"0"] doubleValue];
        self.tax = [[columns valueForKey:@"1"] doubleValue];
        self.commission = [[columns valueForKey:@"2"] doubleValue];
        self.minCharge = [[columns valueForKey:@"3"] doubleValue];
        
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    NSLog(@"## dismiss keyboard when tapping other textfield ##");
    [self dismissKeyboard];
    
    return YES;
}

@end
