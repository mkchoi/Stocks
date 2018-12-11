//
//  KCTitleViewController.m
//  Stocks
//
//  Created by Kevin Choi on 30/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCTitleViewController.h"
#import "KCDBUtility.h"
#import "KCUtility.h"
#import "KCEnvVar.h"

@interface KCTitleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UISwitch *shareSwitch;


@end

@implementation KCTitleViewController


- (IBAction)shareThisPortfolio:(id)sender {
    
    KCEnvVar *obj = [KCEnvVar getInstance];
    
    if ([self.shareSwitch isOn]) {
        KCDBUtility *dbUtility = [KCDBUtility newInstance];
        
        NSString *updateSql = nil;
        
        updateSql = [NSString stringWithFormat:@"update portfolio_table set share='%@' where id=1", @"YES"];
        
        [dbUtility executeSQL:updateSql];
        
        self.sharePortfolio = @"YES";
        obj.sharePortfolio = self.sharePortfolio;
        
        
    } else {
        KCDBUtility *dbUtility = [KCDBUtility newInstance];
        
        NSString *updateSql = nil;
        
        updateSql = [NSString stringWithFormat:@"update portfolio_table set share='%@' where id=1", @"NO"];
        
        [dbUtility executeSQL:updateSql];
        
        self.sharePortfolio = @"NO";
        obj.sharePortfolio = self.sharePortfolio;
    }

}

- (IBAction)saveTitle:(id)sender {
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *updateSql = [NSString stringWithFormat:@"update portfolio_table set name='%@', share='%@' where id=1", [KCUtility getEscapedString:self.titleTextField.text], self.sharePortfolio];

    [dbUtility executeSQL:updateSql];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTitle" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (IBAction)cancelSave:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadInitialData {
    
    self.titleTextField.text = self.portfolioName;
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectSql = [NSString stringWithFormat:@"select name, share from portfolio_table where id=1"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        self.portfolioName = [columns valueForKey:@"0"];
        self.sharePortfolio = [columns valueForKey:@"1"];
    }
    
    if ([self.sharePortfolio isEqualToString:@"YES"]) {
        [self.shareSwitch setOn:YES];
    } else {
        [self.shareSwitch setOn:NO];
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
    
    self.titleTextField.delegate = self;
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
