//
//  LoginViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController (){
    NSString *loginEmail;
    NSString *loginPassword;
    UIImageView *backgroundIV;
}

@end

@implementation LoginViewController
@synthesize passwordInput;
@synthesize emailInput;
@synthesize socketIO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set socketIO listener
    socketIO = APPDELEGATE.socketIO;
    [self socketOnRecievedData];
    
    //Background
    backgroundIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-darkblue@x2.png"]];
    backgroundIV.frame = self.view.bounds;
    [self.view addSubview:backgroundIV];
    [self initLoginView];
    
    //Display saved email/password
    NSString *savedEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedEmail"];
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedPassword"];
    emailInput.text = savedEmail;
    passwordInput.text = savedPassword;
    
    //Auto login
    NSString *previousLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"];
    if(previousLogin != nil){
        if ([previousLogin isEqualToString:@"REGISTER"]){
            if(![savedEmail isEqual:[NSNull null]] && [savedPassword isEqual:[NSNull null]]){
                [self requestRegisterLoginWithEmail:savedEmail password:savedPassword];
                //        [self.view bringSubviewToFront:backgroundIV];
                [self performSelector:@selector(loginFail) withObject:nil afterDelay:3.0];
            }
        } else if([previousLogin isEqualToString:@"FACEBOOK"]){
            [self.view bringSubviewToFront:backgroundIV];
            [self performSelector:@selector(loginFail) withObject:nil afterDelay:3.0];
        }
    }
}

- (void) initLoginView{
//    [self initFacebookLogin];
    [self.view sendSubviewToBack:backgroundIV];

    //Buttons
    _toLoginButton.layer.borderWidth = 2;
    _toLoginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _toLoginButton.layer.cornerRadius = 8;
    _toLoginButton.layer.masksToBounds = YES;
    
    _toSignupButton.layer.borderWidth = 2;
    _toSignupButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _toSignupButton.layer.cornerRadius = 8;
    _toSignupButton.layer.masksToBounds = YES;
    
    _anonLoginButton.layer.borderWidth = 2;
    _anonLoginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _anonLoginButton.layer.cornerRadius = 8;
    _anonLoginButton.layer.masksToBounds = YES;
    
    emailInput.delegate = self;
    passwordInput.delegate = self;
    _signupPassword.delegate = self;
    _signupPasswordC.delegate = self;
    _signupEmail.delegate = self;
    
    if([CLLocationManager locationServicesEnabled]){
        _currentLocation = APPDELEGATE.locationManager.location;
    }

}

- (void) loginFail
{
    if(self.isViewLoaded && self.view.window){
        [self showAlertWithTitle:@"Login Fail" message:@"Connection Timeout"];
        [self.view sendSubviewToBack:backgroundIV];
    }
}

- (void) viewDidAppear:(BOOL)animated{
    //Auto fillin name and password
    NSString *savedEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedEmail"];
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedPassword"];
    if (savedEmail != nil && savedPassword != nil){
        emailInput.text = savedEmail;
        passwordInput.text = savedPassword;
    }
}

- (void) viewDidDisappear:(BOOL)animated{
//    fbLoginView.delegate = Nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField){
        [textField resignFirstResponder];
    }
    return NO;
}

- (IBAction)facebookLogin:(id)sender {
    NSString* fbid = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBid"];
    NSLog(@"facebookLogin clicked %@",fbid);
    if(fbid == nil){
        NSLog(@"access facebook info");
        [self accessFacebookInfo];
    }else{
        NSLog(@"request facebook login");
        [self requestFacebookLogin];
    }
}

- (void) accessFacebookInfo{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            [self showAlertWithTitle:@"Facebook Login Fail" message:[error localizedDescription]];
        } else if (result.isCancelled) {
            [self showAlertWithTitle:@"Facebook Login Fail" message:@"Request canceled"];
        } else {
            if ([result.grantedPermissions containsObject:@"email"] && [result.grantedPermissions containsObject:@"public_profile"]) {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error){
                    if (error) {
                        [self showAlertWithTitle:@"Facebook Login Fail" message:[error localizedDescription]];
                    } else{
                        NSString *fbThumbnailURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", result[@"id"]];
                        [[NSUserDefaults standardUserDefaults] setObject:fbThumbnailURL forKey:@"FBthumbnailURL"];
                        [[NSUserDefaults standardUserDefaults] setObject:result[@"id"] forKey:@"FBid"];
                        [[NSUserDefaults standardUserDefaults] setObject:result[@"email"] forKey:@"FBemail"];
                        [[NSUserDefaults standardUserDefaults] setObject:result[@"link"] forKey:@"FBlink"];
                        [[NSUserDefaults standardUserDefaults] setObject:result[@"first_name"] forKey:@"FBname"];
                        [self requestFacebookLogin];
                    }
                }];
            }
        }
    }];
}


