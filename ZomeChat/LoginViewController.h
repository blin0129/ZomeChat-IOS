//
//  LoginViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "ZomeChat-Swift.h"
#import "AppDelegate.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate,FBLoginViewDelegate>

@property (retain, nonatomic) IBOutlet UITextField *emailInput;
@property (retain, nonatomic) IBOutlet UITextField *passwordInput;
@property (nonatomic, strong) SocketIOClient *socketIO;

@property (weak, nonatomic) IBOutlet UITextField *signupPassword;
@property (weak, nonatomic) IBOutlet UITextField *signupPasswordC;
@property (weak, nonatomic) IBOutlet UITextField *signupEmail;
@property (weak, nonatomic) IBOutlet UIButton *toLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *toSignupButton;
@property (weak, nonatomic) IBOutlet UIButton *anonLoginButton;
@property (nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (strong, nonatomic) FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *statusLabel;

- (IBAction)registerLogin:(id)sender;
- (IBAction)anonymousLogin:(id)sender;
- (IBAction)signUp:(id)sender;

@end
