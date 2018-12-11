//
//  KCSettingTableViewController.m
//  Stocks
//
//  Created by Kevin Choi on 14/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import "KCSettingTableViewController.h"

@interface KCSettingTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *tellFriendTblCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *serverStatusTblCell;

@end

@implementation KCSettingTableViewController

- (void)getServerStatus
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://192.168.59.103:8080/stocks-backend/json/serviceStatus.do"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSLog(@"%@", [request.URL absoluteString]);
    
    NSMutableAttributedString *serverStatus = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Server Status Connecting...", nil)];
    int length = (int)NSLocalizedString(@"Server Status Connecting...", nil).length;
    //NSLog(@"%d", length);
    
    [serverStatus addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 15)];
    [serverStatus addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(16, length-16)];
    
    self.serverStatusTblCell.textLabel.attributedText = serverStatus;
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if ([data length] >0 && error == nil)
         {
             
             NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"serverStatus=%@", responseString);
             
             NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
             
             NSString *result = [jsonDictionary valueForKey:@"result"];
             if ([result isEqualToString:@"ok"]) {
                 
                 NSMutableAttributedString *serverStatus = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Server Status Connected", nil)];
                 int length = (int)NSLocalizedString(@"Server Status Connected", nil).length;
                 NSLog(@"%d", length);
                 
                 [serverStatus addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 15)];
                 [serverStatus addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(16, length-16)];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.serverStatusTblCell.textLabel.attributedText = serverStatus;
                 });
             } else {
                 
                 NSMutableAttributedString *serverStatus = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Server Status Disconnected", nil)];
                 int length = (int)NSLocalizedString(@"Server Status Disconnected", nil).length;
                 NSLog(@"%d", length);
                 
                 [serverStatus addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 15)];
                 [serverStatus addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(16, length-16)];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.serverStatusTblCell.textLabel.attributedText = serverStatus;
                 });
             }
             
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"serverStatus: Nothing was downloaded.");
             
             NSMutableAttributedString *serverStatus = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Server Status Disconnected", nil)];
             int length = (int)NSLocalizedString(@"Server Status Disconnected", nil).length;
             NSLog(@"%d", length);
             
             [serverStatus addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 15)];
             [serverStatus addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(16, length-16)];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.serverStatusTblCell.textLabel.attributedText = serverStatus;
             });
         }
         else if (error != nil){
             NSLog(@"serverStatus: Error = %@", error);
             
             NSMutableAttributedString *serverStatus = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Server Status Disconnected", nil)];
             int length = (int)NSLocalizedString(@"Server Status Disconnected", nil).length;
             NSLog(@"%d", length);
             
             [serverStatus addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 15)];
             [serverStatus addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(16, length-16)];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.serverStatusTblCell.textLabel.attributedText = serverStatus;
             });
         }
         
     }];

}

- (void)tellFriend
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:
                                  NSLocalizedString(@"Message", nil),
                                  NSLocalizedString(@"Email", nil), nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    if ([window.subviews containsObject:self.view]) {
        [actionSheet showInView:self.view];
    } else {
        [actionSheet showInView:window];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Message", nil)]) {
        [self sendSMS];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Email", nil)]) {
        [self sendEmail];
    } else {
        
    }
}


- (void)sendSMS
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.title = @"Tell a friend";
        controller.body = NSLocalizedString(@"Hi friend, this app [Stocks] is worth to try! Check it out at ", nil);
        //controller.recipients = [NSArray arrayWithObjects:@""];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"SMS sending canceled");
			break;
		case MessageComposeResultFailed: {
            NSLog(@"SMS failed");
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"Failed to send your SMS!", nil)
														   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
			[alert show];
			break;
        }
		case MessageComposeResultSent: {
            NSLog(@"SMS sent");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"Your SMS is sent successfully!", nil)
														   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
			[alert show];
			break;
        }
		default:
			break;
	}
    
	[controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)sendEmail {
    
    NSString *emailTitle = @"Tell a friend";
    // Change the message body to HTML
    NSString *messageBody = @"Hi friend, this app [Stocks] is worth to try! Check it out at ";

    //NSArray *toRecipents = [NSArray arrayWithObject:@""];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    //[mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail sending canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sending failed");
            break;
        default:
            NSLog(@"Mail not sent");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *theTblCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (theTblCell == self.tellFriendTblCell) {
        [self tellFriend];
        [self.tableView reloadData];
    } else if (theTblCell == self.serverStatusTblCell) {
        [self getServerStatus];
        [self.tableView reloadData];
    }
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
    [self getServerStatus];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
