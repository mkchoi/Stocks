//
//  KCHistoryControlViewController.m
//  Stocks
//
//  Created by Kevin Choi on 11/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCHistoryControlViewController.h"
#import "KCHistoryTableViewController.h"
#import "KCSelectButton.h"

@interface KCHistoryControlViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UIView *yearMonthView;
@property (weak, nonatomic) IBOutlet KCSelectButton *yearMonthButton;

@property NSMutableArray *yearRef;
@property NSArray *monthRef;
@property NSArray *monthArray;

@end

@implementation KCHistoryControlViewController

- (UIPickerView *)createPopOverPicker:(int) tag withWidth:(int) width withHeight:(int) height
{
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    pickerView.tag = tag;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    //pickerView.transform = CGAffineTransformMakeScale(1, 0.70);
    
    if (tag == 1) {
        [self.yearMonthView addSubview:pickerView];
        [self.yearMonthView setHidden:NO];
        
    }
    
    return pickerView;
    
}

- (IBAction)selectYearMonth:(id)sender {
    
    UITapGestureRecognizer *dismissGestureRecognition1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissYearMonthView)];
    dismissGestureRecognition1.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismissGestureRecognition1];
    
    //[self moveContainerViewUp:NO distance:110];
    [self.containerView setHidden:YES];
    
    self.selectView.frame = CGRectMake(self.selectView.frame.origin.x, self.selectView.frame.origin.y, self.selectView.frame.size.width, 160);
    
    int width = 320;
    int height = 150;
    
    UIPickerView *pickerView = [self createPopOverPicker:1 withWidth:width withHeight:height];
    
    int posY = 0;
    for(int i=0; i<[self.yearRef count]; i++) {
        NSString *compare = [self.yearRef objectAtIndex:i];
        NSLog(@"compare=%@", compare);
        if ([self.year isEqualToString:compare]){
            posY = i;
            break;
        }
        
    }
    
    int posM = 0;
    for(int i=0; i<[self.monthRef count]; i++) {
        NSString *compare = [self.monthRef objectAtIndex:i];
        NSLog(@"compare=%@", compare);
        if ([self.month isEqualToString:compare]){
            posM = i;
            break;
        }
        
    }
    
    [pickerView selectRow:posY inComponent:1 animated:NO];

    [pickerView selectRow:posM inComponent:0 animated:NO];
    
    
}

- (void)dismissYearMonthView
{
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        if([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            [self.view removeGestureRecognizer:recognizer];
        }
    }
    
    if (self.year == nil && self.month == nil) {
        [self.yearMonthButton setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"-- Month --", nil), NSLocalizedString(@"-- Year --", nil)] forState:UIControlStateNormal];
        
        KCHistoryTableViewController *vc = nil;
        NSArray *childControllers = self.childViewControllers;
        for (UIViewController *childController in childControllers) {
            if (childController.title != nil && [childController.title isEqualToString:@"HistoryTableView"]) {
                vc = (KCHistoryTableViewController *) childController;
                vc.year = self.year;
                vc.month = self.month;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshHistory" object:nil];
    }
    
    if (![self.yearMonthView isHidden]) {
        //[self moveContainerViewUp:YES distance:110];
        [self.containerView setHidden:NO];
    }
    
    self.selectView.frame = CGRectMake(self.selectView.frame.origin.x, self.selectView.frame.origin.y, self.selectView.frame.size.width, 40);
    
    NSArray *viewsToRemove = [self.yearMonthView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [self.yearMonthView setHidden:YES];
    
    //self.year = nil;
    //self.month = nil;
    
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (component == 1) {
        return [self.yearRef count];
        
    } else if (component == 0) {
        return [self.monthArray count];
        
    } else {
        return 0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 1) {
        if (row == 0) {
            return NSLocalizedString(@"-- Year --", nil);
        } else {
            return [self.yearRef objectAtIndex:row];
        }
        
        
    } else if (component == 0) {
        return [self.monthArray objectAtIndex:row];
        
    } else {
        return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 1) {
        if (row > 0) {
            self.year = [self.yearRef objectAtIndex:row];
        } else {
            self.year = [self.yearRef objectAtIndex:row];
            self.month = [self.monthRef objectAtIndex:row];
        }
        
    } else if (component == 0) {
        if (row > 0) {
            self.month = [self.monthRef objectAtIndex:row];
        } else {
            self.year = [self.yearRef objectAtIndex:row];
            self.month = [self.monthRef objectAtIndex:row];
        }
        
    } else {
        
    }
    
    if (self.year != nil && self.month != nil) {
        
        KCHistoryTableViewController *vc = nil;
        NSArray *childControllers = self.childViewControllers;
        for (UIViewController *childController in childControllers) {
            if (childController.title != nil && [childController.title isEqualToString:@"HistoryTableView"]) {
                vc = (KCHistoryTableViewController *) childController;
                if ([self.year isEqualToString:@"-- Year --"])
                    vc.year = nil;
                else
                    vc.year = self.year;
                
                if ([self.month isEqualToString:@"-- Month --"])
                    vc.month = nil;
                else
                    vc.month = self.month;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshHistory" object:nil];

        [self.yearMonthButton setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(self.month, nil), self.year] forState:UIControlStateNormal];
        [self dismissYearMonthView];
    }
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
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
    
    NSDate *curDate = [[NSDate alloc] init];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Extract date components into components1
    NSDateComponents *components1 = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:curDate];
    
    self.yearRef = [[NSMutableArray alloc] initWithObjects:@"-- Year --", nil];
    
    if ([self.yearRef count] <= 20) {
        for (long i=components1.year; i>components1.year-20; i--) {
            [self.yearRef addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    
    self.monthRef = [[NSArray alloc] initWithObjects:@"-- Month --", @"jan", @"feb", @"mar", @"apr", @"may", @"jun", @"jul", @"aug", @"sep", @"oct", @"nov", @"dec", nil];
    self.monthArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"-- Month --", nil), NSLocalizedString(@"jan", nil), NSLocalizedString(@"feb", nil), NSLocalizedString(@"mar", nil), NSLocalizedString(@"apr", nil), NSLocalizedString(@"may", nil), NSLocalizedString(@"jun", nil), NSLocalizedString(@"jul", nil), NSLocalizedString(@"aug", nil), NSLocalizedString(@"sep", nil), NSLocalizedString(@"oct", nil), NSLocalizedString(@"nov", nil), NSLocalizedString(@"dec", nil), nil];
    
    [self.yearMonthButton setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"-- Month --", nil), NSLocalizedString(@"-- Year --", nil)] forState:UIControlStateNormal];
    
    self.selectView.frame = CGRectMake(self.selectView.frame.origin.x, self.selectView.frame.origin.y, self.selectView.frame.size.width, 40);
    
    [self.yearMonthView setHidden:YES];
    
    self.year = nil;
    self.month = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)moveContainerViewUp:(BOOL)up distance:(int)movementDistance
{
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"moveContainerViewUp" context: nil];
    //[UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.containerView.frame = CGRectOffset(self.containerView.frame, 0, movement);
    [UIView commitAnimations];

}


@end
