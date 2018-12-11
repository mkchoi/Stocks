//
//  KCProfileViewController.m
//  Stocks
//
//  Created by Kevin Choi on 10/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "KCProfileViewController.h"
#import "KCDBUtility.h"
#import "KCUtility.h"
#import "KCButton.h"
#import "KCEnvVar.h"


@interface KCProfileViewController()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIView *typeView;
@property (weak, nonatomic) IBOutlet KCButton *typeButton;
@property (weak, nonatomic) IBOutlet UISwitch *shareSwitch;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;


@property NSArray *typeRef;
@property NSArray *typeArray;
@property BOOL savedProfilePic;

@property UIAlertView *emailAlertView;
@property UITextField *emailTextField;

@end


@implementation KCProfileViewController

- (IBAction)syncServer:(id)sender {
    KCEnvVar *obj = [KCEnvVar getInstance];
    if ([self.shareSwitch isOn] && [obj.userEmail length] == 0) {
        
        self.emailAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email", nil)
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), NSLocalizedString(@"Cancel", nil), nil];
        
        self.emailAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        self.emailAlertView.tag = 1;
        
        self.emailTextField = [self.emailAlertView textFieldAtIndex:0];
        self.emailTextField.delegate = self;
        self.emailTextField.placeholder = NSLocalizedString(@"Enter your email", nil);
        [self.emailTextField setSecureTextEntry:NO];
        [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
        
        
        [self.emailAlertView show];

    } else if ([self.shareSwitch isOn]) {
        KCDBUtility *dbUtility = [KCDBUtility newInstance];
        
        NSString *updateSql = nil;
        
        updateSql = [NSString stringWithFormat:@"update user_table set share='%@' where id=1", @"YES"];
        
        [dbUtility executeSQL:updateSql];
        
        self.share = @"YES";
        obj.syncWithServer = self.share;

        
    } else {
        KCDBUtility *dbUtility = [KCDBUtility newInstance];
        
        NSString *updateSql = nil;
        
        updateSql = [NSString stringWithFormat:@"update user_table set email='', share='%@' where id=1", @"NO"];
        
        [dbUtility executeSQL:updateSql];
        
        self.share = @"NO";
        obj.syncWithServer = self.share;
        obj.userEmail = nil;
        
        [self.emailLabel setText:@""];
    }
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1) {
        NSLog(@"Email=%@", [alertView textFieldAtIndex:0].text);
        
        KCEnvVar *obj = [KCEnvVar getInstance];

        if (buttonIndex == 0) {
            NSLog(@"OK email!");
            
            if ([self.emailTextField.text length] > 0) {
                
                KCDBUtility *dbUtility = [KCDBUtility newInstance];
                
                NSString *updateSql = nil;
                
                updateSql = [NSString stringWithFormat:@"update user_table set email='%@', share='%@' where id=1", self.emailTextField.text, @"YES"];
                
                [dbUtility executeSQL:updateSql];
                
                self.share = @"YES";
                obj.syncWithServer = self.share;
                obj.userEmail = self.emailTextField.text;
                
                [self.emailLabel setText:obj.userEmail];
                [self.emailLabel setHidden:NO];
                
            } else {
                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"Please enter your email.", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                          otherButtonTitles: nil];
                
                [errorView show];
                
            }
            
            
        } else {
            NSLog(@"Not sync!");
            
            self.share = @"NO";
            obj.syncWithServer = self.share;
            [self.shareSwitch setOn:NO];
            
        }
        
    }
}

