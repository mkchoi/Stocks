//
//  KCAddStockViewController.m
//  Stocks
//
//  Created by Kevin Choi on 9/3/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCAddStockViewController.h"
#import "KCDBUtility.h"
#import "KCUtility.h"

@interface KCAddStockViewController()

@property (weak, nonatomic) IBOutlet UITextField *stockSymTextField;
@property (weak, nonatomic) IBOutlet UITextField *stockNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *buyPriceTextField;
@property (weak, nonatomic) IBOutlet UITextField *buyQtyTextField;
@property (weak, nonatomic) IBOutlet UITextField *marketTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalAmtTextField;

@property NSString *addTradingFee;

@end

@implementation KCAddStockViewController

- (IBAction)addStock:(id)sender
{
    
    if ([self.stockSymTextField.text length] == 0 || [self.stockNameTextField.text length] == 0
        || [self.buyPriceTextField.text length] == 0 || [self.buyQtyTextField.text length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"Please enter all fields.", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    

    self.stockSym = [KCUtility getEscapedString:self.stockSymTextField.text];
    self.stockName = [KCUtility getEscapedString:self.stockNameTextField.text];
    if ([self.buyPriceTextField.text length] > 0) {
        self.buyPrice = [self.buyPriceTextField.text doubleValue];
    }
    if ([self.buyQtyTextField.text length] > 0) {
        self.buyQty = [self.buyQtyTextField.text doubleValue];
    }
    
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *insertSql = nil;
    
    if ([self.marketCode length] > 0) {
        insertSql = [NSString stringWithFormat:@"insert into portfolio_detail_table (sequence, stock_sym, stock_name, market_code, action, action_price, action_time, action_qty, trading_fee, portfolio_id) values (0, '%@', '%@', '%@', '%@', %g, '%@', %d, %g, %d)", self.stockSym, self.stockName, self.marketCode, @"BUY", self.buyPrice, [KCUtility getTodayStr], self.buyQty, self.tradingFee, 1];
    } else {
        insertSql = [NSString stringWithFormat:@"insert into portfolio_detail_table (sequence, stock_sym, stock_name, action, action_price, action_time, action_qty, trading_fee, portfolio_id) values (0, '%@', '%@', '%@', %g, '%@', %d, %g, %d)", self.stockSym, self.stockName, @"BUY", self.buyPrice, [KCUtility getTodayStr], self.buyQty, self.tradingFee, 1];
    }
    
    [dbUtility executeSQL:insertSql];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPortfolio" object:nil];
    
    }];
    
    
}

- (IBAction)cancelAddStock:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)loadInitialData
{
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectSql = [NSString stringWithFormat:@"select code from stock_exchange_table"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        self.marketCode = [columns valueForKey:@"0"];
        
    }
    
    if ([self.marketCode length] > 0 && ![self.marketCode isEqualToString:@"(null)"]) {
        self.marketTextField.text = self.marketCode;
    } else {
        self.marketTextField.text = @"";
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
    
    NSString *selectSql3 = [NSString stringWithFormat:@"select add_trading_fee from user_table where id=1"];
    
    NSMutableArray *result3 = [dbUtility resultSQL:selectSql3];
    for (int i=0; i<[result3 count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result3 objectAtIndex:i];
        self.addTradingFee = [columns valueForKey:@"0"];
        
    }

    
}

- (void)dismissKeyboard
{
    if ([self.stockSymTextField isFirstResponder]) {
        [self.stockSymTextField resignFirstResponder];
    }
    if ([self.stockNameTextField isFirstResponder]) {
        [self.stockNameTextField resignFirstResponder];
    }
    if ([self.buyPriceTextField isFirstResponder]) {
        [self.buyPriceTextField resignFirstResponder];
    }
    if ([self.buyQtyTextField isFirstResponder]) {
        [self.buyQtyTextField resignFirstResponder];
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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.stockSymTextField.delegate = self;
    self.stockNameTextField.delegate = self;
    self.buyPriceTextField.delegate = self;
    self.buyQtyTextField.delegate = self;
    
    UITapGestureRecognizer *dismissGestureRecognition1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    dismissGestureRecognition1.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismissGestureRecognition1];
    
    [self loadInitialData];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 
 }
 */

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    NSLog(@"## dismiss keyboard when tapping other textfield ##");
    [self dismissKeyboard];
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.buyPriceTextField || textField == self.buyQtyTextField) {
        [self moveViewUp:YES distance:100];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.buyPriceTextField || textField == self.buyQtyTextField) {
        [self moveViewUp:NO distance:100];
    
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
        
        self.tradingFee = tradingFee;

        if (tmpBuyPrice > 0 && tmpBuyQty > 0) {
            if ([self.addTradingFee isEqualToString:@"YES"]) {
                self.totalAmtTextField.text = [NSString stringWithFormat:@"%.2lf", tmpBuyPrice*tmpBuyQty+tradingFee];
            } else {
                self.totalAmtTextField.text = [NSString stringWithFormat:@"%.2lf", tmpBuyPrice*tmpBuyQty];
            }
        }
    }
    
}

- (void)moveViewUp:(BOOL)up distance:(int)movementDistance
{
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"moveViewUp" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
