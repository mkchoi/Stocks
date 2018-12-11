//
//  KCHistoryTableViewController.m
//  Stocks
//
//  Created by Kevin Choi on 6/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCHistoryTableViewController.h"
#import "KCHistoryDetailViewController.h"
#import "KCDBUtility.h"


@interface KCHistoryTableViewController ()

@property NSMutableArray *actions;
@property NSMutableDictionary *monthDict;

@end

@implementation KCHistoryTableViewController


- (void)refreshHistory
{
    [self.actions removeAllObjects];
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectSql = nil;
    
    if (self.year == nil && self.month == nil) {
        selectSql = [NSString stringWithFormat:@"select id, stock_sym, stock_name, market_code, action_price, action_qty, trading_fee, action, action_time from portfolio_detail_table order by action_time desc"];

    } else {
    
        NSString *fromDate = [NSString stringWithFormat:@"%@-%@-01", self.year, [self.monthDict valueForKey:self.month]];

        NSString *yearStr = nil;
        NSString *monthStr = nil;
        
        int yearInt = [self.year intValue];
        
        int monthInt = [[self.monthDict valueForKey:self.month] intValue];
        monthInt++;
        
        if (monthInt == 13) {
            monthStr = @"01";
            yearInt++;
            yearStr = [NSString stringWithFormat:@"%d", yearInt];

        } else {
            if (monthInt > 9) {
                monthStr = [NSString stringWithFormat:@"%d", monthInt];
            } else {
                monthStr = [NSString stringWithFormat:@"0%d", monthInt];
            }
            yearStr = [NSString stringWithFormat:@"%d", yearInt];

        }
        
        NSString *toDate = [NSString stringWithFormat:@"%@-%@-01", yearStr, monthStr];
        
        
        selectSql = [NSString stringWithFormat:@"select id, stock_sym, stock_name, market_code, action_price, action_qty, trading_fee, action, action_time from portfolio_detail_table where action_time >= '%@' and action_time < '%@' order by action_time desc", fromDate, toDate];
        
    }
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        
        KCStock *eachAction = [[KCStock alloc] init];
        if ([[columns valueForKey:@"0"] length] > 0) {
            eachAction.rowId = [[columns valueForKey:@"0"] intValue];
        }
        eachAction.stockSym = [columns valueForKey:@"1"];
        eachAction.stockName = [columns valueForKey:@"2"];
        eachAction.marketCode = [columns valueForKey:@"3"];
        if ([[columns valueForKey:@"4"] length] > 0) {
            eachAction.actionPrice = [[columns valueForKey:@"4"] doubleValue];
        }
        if ([[columns valueForKey:@"5"] length] > 0) {
            eachAction.actionQty = [[columns valueForKey:@"5"] intValue];
        }
        eachAction.tradingFee = [[columns valueForKey:@"6"] doubleValue];
        eachAction.action = [columns valueForKey:@"7"];
        eachAction.actionTime = [columns valueForKey:@"8"];
    
        [self.actions addObject:eachAction];
    }
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.actions = [[NSMutableArray alloc] init];
    
    self.monthDict = [[NSMutableDictionary alloc] init];
    [self.monthDict setObject:@"01" forKey:@"jan"];
    [self.monthDict setObject:@"02" forKey:@"feb"];
    [self.monthDict setObject:@"03" forKey:@"mar"];
    [self.monthDict setObject:@"04" forKey:@"apr"];
    [self.monthDict setObject:@"05" forKey:@"may"];
    [self.monthDict setObject:@"06" forKey:@"jun"];
    [self.monthDict setObject:@"07" forKey:@"jul"];
    [self.monthDict setObject:@"08" forKey:@"aug"];
    [self.monthDict setObject:@"09" forKey:@"sep"];
    [self.monthDict setObject:@"10" forKey:@"oct"];
    [self.monthDict setObject:@"11" forKey:@"nov"];
    [self.monthDict setObject:@"12" forKey:@"dec"];
    
    self.selectedAction = [[KCStock alloc] init];
    
    self.year = nil;
    self.month = nil;

    [self refreshHistory];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHistory) name:@"refreshHistory" object:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshHistory) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.actions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    
    // Configure the cell...
    KCStock *action = [self.actions objectAtIndex:indexPath.row];
    
    NSString *dateStr = @"";
    NSString *timeStr = @"";
    
    dateStr = [action.actionTime substringToIndex:11];
    timeStr = [action.actionTime substringFromIndex:11];
    
    UILabel *label1 = (UILabel *)[cell viewWithTag:1];
    label1.text = dateStr;
    
    UILabel *label2 = (UILabel *)[cell viewWithTag:2];
    label2.text = timeStr;
    
    UILabel *label3 = (UILabel *)[cell viewWithTag:3];
    label3.text = action.stockName;
    
    UILabel *label4 = (UILabel *)[cell viewWithTag:4];
    if ([action.marketCode length] > 0 && ![action.marketCode isEqualToString:@"(null)"]) {
        label4.text = [NSString stringWithFormat:@"%@.%@", action.stockSym, action.marketCode];
    } else {
        label4.text = action.stockSym;
    }
    
    UILabel *label5 = (UILabel *)[cell viewWithTag:5];
    label5.text = NSLocalizedString(action.action, nil);
    
    
    if ([action.action isEqualToString:@"BUY"]) {
        [cell setBackgroundColor:[UIColor colorWithRed:172.0/255.0 green:235.0/255.0 blue:136.0/255.0 alpha:1.0]];
        //[label5 setBackgroundColor:[UIColor colorWithRed:172.0/255.0 green:235.0/255.0 blue:136.0/255.0 alpha:1.0]];
    }
    
    if ([action.action isEqualToString:@"SELL"]) {
        [cell setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:130.0/255.0 blue:132.0/255.0 alpha:1.0]];
        //[label5 setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:130.0/255.0 blue:132.0/255.0 alpha:1.0]];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"didSelectRowAtIndexPath");
    
    KCStock *action = [self.actions objectAtIndex:indexPath.row];
    
    //NSLog(@"%@", action.stockSym);
    
    self.selectedAction.stockSym = action.stockSym;
    self.selectedAction.stockName = action.stockName;
    self.selectedAction.marketCode = action.marketCode;
    self.selectedAction.actionPrice = action.actionPrice;
    self.selectedAction.actionQty = action.actionQty;
    self.selectedAction.tradingFee = action.tradingFee;
    self.selectedAction.action = action.action;
    self.selectedAction.actionTime = action.actionTime;
    
    [self performSegueWithIdentifier:@"HistoryDetailSegue" sender:self];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"HistoryDetailSegue"]) {
        NSLog(@"## HistoryDetailSegue ##");
        KCHistoryDetailViewController *vc = [segue destinationViewController];
        vc.stockSym = self.selectedAction.stockSym;
        vc.stockName = self.selectedAction.stockName;
        vc.marketCode = self.selectedAction.marketCode;
        vc.actionPrice = self.selectedAction.actionPrice;
        vc.actionQty = self.selectedAction.actionQty;
        vc.tradingFee = self.selectedAction.tradingFee;
        vc.action = self.selectedAction.action;
        vc.actionTime = self.selectedAction.actionTime;
        
    }
}


@end
