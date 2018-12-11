//
//  KCStatisticsControlViewController.m
//  Stocks
//
//  Created by Kevin Choi on 12/6/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCStatisticsControlViewController.h"
#import "KCStatisticsTableViewController.h"
#import "KCBarChartViewController.h"
#import "KCSelectButton.h"

@interface KCStatisticsControlViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet KCSelectButton *yearButton;
@property (weak, nonatomic) IBOutlet UIView *yearView;

@property NSMutableArray *yearRef;

@end

@implementation KCStatisticsControlViewController

- (UIPickerView *)createPopOverPicker:(int) tag withWidth:(int) width withHeight:(int) height
{
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    pickerView.tag = tag;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    //pickerView.transform = CGAffineTransformMakeScale(1, 0.70);
    
    if (tag == 1) {
        [self.yearView addSubview:pickerView];
        [self.yearView setHidden:NO];
        
    }
    
    return pickerView;
    
}

- (IBAction)selectYear:(id)sender {
    
    UITapGestureRecognizer *dismissGestureRecognition1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissYearView)];
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
        NSLog(@"self.year=%@", self.year);
        NSLog(@"compare=%@", compare);
        if ([self.year isEqualToString:compare]){
            posY = i;
            break;
        }
        
    }
    
    [pickerView selectRow:posY inComponent:0 animated:NO];
    
}

- (void)dismissYearView
{
    
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        if([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            [self.view removeGestureRecognizer:recognizer];
        }
    }
    
    if (self.year == nil) {
        [self.yearButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"-- Year --", nil)] forState:UIControlStateNormal];
        
        KCStatisticsTableViewController *vc = nil;
        NSArray *childControllers = self.childViewControllers;
        for (UIViewController *childController in childControllers) {
            if (childController.title != nil && [childController.title isEqualToString:@"StatisticsTableView"]) {
                vc = (KCStatisticsTableViewController *) childController;
                vc.year = self.year;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatistics" object:nil];
    }
    
    if (![self.yearView isHidden]) {
        //[self moveContainerViewUp:YES distance:110];
        [self.containerView setHidden:NO];
    }
    
    self.selectView.frame = CGRectMake(self.selectView.frame.origin.x, self.selectView.frame.origin.y, self.selectView.frame.size.width, 40);
    
    NSArray *viewsToRemove = [self.yearView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [self.yearView setHidden:YES];
    
    //self.year = nil;
    
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (component == 0) {
        return [self.yearRef count];
        
    } else {
        return 0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        if (row == 0) {
            return NSLocalizedString(@"-- Year --", nil);
        } else {
            return [self.yearRef objectAtIndex:row];
        }
        
    } else {
        return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        //if (row > 0) {
            self.year = [self.yearRef objectAtIndex:row];
        //}
    
    } else {
        
    }
    
    if (self.year != nil) {
        
        KCStatisticsTableViewController *vc = nil;
        NSArray *childControllers = self.childViewControllers;
        for (UIViewController *childController in childControllers) {
            if (childController.title != nil && [childController.title isEqualToString:@"StatisticsTableView"]) {
                vc = (KCStatisticsTableViewController *) childController;
                if ([self.year isEqualToString:@"-- Year --"])
                    vc.year = nil;
                else
                    vc.year = self.year;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatistics" object:nil];
        
        [self.yearButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(self.year, nil)] forState:UIControlStateNormal];
        [self dismissYearView];
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
    
    [self.yearButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"-- Year --", nil)] forState:UIControlStateNormal];
    
    self.selectView.frame = CGRectMake(self.selectView.frame.origin.x, self.selectView.frame.origin.y, self.selectView.frame.size.width, 40);
    
    [self.yearView setHidden:YES];
    
    self.year = nil;


}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self performSegueWithIdentifier:@"BarChartSegue" sender:self];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"BarChartSegue"]) {
        NSLog(@"## BarChartSegue ##");
        
        KCStatisticsTableViewController *vc = nil;
        NSArray *childControllers = self.childViewControllers;
        for (UIViewController *childController in childControllers) {
            if (childController.title != nil && [childController.title isEqualToString:@"StatisticsTableView"]) {
                vc = (KCStatisticsTableViewController *) childController;
            }
        }
        
        KCBarChartViewController *bcVc = [segue destinationViewController];
        
        bcVc.year = vc.year;
        bcVc.stocks = [vc.stocks copy];
        
    }
}

- (void)moveContainerViewUp:(BOOL)up distance:(int)movementDistance
{
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"moveContainerViewUp" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.containerView.frame = CGRectOffset(self.containerView.frame, 0, movement);
    [UIView commitAnimations];
    
}

@end
