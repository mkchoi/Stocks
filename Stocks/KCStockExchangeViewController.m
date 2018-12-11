//
//  KCStockExchangeViewController.m
//  Stocks
//
//  Created by Kevin Choi on 22/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCStockExchangeViewController.h"
#import "KCSelectButton.h"
#import "KCDBUtility.h"

@interface KCStockExchangeViewController ()

@property (weak, nonatomic) IBOutlet UIView *areaView;
@property (weak, nonatomic) IBOutlet UIView *marketView;
@property (weak, nonatomic) IBOutlet KCSelectButton *areaButton;
@property (weak, nonatomic) IBOutlet KCSelectButton *marketButton;

@property NSArray *areaRef;
@property NSArray *areaArray;
@property NSArray *americasRef;
@property NSArray *americasArray;
@property NSArray *emeaRef;
@property NSArray *emeaArray;
@property NSArray *asiaPacificRef;
@property NSArray *asiaPacificArray;
@property NSArray *noChoiceRef;
@property NSArray *noChoiceArray;
@property NSArray *marketRef;
@property NSArray *marketArray;

@property NSDictionary *marketCodeDict;

@end

@implementation KCStockExchangeViewController


- (UIPickerView *)createPopOverPicker:(int) tag withWidth:(int) width withHeight:(int) height
{
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    pickerView.tag = tag;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    
    if (tag == 1) {
        [self.areaView addSubview:pickerView];
        [self.areaView setHidden:NO];
        
    } else if (tag == 2) {
        [self.marketView addSubview:pickerView];
        [self.marketView setHidden:NO];
    }
    
    return pickerView;
    
}

- (IBAction)selectArea:(id)sender {
    
    int width = 290;
    int height = 150;
    
    UIPickerView *pickerView = [self createPopOverPicker:1 withWidth:width withHeight:height];
    
    int pos = 0;
    for(int i=0; i<[self.areaRef count]; i++) {
        NSString *compare = [self.areaRef objectAtIndex:i];
        NSLog(@"compare=%@", compare);
        if ([self.area isEqualToString:compare]){
            pos = i;
            break;
        }
        
    }
    
    [pickerView selectRow:pos inComponent:0 animated:NO];
    
}

- (IBAction)selectMarket:(id)sender {
    
    int width = 290;
    int height = 150;
    
    UIPickerView *pickerView = [self createPopOverPicker:2 withWidth:width withHeight:height];
    
    int pos = 0;
    for(int i=0; i<[self.marketRef count]; i++) {
        NSString *compare = [self.marketRef objectAtIndex:i];
        NSLog(@"compare=%@", compare);
        if ([self.market isEqualToString:compare]){
            pos = i;
            break;
        }
        
    }
    
    [pickerView selectRow:pos inComponent:0 animated:NO];
    
}

