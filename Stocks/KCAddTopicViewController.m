//
//  KCAddTopicViewController.m
//  Stocks
//
//  Created by Kevin Choi on 16/2/15.
//  Copyright (c) 2015 Kevin Choi. All rights reserved.
//

#import "KCAddTopicViewController.h"
#import "KCTextView.h"
#import "KCDBUtility.h"
#import "KCEnvVar.h"
#import "KCUtility.h"

@interface KCAddTopicViewController ()

@property (weak, nonatomic) IBOutlet KCTextView *addTopicTextView;

@end

@implementation KCAddTopicViewController

- (IBAction)addTopic:(id)sender {
    
    if ([self.addTopicTextView.text length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"Please enter topic.", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];

        return;
    }
    
    KCEnvVar *obj = [KCEnvVar getInstance];
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *insertSql = nil;
    
    insertSql = [NSString stringWithFormat:@"insert into forum_topic_table (topic_name, user_email, create_time) values ('%@', '%@', '%@')", self.addTopicTextView.text, obj.userEmail, [KCUtility getTodayStr]];
    
    [dbUtility executeSQL:insertSql];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDiscussion" object:nil];
        
    }];

    
}

- (IBAction)cancelAddTopic:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard
{
    if ([self.addTopicTextView isFirstResponder]) {
        [self.addTopicTextView resignFirstResponder];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *dismissGestureRecognition1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    dismissGestureRecognition1.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismissGestureRecognition1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
