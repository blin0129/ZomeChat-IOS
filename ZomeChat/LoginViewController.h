//
//  LoginViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "AppDelegate.h"

@interface LoginViewController : UIViewController<SocketIODelegate,UITextFieldDelegate>
{
    SocketIO *socketIO;
}

@property (retain, nonatomic) IBOutlet UITextField *usernameInput;
@property (retain, nonatomic) IBOutlet UITextField *passwordInput;

@property (weak, nonatomic) IBOutlet UITextField *signupPassword;
@property (weak, nonatomic) IBOutlet UITextField *signupPasswordC;
@property (weak, nonatomic) IBOutlet UITextField *signupEmail;
@property (weak, nonatomic) IBOutlet UITextField *singupUsername;
@property (weak, nonatomic) IBOutlet UIButton *toLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *toSignupButton;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *registerLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *anonLoginButton;
@property (nonatomic) CLLocation *currentLocation;

- (IBAction)backgroundTouched:(id)sender;
- (IBAction)registerLogin:(id)sender;
- (IBAction)anonymousLogin:(id)sender;
- (IBAction)signUp:(id)sender;

@end
