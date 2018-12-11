//
//  KCProfileViewController.h
//  Stocks
//
//  Created by Kevin Choi on 10/5/14.
//  Copyright (c) 2014 Kevin Choi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCProfileViewController : UIViewController<UIAlertViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property NSString *name;
@property NSString *photo;
@property NSString *type;
@property NSString *share;
@property NSString *email;

@end