- (void)dismissAreaView
{
    NSArray *viewsToRemove = [self.areaView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [self.areaView setHidden:YES];
    
}

- (void)dismissMarketView
{
    NSArray *viewsToRemove = [self.marketView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [self.marketView setHidden:YES];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (pickerView.tag == 1) {
        return [self.areaArray count];
        
    } else if (pickerView.tag == 2) {
        return [self.marketArray count];
    
    } else {
        return 0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        return [self.areaArray objectAtIndex:row];
        
    } else if (pickerView.tag == 2) {
        return [self.marketArray objectAtIndex:row];
    
    } else {
        return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView.tag == 1) {
        self.area = [self.areaRef objectAtIndex:row];
        [self.areaButton setTitle:[self.areaArray objectAtIndex:row] forState:UIControlStateNormal];
        
        if ([self.area isEqualToString:@"americas"]) {
            self.marketRef = self.americasRef;
            self.marketArray = self.americasArray;
        } else if ([self.area isEqualToString:@"emea"]) {
            self.marketRef = self.emeaRef;
            self.marketArray = self.emeaArray;
        } else if ([self.area isEqualToString:@"asia-pacific"]) {
            self.marketRef = self.asiaPacificRef;
            self.marketArray = self.asiaPacificArray;
        } else {
            self.marketRef = self.noChoiceRef;
            self.marketArray = self.noChoiceArray;

        }
        
        self.market = [self.marketRef objectAtIndex:0];
        [self.marketButton setTitle:[self.marketArray objectAtIndex:0] forState:UIControlStateNormal];
        
        self.code = [self.marketCodeDict valueForKey:self.market];
        NSLog(@"code=%@", self.code);
        
        [self dismissAreaView];
    
    } else if (pickerView.tag == 2) {
        self.market = [self.marketRef objectAtIndex:row];
        [self.marketButton setTitle:[self.marketArray objectAtIndex:row] forState:UIControlStateNormal];
        
        self.code = [self.marketCodeDict valueForKey:self.market];
        NSLog(@"code=%@", self.code);
        
        [self dismissMarketView];

    } else {
        
    }
    
}

- (void)saveStockExchange
{
    NSLog(@"Save Stock Exchange");
    
    if (self.area == nil) {
        self.area = @"";
    }
    
    if (self.market == nil) {
        self.market = @"";
    }
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    int countStockExchange = 0;
    
    NSString *selectSql = [NSString stringWithFormat:@"select count(*) from stock_exchange_table"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        countStockExchange = [[columns valueForKey:@"0"] intValue];
    }
    
    if (countStockExchange == 0) {
        
        NSString *insertSql = nil;
        
        insertSql = [NSString stringWithFormat:@"insert into stock_exchange_table (area, market, code) values ('%@', '%@', '%@')", self.area, self.market, self.code];
            
        [dbUtility executeSQL:insertSql];
        
    } else {
        
        NSString *updateSql = nil;
        
        updateSql = [NSString stringWithFormat:@"update stock_exchange_table set area='%@', market='%@', code='%@'", self.area, self.market, self.code];
        
        [dbUtility executeSQL:updateSql];
        
        updateSql = [NSString stringWithFormat:@"update portfolio_detail_table set market_code='%@'", self.code];
        
        [dbUtility executeSQL:updateSql];
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)loadInitialData {
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectSql = [NSString stringWithFormat:@"select area, market, code from stock_exchange_table"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        self.area = [columns valueForKey:@"0"];
        self.market = [columns valueForKey:@"1"];
        self.code = [columns valueForKey:@"2"];
    }

    
    if ([self.area length] > 0) {
        [self.areaButton setTitle:NSLocalizedString(self.area, nil) forState:UIControlStateNormal];
        
        if ([self.area isEqualToString:@"americas"]) {
            self.marketRef = self.americasRef;
            self.marketArray = self.americasArray;
        } else if ([self.area isEqualToString:@"emea"]) {
            self.marketRef = self.emeaRef;
            self.marketArray = self.emeaArray;
        } else if ([self.area isEqualToString:@"asia-pacific"]) {
            self.marketRef = self.asiaPacificRef;
            self.marketArray = self.asiaPacificArray;
        } else {
            self.marketRef = self.noChoiceRef;
            self.marketArray = self.noChoiceArray;
        }

    } else {
        [self.areaButton setTitle:NSLocalizedString(@"-- Please Select --", nil) forState:UIControlStateNormal];
    }
    
    if ([self.market length] > 0) {
        [self.marketButton setTitle:NSLocalizedString(self.market, nil) forState:UIControlStateNormal];
    } else {
        [self.marketButton setTitle:NSLocalizedString(@"-- Please Select --", nil) forState:UIControlStateNormal];
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
        
        [self saveStockExchange];
    //}
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.areaRef = [[NSArray alloc] initWithObjects:@"-- Please Select --", @"americas", @"emea", @"asia-pacific", nil];
    self.areaArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"-- Please Select --", nil), NSLocalizedString(@"americas", nil), NSLocalizedString(@"emea", nil), NSLocalizedString(@"asia-pacific", nil), nil];
    
    // Americas
    self.americasRef = [[NSArray alloc] initWithObjects:@"-- Please Select --", @"united_states", @"mexico", @"canada", @"brazil", @"argentina", @"colombia", nil];
    
    self.americasArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"-- Please Select --", nil), NSLocalizedString(@"united_states", nil), NSLocalizedString(@"mexico", nil), NSLocalizedString(@"canada", nil), NSLocalizedString(@"brazil", nil), NSLocalizedString(@"argentina", nil), NSLocalizedString(@"colombia", nil), nil];
    
    // EMEA
    self.emeaRef = [[NSArray alloc] initWithObjects:@"-- Please Select --", @"france", @"germany", @"united_kingdom", @"greece", @"ireland", @"italy", @"netherlands", @"sweden", @"norway", @"switzerland", @"denmark", @"austria", @"portugal", @"spain", @"poland", @"russian_federation", @"turkey", @"israel", @"saudi_arabia", @"united_arab_emirates", @"nigeria", @"south_africa", nil];
    
    self.emeaArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"-- Please Select --", nil), NSLocalizedString(@"france", nil), NSLocalizedString(@"germany", nil), NSLocalizedString(@"united_kingdom", nil), NSLocalizedString(@"greece", nil), NSLocalizedString(@"ireland", nil), NSLocalizedString(@"italy", nil), NSLocalizedString(@"netherlands", nil), NSLocalizedString(@"sweden", nil), NSLocalizedString(@"norway", nil), NSLocalizedString(@"switzerland", nil), NSLocalizedString(@"denmark", nil), NSLocalizedString(@"austria", nil), NSLocalizedString(@"portugal", nil), NSLocalizedString(@"spain", nil), NSLocalizedString(@"poland", nil), NSLocalizedString(@"russian_federation", nil), NSLocalizedString(@"turkey", nil), NSLocalizedString(@"israel", nil), NSLocalizedString(@"saudi_arabia", nil), NSLocalizedString(@"united_arab_emirates", nil), NSLocalizedString(@"nigeria", nil), NSLocalizedString(@"south_africa", nil), nil];
    
    // Asia-Pacific
    self.asiaPacificRef = [[NSArray alloc] initWithObjects:@"-- Please Select --", @"australia", @"new_zealand", @"china", @"hong_kong", @"indonesia", @"india", @"japan", @"malaysia", @"philippines", @"republic_of_korea", @"taiwan", @"thailand", nil];
    
    self.asiaPacificArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"-- Please Select --", nil), NSLocalizedString(@"australia", nil), NSLocalizedString(@"new_zealand", nil), NSLocalizedString(@"china", nil), NSLocalizedString(@"hong_kong", nil), NSLocalizedString(@"indonesia", nil), NSLocalizedString(@"india", nil), NSLocalizedString(@"japan", nil), NSLocalizedString(@"malaysia", nil), NSLocalizedString(@"philippines", nil), NSLocalizedString(@"republic_of_korea", nil), NSLocalizedString(@"taiwan", nil), NSLocalizedString(@"thailand", nil), nil];
    
    
    self.noChoiceRef = [[NSArray alloc] initWithObjects:@"-- Please Select --", nil];
    self.noChoiceArray = [[NSArray alloc] initWithObjects:@"-- Please Select --", nil];
    
    self.marketRef = self.noChoiceRef;
    self.marketArray = self.noChoiceArray;
    
    
    self.marketCodeDict = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"US", @"MX", @"CA", @"BR", @"AR", @"CO", @"FR", @"DE", @"UK", @"GR", @"IE", @"IT", @"NL", @"SE", @"NO", @"CH", @"DK", @"AT", @"PT", @"ES", @"PL", @"RU", @"TR", @"IL", @"SA", @"AE", @"NG", @"ZA", @"AU", @"NZ", @"CN", @"HK", @"ID", @"IN", @"JP", @"MY", @"PH", @"KR", @"TW", @"TH", nil] forKeys:[[NSArray alloc] initWithObjects:@"united_states", @"mexico", @"canada", @"brazil", @"argentina", @"colombia", @"france", @"germany", @"united_kingdom", @"greece", @"ireland", @"italy", @"netherlands", @"sweden", @"norway", @"switzerland", @"denmark", @"austria", @"portugal", @"spain", @"poland", @"russian_federation", @"turkey", @"israel", @"saudi_arabia", @"united_arab_emirates", @"nigeria", @"south_africa", @"australia", @"new_zealand", @"china", @"hong_kong", @"indonesia", @"india", @"japan", @"malaysia", @"philippines", @"republic_of_korea", @"taiwan", @"thailand", nil]];
    
    [self.areaView setHidden:YES];
    [self.marketView setHidden:YES];
    
    UITapGestureRecognizer *dismissGestureRecognition1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAreaView)];
    dismissGestureRecognition1.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismissGestureRecognition1];
    
    UITapGestureRecognizer *dismissGestureRecognition2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMarketView)];
    dismissGestureRecognition2.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismissGestureRecognition2];
    
    
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