- (IBAction)registerLogin:(id)sender {
    [self setButtonsDisable];
    [self performSelector:@selector(setButtonsEnable) withObject:nil afterDelay:2.0];
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        [self showAlertWithTitle:@"Location Service disabled" message:@"Please turn on Location Services in your device setting"];
    } else {
        loginEmail = self.emailInput.text;
        loginPassword = self.passwordInput.text;
        [self requestRegisterLoginWithEmail:loginEmail password:loginPassword ];
    }
}

- (IBAction)anonymousLogin:(id)sender {
    [self setButtonsDisable];
    [self performSelector:@selector(setButtonsEnable) withObject:nil afterDelay:2.0];
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        [self showAlertWithTitle:@"Location Service disabled" message:@"Please turn on Location Services in your device setting"];
    } else {
        [self requestAnonLogin];
    }
}



- (IBAction)toSignUpPage:(id)sender {
}



-(BOOL) checkSingupConstraints: (NSString *)email :(NSString *)pssd :(NSString *)pssdc
{
    if (pssd.length < 5){
        [self showAlertWithTitle:@"Signup Fail" message:@"Password less than 5 characters"];
        return FALSE;
    } else if (![pssd isEqualToString:pssdc]){
        [self showAlertWithTitle:@"Signup Fail" message:@"Confrimed password does not match password"];
        return FALSE;
    } else if (![self isValidEmail:email]){
        [self showAlertWithTitle:@"Signup Fail" message:@"Invalid email"];
        return FALSE;
    }
    return TRUE;
}

-(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void) setButtonsDisable
{
    [_toSignupButton setEnabled:FALSE];
    [_toLoginButton setEnabled:FALSE];
    [_anonLoginButton setEnabled:FALSE];
}

- (void) setButtonsEnable
{
    [_toSignupButton setEnabled:TRUE];
    [_toLoginButton setEnabled:TRUE];
    [_anonLoginButton setEnabled:TRUE];
}

#pragma mark -ServerCommunication

- (void) socketOnRecievedData
{
    [socketIO onAny:^(SocketAnyEvent* respond) {
        NSString *event = respond.event;
        NSDictionary *data = [respond.items objectAtIndex:0];
        if([event isEqual:@"signup_response"]){
            [self receiveSignupResponse:data];
        } else if([event isEqual:@"login_response"]){
            [self receiveLoginResponse:data];
        } else if([event isEqual:@"error"]){
            [self showAlertWithTitle:@"Server Error" message:[data objectForKey:@"message"]];
        }
    }];
}

- (void)showDefaultServerErrorAlert{
    [self showAlertWithTitle:@"Server Error" message:@"Woop, something is wrong with our server"];
}

- (void)showAlertWithTitle:(NSString*) title message:(NSString*) message
{
    UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:title
                                                              message:message
                                                             delegate:self
                                                    cancelButtonTitle:@"Okay"
                                                    otherButtonTitles:nil];
    [newMessageAlert show];
}

