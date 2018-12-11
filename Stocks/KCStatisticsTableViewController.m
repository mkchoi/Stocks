//
//  KCStatisticsTableViewController.m
//  Stocks
//
//  Created by Kevin Choi on 12/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCStatisticsTableViewController.h"
#import "KCDBUtility.h"

@interface KCStatisticsTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *totalProfitLabel;
@property NSString *addTradingFee;
@property NSString *greenAsRise;

@end

@implementation KCStatisticsTableViewController

- (void)refreshStatistics
{
    double totalProfit = 0;
    
    [self.stocks removeAllObjects];
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectDisplaySql = [NSString stringWithFormat:@"select add_trading_fee, green_as_rise from user_table where id=1"];
    
    NSMutableArray *displayResult = [dbUtility resultSQL:selectDisplaySql];
    for (int i=0; i<[displayResult count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[displayResult objectAtIndex:i];
        self.addTradingFee = [columns valueForKey:@"0"];
        self.greenAsRise = [columns valueForKey:@"1"];
    }

    
    NSString *selectSql = nil;
    
    if (self.year == nil) {
        selectSql = [NSString stringWithFormat:@"select id, stock_sym, stock_name, market_code, action_price, action_qty, trading_fee, action, action_time from portfolio_detail_table order by action_time desc"];
        
    } else {
        
        NSString *fromDate = [NSString stringWithFormat:@"%@-01-01", self.year];
        
        NSString *yearStr = nil;
        
        int yearInt = [self.year intValue];
        
        yearInt++;
        yearStr = [NSString stringWithFormat:@"%d", yearInt];
        
        NSString *toDate = [NSString stringWithFormat:@"%@-01-01", yearStr];
        
        
        selectSql = [NSString stringWithFormat:@"select id, stock_sym, stock_name, market_code, action_price, action_qty, trading_fee, action, action_time from portfolio_detail_table where action_time >= '%@' and action_time < '%@' order by action_time desc", fromDate, toDate];
        
    }
    
    NSMutableDictionary *buyActionsDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *sellActionsDict = [[NSMutableDictionary alloc] init];
    
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
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        eachAction.actionDate = [dateFormat dateFromString:eachAction.actionTime];
        
        if ([eachAction.action isEqualToString:@"BUY"]) {
            NSMutableArray *actions = [buyActionsDict objectForKey:[NSString stringWithFormat:@"%@.%@", eachAction.stockSym, eachAction.marketCode]];
            
            if (actions == nil) {
                actions = [[NSMutableArray alloc] init];
            }
            
            [actions addObject:eachAction];
            [buyActionsDict setObject:actions forKey:[NSString stringWithFormat:@"%@.%@", eachAction.stockSym, eachAction.marketCode]];
            

        } else if ([eachAction.action isEqualToString:@"SELL"]) {
            NSMutableArray *actions = [sellActionsDict objectForKey:[NSString stringWithFormat:@"%@.%@", eachAction.stockSym, eachAction.marketCode]];
            
            if (actions == nil) {
                actions = [[NSMutableArray alloc] init];
            }
            
            [actions addObject:eachAction];
            [sellActionsDict setObject:actions forKey:[NSString stringWithFormat:@"%@.%@", eachAction.stockSym, eachAction.marketCode]];

        }
    }
    
    
    // calculate profit or loss and add to stocks list
    
    NSMutableDictionary *buyStocksDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *sellStocksDict = [[NSMutableDictionary alloc] init];
    
    NSArray *allBuyActionsKeys = [buyActionsDict allKeys];
    for (int i=0; i<[allBuyActionsKeys count]; i++) {
        NSString *key = [allBuyActionsKeys objectAtIndex:i];
        
        NSString *stockSym = nil;
        NSString *stockName = nil;
        NSString *marketCode = nil;
        double totalBuyValue = 0;
        int totalBuyQty = 0;
        double totalBuyTradingFee = 0;
        
        NSMutableArray *allActions = [buyActionsDict objectForKey:key];
        
        for (int j=0; j<[allActions count]; j++) {
            KCStock *eachAction = [allActions objectAtIndex:j];
            
            stockSym = eachAction.stockSym;
            stockName = eachAction.stockName;
            marketCode = eachAction.marketCode;
            
            if ([eachAction.action isEqualToString:@"BUY"]) {
                
                totalBuyValue += eachAction.actionPrice * eachAction.actionQty;
                totalBuyQty += eachAction.actionQty;
                totalBuyTradingFee += eachAction.tradingFee;
                
            }
        }
        
        KCStock *eachStock = [[KCStock alloc] init];
        eachStock.stockSym = stockSym;
        eachStock.stockName = stockName;
        eachStock.marketCode = marketCode;
        eachStock.tradingFee = totalBuyTradingFee;
        
        
        int totalQty = 0;
        
        totalQty = totalBuyQty;
        
        double totalValue = 0;
        if ([self.addTradingFee isEqualToString:@"YES"]) {
           
            totalValue = totalBuyValue + totalBuyTradingFee;
            
        } else {
            
            totalValue = totalBuyValue;
            
        }
        
        NSLog(@"buyTotalValue=%g", totalValue);
        NSLog(@"buyTotalQty=%d", totalQty);
        
        if (totalQty > 0) {
            
            eachStock.avgPrice = totalValue / totalQty;
            eachStock.totalQty = totalQty;
            
            [buyStocksDict setObject:eachStock forKey:[NSString stringWithFormat:@"%@.%@", eachStock.stockSym, eachStock.marketCode]];
        }
    }
    
    NSArray *allSellActionsKeys = [sellActionsDict allKeys];
    for (int i=0; i<[allSellActionsKeys count]; i++) {
        NSString *key = [allSellActionsKeys objectAtIndex:i];
        
        NSString *stockSym = nil;
        NSString *stockName = nil;
        NSString *marketCode = nil;
        double totalSellValue = 0;
        int totalSellQty = 0;
        double totalSellTradingFee = 0;
        
        NSMutableArray *allActions = [sellActionsDict objectForKey:key];
        
        // sort actions to find the latest sale
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"actionDate" ascending:NO];
        [allActions sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        KCStock *latestStock = [allActions objectAtIndex:0];
        
        NSDate *latestDate = latestStock.actionDate;
        
        
        for (int j=0; j<[allActions count]; j++) {
            KCStock *eachAction = [allActions objectAtIndex:j];
            
            stockSym = eachAction.stockSym;
            stockName = eachAction.stockName;
            marketCode = eachAction.marketCode;
            
           if ([eachAction.action isEqualToString:@"SELL"]) {
                
                totalSellValue += eachAction.actionPrice * eachAction.actionQty;
                totalSellQty += eachAction.actionQty;
                totalSellTradingFee += eachAction.tradingFee;
                
            }
        }
        
        
        KCStock *eachStock = [[KCStock alloc] init];
        eachStock.stockSym = stockSym;
        eachStock.stockName = stockName;
        eachStock.marketCode = marketCode;
        eachStock.actionDate = latestDate;
        eachStock.tradingFee = totalSellTradingFee;
        
        
        
        int totalQty = 0;
        
        totalQty = totalSellQty;
        
        
        double totalValue = 0;
        if ([self.addTradingFee isEqualToString:@"YES"]) {
            
            totalValue = totalSellValue + totalSellTradingFee;
            
        } else {
           
            totalValue = totalSellValue;
            
        }
        
        NSLog(@"sellTotalValue=%g", totalValue);
        NSLog(@"sellTotalQty=%d", totalQty);
        
        if (totalQty > 0) {
            
            eachStock.avgPrice = totalValue / totalQty;
            eachStock.totalQty = totalQty;
            
            [sellStocksDict setObject:eachStock forKey:[NSString stringWithFormat:@"%@.%@", eachStock.stockSym, eachStock.marketCode]];
        }
    }

    
    NSArray *allBuyStocksKeys = [buyStocksDict allKeys];
    for (int i=0; i<[allBuyStocksKeys count]; i++) {
        NSString *buyStockKey = [allBuyStocksKeys objectAtIndex:i];
    
        KCStock *buyStock = [buyStocksDict objectForKey:buyStockKey];
        KCStock *sellStock = [sellStocksDict objectForKey:buyStockKey];
        
        if (sellStock != nil) {
            
            double profit = (sellStock.avgPrice - buyStock.avgPrice) * sellStock.totalQty;
            sellStock.profit = profit;
            totalProfit += profit;
            
            [self.stocks addObject:sellStock];
        }
        
    }
    
    buyActionsDict = nil;
    sellActionsDict = nil;
    buyStocksDict = nil;
    sellStocksDict = nil;
    
    NSMutableAttributedString *tpAttribText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ : %.2lf", NSLocalizedString(@"Total Profit", nil), totalProfit]];
    int length = (int)tpAttribText.length;
    
    [tpAttribText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 14)];
    if (totalProfit == 0) {
        [tpAttribText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(14, length-14)];
    } else if (totalProfit < 0) {
        if ([self.greenAsRise length] > 0 && [self.greenAsRise isEqualToString:@"YES"]) {
            [tpAttribText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(14, length-14)];
        } else {
            [tpAttribText addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(14, length-14)];
        }
        
    } else {
        if ([self.greenAsRise length] > 0 && [self.greenAsRise isEqualToString:@"YES"]) {
            [tpAttribText addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(14, length-14)];
        } else {
            [tpAttribText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(14, length-14)];
        }
    }
   
    self.totalProfitLabel.attributedText = tpAttribText;
    //self.totalProfitLabel.text = [NSString stringWithFormat:@"%@ : %.2lf", NSLocalizedString(@"Total Profit", nil), totalProfit];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"actionDate" ascending:NO];
    [self.stocks sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

/*
- (void)sortArrayByValueAscending:(BOOL)option {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"stockSym" ascending:option comparator:^(NSString *string1, NSString *string2) {
        
        static NSStringCompareOptions comparisonOptions =
        NSCaseInsensitiveSearch | NSNumericSearch |
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        return [string1 compare:string2 options:comparisonOptions];
    }];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *sortedArray = [self.stocks sortedArrayUsingDescriptors:sortDescriptors];
    
    [self.stocks removeAllObjects];
    [self.stocks addObjectsFromArray:sortedArray];
}
*/

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.stocks = [[NSMutableArray alloc] init];
    
    self.selectedStock = [[KCStock alloc] init];
    
    self.year = nil;
    
    [self refreshStatistics];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatistics) name:@"refreshStatistics" object:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshStatistics) forControlEvents:UIControlEventValueChanged];
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
    return [self.stocks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatisticsCell" forIndexPath:indexPath];
    
    // Configure the cell...
    KCStock *stock = [self.stocks objectAtIndex:indexPath.row];
    
    UILabel *label1 = (UILabel *)[cell viewWithTag:1];
    if ([stock.marketCode length] > 0 && ![stock.marketCode isEqualToString:@"(null)"]) {
        label1.text = [NSString stringWithFormat:@"%@.%@", stock.stockSym, stock.marketCode];
    } else {
        label1.text = stock.stockSym;
    }
    
    UILabel *label2 = (UILabel *)[cell viewWithTag:2];
    label2.text = stock.stockName;
    
    UILabel *label3 = (UILabel *)[cell viewWithTag:3];
    label3.text = [NSString stringWithFormat:@"%.2lf", stock.profit];
    
    if ([self.greenAsRise length] > 0 && [self.greenAsRise isEqualToString:@"YES"]) {
        if (stock.profit > 0) {
            label3.textColor = [UIColor greenColor];
            //[label3 setBackgroundColor:[UIColor colorWithRed:65.0/255.0 green:250.0/255.0 blue:65.0/255.0 alpha:1.0]];
        } else {
            label3.textColor = [UIColor redColor];
            //[label3 setBackgroundColor:[UIColor colorWithRed:250.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0]];
        }
    } else {
        if (stock.profit < 0) {
            label3.textColor = [UIColor greenColor];
            //[label3 setBackgroundColor:[UIColor colorWithRed:65.0/255.0 green:250.0/255.0 blue:65.0/255.0 alpha:1.0]];
        } else {
            label3.textColor = [UIColor redColor];
            //[label3 setBackgroundColor:[UIColor colorWithRed:250.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0]];
        }
    }

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"didSelectRowAtIndexPath");
    
    KCStock *stock = [self.stocks objectAtIndex:indexPath.row];
    
    //NSLog(@"%@", action.stockSym);
    
    self.selectedStock.stockSym = stock.stockSym;
    self.selectedStock.stockName = stock.stockName;
    self.selectedStock.marketCode = stock.marketCode;
    self.selectedStock.profit = stock.profit;
   
    
    //[self performSegueWithIdentifier:@"StatisticsDetailSegue" sender:self];
    
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
