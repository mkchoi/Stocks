//
//  KCRankingViewController.m
//  Stocks
//
//  Created by Kevin Choi on 12/2/15.
//  Copyright (c) 2015 Kevin Choi. All rights reserved.
//

#import "KCRankingViewController.h"

@interface KCRankingViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *rankingWebView;
@end

@implementation KCRankingViewController

- (void)viewWillAppear:(BOOL)animated
{
    NSURL *targetUrl = [NSURL URLWithString:@"http://192.168.59.103:8080/stocks-backend/device/ranking"];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetUrl];
    //[self.noticeWebView setScalesPageToFit:YES];
    [self.rankingWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
