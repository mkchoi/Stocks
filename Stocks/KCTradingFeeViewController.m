//
//  KCTradingFeeViewController.m
//  Stocks
//
//  Created by Kevin Choi on 22/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCTradingFeeViewController.h"
#import "KCDBUtility.h"

@interface KCTradingFeeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tranCostTextField;
@property (weak, nonatomic) IBOutlet UITextField *taxTextField;
@property (weak, nonatomic) IBOutlet UITextField *commTextField;
@property (weak, nonatomic) IBOutlet UITextField *minChargeTextField;

@end

@implementation KCTradingFeeViewController

- (void)saveTradingFee
{
    NSLog(@"Save Trading Fee");
    
    self.tranCost = [self.tranCostTextField.text floatValue];
    self.tax = [self.taxTextField.text floatValue];
    self.commission = [self.commTextField.text floatValue];
    self.minCharge = [self.minChargeTextField.text floatValue];
    
    if (self.tranCost < 0) {
        self.tranCost = 0;
    }
    if (self.tax < 0) {
        self.tax = 0;
    }
    if (self.commission < 0) {
        self.commission = 0;
    }
    if (self.minCharge < 0) {
        self.minCharge = 0;
    }
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    int countCost = 0;
    
    NSString *selectSql = [NSString stringWithFormat:@"select count(*) from cost_table"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        countCost = [[columns valueForKey:@"0"] intValue];
    }
    
    if (countCost == 0) {
        
        NSString *insertSql = nil;
        
        insertSql = [NSString stringWithFormat:@"insert into cost_table (tran_cost, tax, commission, min_charge) values (%g, %g, %g, %g)", self.tranCost, self.tax, self.commission, self.minCharge];
        
        [dbUtility executeSQL:insertSql];
        
    } else {
        
        NSString *updateSql = nil;
        
        updateSql = [NSString stringWithFormat:@"update cost_table set tran_cost=%g, tax=%g, commission=%g, min_charge=%g", self.tranCost, self.tax, self.commission, self.minCharge];
        
        [dbUtility executeSQL:updateSql];
        
    }
    
    
    // update all portfolio details
    
    NSString *selectSql2 = [NSString stringWithFormat:@"select id, action_price, action_qty from portfolio_detail_table"];
    
    NSMutableArray *result2 = [dbUtility resultSQL:selectSql2];
    for (int i=0; i<[result2 count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result2 objectAtIndex:i];
        
        int rowId = 0;
        double actionPrice = 0.0;
        int actionQty = 0;
        double tradingFee = 0.0;
        
        if ([[columns valueForKey:@"0"] length] > 0) {
            rowId = [[columns valueForKey:@"0"] intValue];
        }
        if ([[columns valueForKey:@"1"] length] > 0) {
            actionPrice = [[columns valueForKey:@"1"] doubleValue];
        }
        if ([[columns valueForKey:@"2"] length] > 0) {
            actionQty = [[columns valueForKey:@"2"] intValue];
        }
        
        
        tradingFee += actionPrice * actionQty * (self.tranCost / 100);
        tradingFee += actionPrice * actionQty * (self.tax / 100);
        
        if (actionPrice * actionQty * (self.commission / 100) < self.minCharge) {
            tradingFee += self.minCharge;
        } else {
            tradingFee += actionPrice * actionQty * (self.commission / 100);
        }
        
        NSString *updateSql = [NSString stringWithFormat:@"update portfolio_detail_table set trading_fee=%g where id=%d", tradingFee, rowId];
        
        [dbUtility executeSQL:updateSql];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPortfolio" object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)loadInitialData {
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectSql = [NSString stringWithFormat:@"select tran_cost, tax, commission, min_charge from cost_table"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        if([[columns valueForKey:@"0"] length] > 0) {
            self.tranCost = [[columns valueForKey:@"0"] doubleValue];
        }
        if([[columns valueForKey:@"1"] length] > 0) {
            self.tax = [[columns valueForKey:@"1"] doubleValue];
        }
        if([[columns valueForKey:@"2"] length] > 0) {
            self.commission = [[columns valueForKey:@"2"] doubleValue];
        }
        if([[columns valueForKey:@"3"] length] > 0) {
            self.minCharge = [[columns valueForKey:@"3"] doubleValue];
        }
    }
    
    
    if (self.tranCost > 0) {
        [self.tranCostTextField setText:[NSString stringWithFormat:@"%g", self.tranCost]];
    } else {
        [self.tranCostTextField setText:@"0"];
    }
    
    if (self.tax > 0) {
        [self.taxTextField setText:[NSString stringWithFormat:@"%g", self.tax]];
    } else {
        [self.taxTextField setText:@"0"];
    }
    
    if (self.commission > 0) {
        [self.commTextField setText:[NSString stringWithFormat:@"%g", self.commission]];
    } else {
        [self.commTextField setText:@"0"];
    }
    
    if (self.minCharge > 0) {
        [self.minChargeTextField setText:[NSString stringWithFormat:@"%g", self.minCharge]];
    } else {
        [self.minChargeTextField setText:@"0"];
    }
}


- (void)dismissKeyboard
{
    if ([self.tranCostTextField isFirstResponder]) {
        [self.tranCostTextField resignFirstResponder];
    }
    if ([self.taxTextField isFirstResponder]) {
        [self.taxTextField resignFirstResponder];
    }
    if ([self.commTextField isFirstResponder]) {
        [self.commTextField resignFirstResponder];
    }
    if ([self.minChargeTextField isFirstResponder]) {
        [self.minChargeTextField resignFirstResponder];
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

-(void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    //if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        
        [self saveTradingFee];
    //}
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.tranCostTextField.delegate = self;
    self.taxTextField.delegate = self;
    self.commTextField.delegate = self;
    self.minChargeTextField.delegate = self;
    
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.commTextField || textField == self.minChargeTextField) {
        [self moveViewUp:YES distance:100];
    }
    /*
    UITapGestureRecognizer *dismissGestureRecognition1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    dismissGestureRecognition1.numberOfTapsRequired = 1;
    [textField addGestureRecognizer:dismissGestureRecognition1];
    */
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.commTextField || textField == self.minChargeTextField) {
        [self moveViewUp:NO distance:100];
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



@end
