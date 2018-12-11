//
//  KCMyPortfolioTableViewController.m
//  Stocks
//
//  Created by Kevin Choi on 27/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCMyPortfolioTableViewController.h"
#import "KCDBUtility.h"
#import "KCUtility.h"
#import "KCButton.h"
#import "KCStockDetailViewController.h"


enum KCPortfolioDisplayType {
    KCBuyPriceType = 1,
    KCBuyQtyType = 2,
    KCBuyAmtType = 3,
};

@interface KCMyPortfolioTableViewController ()

@property NSMutableDictionary *stocksDict;
@property NSString *addTradingFee;

@end

@implementation KCMyPortfolioTableViewController


- (NSMutableArray *)sortStocksArrayBySequenceAscending:(BOOL)option {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence" ascending:option comparator:^(NSString *string1, NSString *string2) {
        
        static NSStringCompareOptions comparisonOptions =
        NSCaseInsensitiveSearch | NSNumericSearch |
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        NSRange string1Range = NSMakeRange(0, [string1 length]);
        
        return [string1 compare:string2 options:comparisonOptions range:string1Range];
    }];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *sortedArray = [self.stocks sortedArrayUsingDescriptors:sortDescriptors];
    
    return [NSMutableArray arrayWithArray:sortedArray];
}