- (void) receiveSignupResponse:(NSDictionary *)data
{
    if([[data objectForKey:@"respond"] isEqual:@"SIGNUP_SUCCESS"]){
        [[NSUserDefaults standardUserDefaults] setObject:loginEmail forKey:@"savedEmail"];
        [[NSUserDefaults standardUserDefaults] setObject:loginPassword forKey:@"savedPassword"];
        [_toLoginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        [self showAlertWithTitle:@"Signup Succeed" message:[data objectForKey:@"displayMessage"]];
    } else{
        [self showAlertWithTitle:@"Signup Failed" message:[data objectForKey:@"displayMessage"]];
    }
}

- (void) receiveLoginResponse:(NSDictionary *)data
{
    if([[data objectForKey:@"respond"] isEqual:@"LOGIN_SUCCESS"]){
        APPDELEGATE.userName = [data objectForKey:@"userName"];
        APPDELEGATE.uid = [data objectForKey:@"uid"];
        if([APPDELEGATE.loginType isEqualToString:@"register"]){
            [[NSUserDefaults standardUserDefaults] setObject:loginEmail forKey:@"savedEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:loginPassword forKey:@"savedPassword"];
            [[NSUserDefaults standardUserDefaults] setObject:@"REGISTER" forKey:@"loginType"];
            [APPDELEGATE setRegularUserConstrains];
        }else if([APPDELEGATE.loginType isEqualToString:@"facebook"]){
            [APPDELEGATE setFacebookUserConstrains];
            [[NSUserDefaults standardUserDefaults] setObject:@"FACEBOOK" forKey:@"loginType"];
//            [[NSUserDefaults standardUserDefaults] setObject:facebookUser forKey:@"savedFacebookUser"];
        }else{
            [APPDELEGATE setAnonymouseUserConstrains];
        }
        UIStoryboard *storyboard = self.storyboard;
        MainViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
        [self presentViewController:mainView  animated:YES completion:nil];
    } else{
        [self showAlertWithTitle:@"Login Failed" message:[data objectForKey:@"displayMessage"]];
        [self.view sendSubviewToBack:backgroundIV];
    }
}

- (IBAction)signUp:(id)sender {
    [self setButtonsDisable];
    [self performSelector:@selector(setButtonsEnable) withObject:nil afterDelay:2.0];
//    if ([socketIO isConnected] == FALSE){
//        [APPDELEGATE connectServer];
//        [self performSelector:@selector(requestSignUp) withObject:nil afterDelay:1.0];
//    } else {
        [self requestSignUp];
//    }
}

-(void) requestSignUp
{
    loginEmail = self.signupEmail.text;
    loginPassword = self.signupPassword.text;
    NSString *passwordConfirm = self.signupPasswordC.text;
    NSString *email = self.signupEmail.text;
    
    if([self checkSingupConstraints:loginEmail:loginPassword:passwordConfirm]){
        NSDictionary* signupData = @{@"uid" : loginEmail,
                                     @"version": [APPDELEGATE version],
                                     @"password" : loginPassword,
                                     @"lng" : APPDELEGATE.lng,
                                     @"lat" : APPDELEGATE.lat
                                     };
        [socketIO emitObjc:@"signup" withItems:@[signupData]];
    }
}

-(void) requestAnonLogin
{
    NSNull *email = [NSNull null];
    NSNull *password = [NSNull null];
    loginEmail = nil;
    loginPassword = nil;
    NSDictionary* singinData = @{@"signinType" : @"ANONYMOUS",
                                 @"version": [APPDELEGATE version],
                                 @"uid" : email,
                                 @"password" : password,
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    [socketIO emitObjc:@"login" withItems:@[singinData]];
    APPDELEGATE.loginType = @"anonymous";
}

-(void) requestRegisterLoginWithEmail:(NSString*)email password:(NSString*)password
{
//    loginEmail = self.emailInput.text;
//    loginPassword = self.passwordInput.text;
    NSDictionary* singinData = @{@"signinType" : @"REGISTER",
                                 @"version": [APPDELEGATE version],
                                 @"uid" : email,
                                 @"password" : password,
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    [socketIO emitObjc:@"login" withItems:@[singinData]];
    APPDELEGATE.loginType = @"register";
}

- (void) requestFacebookLogin
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"FBid"] == nil){
        [self showAlertWithTitle:@"Facebook Login Fail" message:@"FB id is nil"];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:@"FBemail"] == nil) {
        [self showAlertWithTitle:@"Facebook Login Fail" message:@"FB email is nil"];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:@"FBlink"] == nil) {
        [self showAlertWithTitle:@"Facebook Login Fail" message:@"FB link is nil"];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:@"FBname"] == nil) {
        [self showAlertWithTitle:@"Facebook Login Fail" message:@"FB name is nil"];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:@"FBthumbnailURL"] == nil) {
        [self showAlertWithTitle:@"Facebook Login Fail" message:@"FB thumbnail is nil"];
    } else {
        NSDictionary* singinData = @{@"signinType" : @"FACEBOOK",
                                     @"version": [APPDELEGATE version],
                                     @"uid" : [[NSUserDefaults standardUserDefaults] objectForKey:@"FBid"],
                                     @"email": [[NSUserDefaults standardUserDefaults] objectForKey:@"FBemail"],
                                     @"fbLink":[[NSUserDefaults standardUserDefaults] objectForKey:@"FBlink"],
                                     @"username": [[NSUserDefaults standardUserDefaults] objectForKey:@"FBname"],
                                     @"thumbnailURL":[[NSUserDefaults standardUserDefaults] objectForKey:@"FBthumbnailURL"],
                                     @"lng" : APPDELEGATE.lng,
                                     @"lat" : APPDELEGATE.lat
                                     };
        [socketIO emitObjc:@"login" withItems:@[singinData]];
        APPDELEGATE.loginType = @"facebook";
    }
}

@end