- (IBAction)browsePhoto:(id)sender {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                              message:NSLocalizedString(@"Device has no photo library.", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        imagePicker.allowsEditing = YES;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
        
    UIImage *image =  [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self.photoButton setImage:image forState:UIControlStateNormal];
    
    NSData *imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(image, 1)];
    NSString *imgContent = [imageData base64EncodedStringWithOptions:0];
    imgContent = [imgContent stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    imgContent = [imgContent stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    imgContent = [imgContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:@"profile_pic.jpg"];
    
    if (![imageData writeToFile:imagePath atomically:NO])
    {
        NSLog((@"Failed to save image to disk"));
        self.savedProfilePic = NO;
    }
    else
    {
        NSLog(@"The image path is %@", imagePath);
        self.savedProfilePic = YES;
    }
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIPickerView *)createPopOverPicker:(int) tag withWidth:(int) width withHeight:(int) height
{

    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    pickerView.tag = tag;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    [self.typeView addSubview:pickerView];
    [self.typeView setHidden:NO];
       
    return pickerView;
    
}

- (IBAction)selectType:(id)sender {
    
    int width = 250;
    int height = 150;
    
    UIPickerView *pickerView = [self createPopOverPicker:1 withWidth:width withHeight:height];
    
    int pos = 0;
    for(int i=0; i<[self.typeRef count]; i++) {
        NSString *compare = [self.typeRef objectAtIndex:i];
        NSLog(@"compare=%@", compare);
        if ([self.type isEqualToString:compare]){
            pos = i;
            break;
        }
        
    }
    
    [pickerView selectRow:pos inComponent:0 animated:NO];
    
}

- (void)dismissTypeView {
    
    NSArray *viewsToRemove = [self.typeView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [self.typeView setHidden:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (pickerView.tag == 1) {
        return [self.typeArray count];
    } else {
        return 0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        return [self.typeArray objectAtIndex:row];
    } else {
        return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView.tag == 1) {
        self.type = [self.typeRef objectAtIndex:row];
        [self.typeButton setTitle:[self.typeArray objectAtIndex:row] forState:UIControlStateNormal];
        [self dismissTypeView];
    } else {
        
    }

}

- (void)saveProfile {
    
    NSLog(@"Save Profile");
    
    if (self.type == nil) {
        self.type = @"";
    }
    
    if ([self.shareSwitch isOn]) {
        self.share = @"YES";
    } else {
        self.share = @"NO";
    }
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    int countProfile = 0;
    
    NSString *selectSql = [NSString stringWithFormat:@"select count(*) from user_table"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        countProfile = [[columns valueForKey:@"0"] intValue];
    }
   
    if (countProfile == 0) {
        
        NSString *insertSql = nil;
        
        if (self.savedProfilePic) {
        
            insertSql = [NSString stringWithFormat:@"insert into user_table (name, photo, type, share, create_time) values ('%@', '%@', '%@', '%@', '%@')", self.nameField.text, @"profile_pic.jpg", self.type, self.share, [KCUtility getTodayStr]];
            
        } else {
            
            insertSql = [NSString stringWithFormat:@"insert into user_table (name, type, share, create_time) values ('%@', '%@', '%@', '%@')", self.nameField.text, self.type, self.share, [KCUtility getTodayStr]];

        }
        
        [dbUtility executeSQL:insertSql];
        
    } else {
        
        NSString *updateSql = nil;
        
        if (self.savedProfilePic) {
        
            updateSql = [NSString stringWithFormat:@"update user_table set name='%@', photo='%@', type='%@', share='%@', create_time='%@' where id=1", self.nameField.text, @"profile_pic.jpg", self.type, self.share, [KCUtility getTodayStr]];
            
        } else {
            
            updateSql = [NSString stringWithFormat:@"update user_table set name='%@', type='%@', share='%@', create_time='%@' where id=1", self.nameField.text, self.type, self.share, [KCUtility getTodayStr]];

        }
        
        [dbUtility executeSQL:updateSql];
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //}
    
    
}


- (void)loadInitialData {
    
    KCDBUtility *dbUtility = [KCDBUtility newInstance];
    
    NSString *selectSql = [NSString stringWithFormat:@"select name, photo, type, share, email from user_table where id=1"];
    
    NSMutableArray *result = [dbUtility resultSQL:selectSql];
    for (int i=0; i<[result count]; i++) {
        NSMutableDictionary *columns = (NSMutableDictionary *)[result objectAtIndex:i];
        self.name = [columns valueForKey:@"0"];
        self.photo = [columns valueForKey:@"1"];
        self.type = [columns valueForKey:@"2"];
        self.share = [columns valueForKey:@"3"];
        self.email = [columns valueForKey:@"4"];
    }
    
    KCEnvVar *obj = [KCEnvVar getInstance];
    
    if ([self.photo length] > 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:@"profile_pic.jpg"];
        [self.photoButton setImage:[UIImage imageWithContentsOfFile:imagePath] forState:UIControlStateNormal];
    } else {
        [self.photoButton setImage:[UIImage imageNamed:@"profile-100.png"] forState:UIControlStateNormal];
    }
    
    if ([self.name length] > 0 && ![self.name isEqualToString:@"ANONYMOUS"]) {
        self.nameField.text = self.name;
    }
    
    if ([self.type length] > 0) {
        [self.typeButton setTitle:NSLocalizedString(self.type, nil) forState:UIControlStateNormal];
    } else {
        [self.typeButton setTitle:NSLocalizedString(@"-- Please Select --", nil) forState:UIControlStateNormal];
    }
    
    if ([self.share length] > 0 && [self.share isEqualToString:@"YES"]) {
        [self.shareSwitch setOn:YES];
        
        obj.syncWithServer = self.share;
    } else {
        obj.syncWithServer = self.share;
        [self.shareSwitch setOn:NO];
    }
    
    if ([self.email length] > 0) {
        [self.emailLabel setText:self.email];
        [self.emailLabel setHidden:NO];
        
        obj.userEmail = self.email;
        
    } else {
        [self.emailLabel setHidden:YES];
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
        [self saveProfile];
    //}
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.nameField.delegate = self;
    
    self.typeRef = [[NSArray alloc] initWithObjects:@"-- Please Select --", @"aggressive", @"balance", @"conservative", nil];
    self.typeArray  = [[NSArray alloc] initWithObjects:NSLocalizedString(@"-- Please Select --", nil), NSLocalizedString(@"aggressive", nil), NSLocalizedString(@"balance", nil), NSLocalizedString(@"conservative", nil), nil];
    
    
    UITapGestureRecognizer *dismissGestureRecognition = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTypeView)];
    dismissGestureRecognition.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismissGestureRecognition];
    
    
    [self loadInitialData];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
