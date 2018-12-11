//
//  KCDisplayViewController.m
//  Stocks
//
//  Created by Kevin Choi on 4/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCDisplayViewController.h"
#import "KCDBUtility.h"
#import "KCSelectButton.h"

@interface KCDisplayViewController ()

@property (weak, nonatomic) IBOutlet UIView *colourView;
@property (weak, nonatomic) IBOutlet KCSelectButton *colourButton;
@property (weak, nonatomic) IBOutlet UISwitch *addTradingFeeSwitch;

@property NSArray *colourRef;
@property NSArray *colourArray;

@end

@implementation KCDisplayViewController

- (UIPickerView *)createPopOverPicker:(int) tag withWidth:(int) width withHeight:(int) height
{
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    pickerView.tag = tag;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    
    
    if (tag == 1) {
        [self.colourView addSubview:pickerView];
        [self.colourView setHidden:NO];
        
    }
    
    return pickerView;
    
}

- (IBAction)selectColour:(id)sender {
    
    int width = 222;
    int height = 150;
    
    UIPickerView *pickerView = [self createPopOverPicker:1 withWidth:width withHeight:height];
    
    int pos = 0;
    for(int i=0; i<[self.colourRef count]; i++) {
        NSString *compare = [self.colourRef objectAtIndex:i];
        NSLog(@"compare=%@", compare);
        if ([compare isEqualToString:@"greenAsRise"]) {
            compare = @"YES";
        } else {
            compare = @"NO";
        }
        if ([self.greenAsRise isEqualToString:compare]){
            pos = i;
            break;
        }
        
    }
    
    [pickerView selectRow:pos inComponent:0 animated:NO];
    
}

- (void)dismissColourView
{
    NSArray *viewsToRemove = [self.colourView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [self.colourView setHidden:YES];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (pickerView.tag == 1) {
        return [self.colourArray count];
        
    } else {
        return 0;
    }
}

/*
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        return [self.colourArray objectAtIndex:row];
    
    } else {
        return @"";
    }
}
*/

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *tView = (UILabel *)view;
    if (!tView) {
        tView = [[UILabel alloc] initWithFrame:pickerView.frame];
    }
    
    tView.textAlignment = NSTextAlignmentCenter;
    tView.adjustsFontSizeToFitWidth = YES;
    
    if (pickerView.tag == 1) {
        NSMutableAttributedString *colourScheme = [[NSMutableAttributedString alloc] initWithString:[self.colourArray objectAtIndex:row]];
        int length = (int)colourScheme.length;
        
        if ([[self.colourArray objectAtIndex:row] isEqualToString:NSLocalizedString(@"greenAsRise", nil)]) {
            [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, 13)];
            [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(13, length-13)];
        } else {
            [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 13)];
            [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(13, length-13)];
        }
        
        tView.attributedText = colourScheme;
        
        //tView.text = [self.colourArray objectAtIndex:row];
    } else {
        tView.text = @"";
    }
    
    return tView;

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView.tag == 1) {
        if ([[self.colourArray objectAtIndex:row] isEqualToString:NSLocalizedString(@"greenAsRise", nil)]) {
            self.greenAsRise = @"YES";
            
            NSMutableAttributedString *colourScheme = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"greenAsRise", nil)];
            int length = (int)colourScheme.length;
            [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, 13)];
            [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(13, length-13)];
            
            [self.colourButton setAttributedTitle:colourScheme forState:UIControlStateNormal];
        } else {
            self.greenAsRise = @"NO";
            
            NSMutableAttributedString *colourScheme = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"redAsRise", nil)];
            int length = (int)colourScheme.length;
            [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 13)];
            [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(13, length-13)];
            
            [self.colourButton setAttributedTitle:colourScheme forState:UIControlStateNormal];
            
        }
        
        //[self.colourButton setTitle:[self.colourArray objectAtIndex:row] forState:UIControlStateNormal];
        
        [self dismissColourView];
 
    } else {
        
    }
    
}

- (void)saveDisplay
{
    NSLog(@"Save Display");
    
    if ([self.addTradingFeeSwitch isOn]) {
        self.addTradingFee = @"YES";
    } else {
        self.addTradingFee = @"NO";
    }
    
    if (self.greenAsRise == nil) {
        self.greenAsRise = @"YES";
    }
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    int countUser = 0;
    
    NSString *selectSql = [NSString stringWithFormat:@"select count(*) from user_table where id=1"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        countUser = [[columns valueForKey:@"0"] intValue];
    }
    
    if (countUser == 0) {
        
        NSString *insertSql = nil;
        
        insertSql = [NSString stringWithFormat:@"insert into user_table (add_trading_fee, green_as_rise) values ('%@', '%@')", self.addTradingFee, self.greenAsRise];
        
        [dbUtility executeSQL:insertSql];
        
    } else {
        
        NSString *updateSql = nil;
        
        updateSql = [NSString stringWithFormat:@"update user_table set add_trading_fee='%@', green_as_rise='%@' where id=1", self.addTradingFee, self.greenAsRise];
        
        [dbUtility executeSQL:updateSql];
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatistics" object:nil];
}

- (void)loadInitialData
{
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectSql = [NSString stringWithFormat:@"select add_trading_fee, green_as_rise from user_table where id=1"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        self.addTradingFee = [columns valueForKey:@"0"];
        self.greenAsRise = [columns valueForKey:@"1"];
    }
    
    if ([self.addTradingFee length] > 0 && [self.addTradingFee isEqualToString:@"NO"]) {
        [self.addTradingFeeSwitch setOn:NO];
    } else {
        [self.addTradingFeeSwitch setOn:YES];
    }
    
    if ([self.greenAsRise length] > 0 && [self.greenAsRise isEqualToString:@"YES"]) {
        NSMutableAttributedString *colourScheme = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"greenAsRise", nil)];
        int length = (int)colourScheme.length;
        [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, 13)];
        [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(13, length-13)];

        [self.colourButton setAttributedTitle:colourScheme forState:UIControlStateNormal];
        //[self.colourButton setTitle:NSLocalizedString(@"greenAsRise", nil) forState:UIControlStateNormal];
    } else {
        NSMutableAttributedString *colourScheme = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"redAsRise", nil)];
        int length = (int)colourScheme.length;
        [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 13)];
        [colourScheme addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(13, length-13)];

        [self.colourButton setAttributedTitle:colourScheme forState:UIControlStateNormal];
        //[self.colourButton setTitle:NSLocalizedString(@"redAsRise", nil) forState:UIControlStateNormal];
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
        
        [self saveDisplay];
    //}
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colourRef = [[NSArray alloc] initWithObjects:@"greenAsRise", @"redAsRise", nil];
    self.colourArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"greenAsRise", nil), NSLocalizedString(@"redAsRise", nil), nil];
    
    [self.colourView setHidden:YES];
    
    UITapGestureRecognizer *dismissGestureRecognition1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissColourView)];
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

@end