- (void)refreshPortfolio
{
    [self.stocksDict removeAllObjects];
    [self.stocks removeAllObjects];
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectDisplaySql = [NSString stringWithFormat:@"select add_trading_fee from user_table where id=1"];
    
    NSMutableArray *displayResult = [dbUtility resultSQL:selectDisplaySql];
    for (int i=0; i<[displayResult count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[displayResult objectAtIndex:i];
        self.addTradingFee = [columns valueForKey:@"0"];
    }
    
    NSString *selectSql = [NSString stringWithFormat:@"select id, stock_sym, stock_name, market_code, action_price, action_qty, sequence, trading_fee, action from portfolio_detail_table"];
    
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
        eachAction.sequence = [columns valueForKey:@"6"];
        eachAction.tradingFee = [[columns valueForKey:@"7"] doubleValue];
        eachAction.action = [columns valueForKey:@"8"];
        
        
        NSMutableArray *allActions = [self.stocksDict objectForKey:[NSString stringWithFormat:@"%@.%@", eachAction.stockSym, eachAction.marketCode]];
        
        if (allActions == nil) {
            NSMutableArray *values = [[NSMutableArray alloc] init];
            [values addObject:eachAction];
            [self.stocksDict setObject:values forKey:[NSString stringWithFormat:@"%@.%@", eachAction.stockSym, eachAction.marketCode]];
        } else {
            [allActions addObject:eachAction];
        }
        
        
    }
    
    NSArray *allKeys = [self.stocksDict allKeys];
    for (int i=0; i<[allKeys count]; i++) {
        NSString *key = [allKeys objectAtIndex:i];
        
        NSString *stockSym = nil;
        NSString *stockName = nil;
        NSString *marketCode = nil;
        double totalBuyValue = 0;
        int totalBuyQty = 0;
        double totalSellValue = 0;
        int totalSellQty = 0;
        double totalBuyTradingFee = 0;
        double totalSellTradingFee = 0;
        NSString *sequence = @"0";
        
        NSMutableArray *allActions = [self.stocksDict objectForKey:key];
        
        for (int j=0; j<[allActions count]; j++) {
            KCStock *eachAction = [allActions objectAtIndex:j];

            stockSym = eachAction.stockSym;
            stockName = eachAction.stockName;
            marketCode = eachAction.marketCode;
            sequence = eachAction.sequence;
            
            if ([eachAction.action isEqualToString:@"BUY"]) {
                
                totalBuyValue += eachAction.actionPrice * eachAction.actionQty;
                totalBuyQty += eachAction.actionQty;
                totalBuyTradingFee += eachAction.tradingFee;
                
            } else if ([eachAction.action isEqualToString:@"SELL"]) {
                
                totalSellValue += eachAction.actionPrice * eachAction.actionQty;
                totalSellQty += eachAction.actionQty;
                totalSellTradingFee += eachAction.tradingFee;

            }
        }
        
        NSLog(@"###totalBuyValue=%g", totalBuyValue);
        NSLog(@"###totalBuyQty=%d", totalBuyQty);
        NSLog(@"##totalBuyTradingFee=%g", totalBuyTradingFee);
        NSLog(@"###totalSellValue=%g", totalSellValue);
        NSLog(@"###totalSellQty=%d", totalSellQty);
        NSLog(@"##totalSellTradingFee=%g", totalSellTradingFee);
        
        KCStock *eachStock = [[KCStock alloc] init];
        eachStock.stockSym = stockSym;
        eachStock.stockName = stockName;
        eachStock.marketCode = marketCode;
        eachStock.tradingFee = totalBuyTradingFee + totalSellTradingFee;
        eachStock.sequence = sequence;

        
        int totalQty = 0;
        if (totalBuyQty - totalSellQty > 0) {
            totalQty = totalBuyQty - totalSellQty;
        }
        
        double totalValue = 0;
        if ([self.addTradingFee isEqualToString:@"YES"]) {
            if (totalBuyValue - totalSellValue + (totalBuyTradingFee + totalSellTradingFee) > 0) {
                totalValue = totalBuyValue - totalSellValue + (totalBuyTradingFee + totalSellTradingFee);
            }
        } else {
            if (totalBuyValue - totalSellValue > 0) {
                totalValue = totalBuyValue - totalSellValue;
            }
        }
        
        NSLog(@"totalValue=%g", totalValue);
        NSLog(@"totalQty=%d", totalQty);
        
        if (totalQty > 0) {
            
            eachStock.avgPrice = totalValue / totalQty;
            eachStock.totalQty = totalQty;
            
            [self.stocks addObject:eachStock];
        }
        
    }
    
    self.stocks = [self sortStocksArrayBySequenceAscending:YES];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stocks = [[NSMutableArray alloc] init];
    self.stocksDict = [[NSMutableDictionary alloc] init];
    self.selectedStock = [[KCStock alloc] init];
    self.currentDisplayType = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPortfolio) name:@"refreshPortfolio" object:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshPortfolio) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self refreshPortfolio];
    
    
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
    //NSLog(@"section=%d", section);
    //NSLog(@"portfolio detail=%d", [self.stocks count]);
    return [self.stocks count];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    KCStock *stock = [self.stocks objectAtIndex:indexPath.row];
    stock.sequence = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    NSString *updateSql = nil;
    
    if (stock.marketCode == nil) {
        updateSql = [NSString stringWithFormat:@"update portfolio_detail_table set sequence=%ld where stock_sym='%@' and market_code is null", (long)indexPath.row, stock.stockSym];
    } else {
        updateSql = [NSString stringWithFormat:@"update portfolio_detail_table set sequence=%ld where stock_sym='%@' and market_code='%@'", (long)indexPath.row, stock.stockSym, stock.marketCode];
    }
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    [dbUtility executeSQL:updateSql];
    
    
    UILabel *label1 = (UILabel *)[cell viewWithTag:1];
    if ([stock.marketCode length] > 0 && ![stock.marketCode isEqualToString:@"(null)"]) {
        label1.text = [NSString stringWithFormat:@"%@.%@", stock.stockSym, stock.marketCode];
    } else {
        label1.text = stock.stockSym;
    }
    
    UILabel *label2 = (UILabel *)[cell viewWithTag:2];
    label2.text = stock.stockName;
    
    UILabel *label3 = (UILabel *)[cell viewWithTag:3];
    
    if (self.currentDisplayType == 1) {
        label3.text = [NSString stringWithFormat:@"%.2lf", stock.avgPrice];
    } else if (self.currentDisplayType == 2) {
        label3.text = [NSString stringWithFormat:@"%d", stock.totalQty];
    } else {
        label3.text = [NSString stringWithFormat:@"%.2lf", stock.avgPrice * stock.totalQty];
    }
    

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    KCStock *stock = [self.stocks objectAtIndex:indexPath.row];
    self.selectedStock.stockSym = stock.stockSym;
    self.selectedStock.stockName = stock.stockName;
    self.selectedStock.marketCode = stock.marketCode;
    self.selectedStock.avgPrice = stock.avgPrice;
    self.selectedStock.totalQty = stock.totalQty;
    self.selectedStock.tradingFee = stock.tradingFee;
    
    [self performSegueWithIdentifier:@"StockDetailSegue" sender:self];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (!self.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        KCStock *stock = [self.stocks objectAtIndex:indexPath.row];
        
        KCDBUtility *dbUtility = [KCDBUtility newInstance];
        
        NSString *deleteSql = [NSString stringWithFormat:@"delete from portfolio_detail_table where stock_sym='%@' and market_code='%@'", stock.stockSym, stock.marketCode];
        
        BOOL result = [dbUtility executeSQL:deleteSql];
        
        if (result) {
            [self.stocks removeObject:stock];
        
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    KCStock *stock = [self.stocks objectAtIndex:fromIndexPath.row];
    
    
    NSString *updateSql = nil;
    
    if (stock.marketCode == nil) {
        updateSql = [NSString stringWithFormat:@"update portfolio_detail_table set sequence=%ld where stock_sym='%@' and market_code is null", (long)toIndexPath.row, stock.stockSym];
    } else {
        updateSql = [NSString stringWithFormat:@"update portfolio_detail_table set sequence=%ld where stock_sym='%@' and market_code='%@'", (long)toIndexPath.row, stock.stockSym, stock.marketCode];
    }
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    [dbUtility executeSQL:updateSql];

    
    if (fromIndexPath.row > toIndexPath.row){
     
        NSString *sql = nil;
        
        if (stock.marketCode == nil) {
            sql = [NSString stringWithFormat:@"update portfolio_detail_table set sequence=sequence+1 where sequence>=%ld and stock_sym!='%@' and market_code is null", (long)toIndexPath.row, stock.stockSym];
        } else {
            sql = [NSString stringWithFormat:@"update portfolio_detail_table set sequence=sequence+1 where sequence>=%ld and stock_sym!='%@' and market_code='%@'", (long)toIndexPath.row, stock.stockSym, stock.marketCode];
        }
        
        KCDBUtility *dbUtility = [KCDBUtility newInstance];
        [dbUtility executeSQL:sql];
       
        if (stock.marketCode == nil) {
            sql = [NSString stringWithFormat:@"update portfolio_detail_table set sequence=sequence-1 where sequence>%ld and stock_sym!='%@' and market_code is null", (long)fromIndexPath.row, stock.stockSym];
        } else {
            sql = [NSString stringWithFormat:@"update portfolio_detail_table set sequence=sequence-1 where sequence>%ld and stock_sym!='%@' and market_code='%@'", (long)fromIndexPath.row, stock.stockSym, stock.marketCode];
        }
        
        [dbUtility executeSQL:sql];
        
        
        
    } else {
        
        NSString *sql = nil;
        
        if (stock.marketCode == nil) {
            sql = [NSString stringWithFormat:@"update portfolio_detail_table set sequence=sequence-1 where sequence>%ld and sequence<=%ld and stock_sym!='%@' and market_code is null", (long)fromIndexPath.row, (long)toIndexPath.row, stock.stockSym];
        } else {
            sql = [NSString stringWithFormat:@"update portfolio_detail_table set sequence=sequence-1 where sequence>%ld and sequence<=%ld and stock_sym!='%@' and market_code='%@'", (long)fromIndexPath.row, (long)toIndexPath.row, stock.stockSym, stock.marketCode];
        }
        
        KCDBUtility *dbUtility = [KCDBUtility newInstance];
        [dbUtility executeSQL:sql];
        
        
    }
    
    [self refreshPortfolio];
    

}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"StockDetailSegue"]) {
        NSLog(@"## StockDetailSegue ##");
        KCStockDetailViewController *vc = [segue destinationViewController];
        vc.stockSym = self.selectedStock.stockSym;
        vc.stockName = self.selectedStock.stockName;
        vc.marketCode = self.selectedStock.marketCode;
        vc.buyPrice = self.selectedStock.avgPrice;
        vc.buyQty = self.selectedStock.totalQty;
        vc.tradingFee = self.selectedStock.tradingFee;
        
    }
}

/*
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationPortrait
        || orientation == UIInterfaceOrientationPortraitUpsideDown)
        return YES;
    else
        return NO;
}
*/

@end
