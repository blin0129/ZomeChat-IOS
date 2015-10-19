//
//  LoginViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "ZomeChat-Swift.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController (){
    NSString *loginEmail;
    NSString *loginPassword;
    UIImageView *backgroundIV;
    SocketIOClient *socketIO;
    NSString *previousLogin;
    BOOL loginAttemptSuccess;
}
@end

@implementation LoginViewController
@synthesize passwordInput;
@synthesize emailInput;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    loginAttemptSuccess = true;
    
    //Set socketIO listener
    socketIO = APPDELEGATE.socketIO;
    [self socketOnRecievedData];
    
    //Background
    backgroundIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-darkblue@x2.png"]];
    backgroundIV.frame = self.view.bounds;
    [self.view addSubview:backgroundIV];
    [self initLoginView];
    
    previousLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"];
    if(previousLogin != nil){
        [self.view bringSubviewToFront:backgroundIV];
        [self autoLogin];
    } else{
        [self.view sendSubviewToBack:backgroundIV];
    }
    
    //Auto fillin name and password
    NSString *savedEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    if (savedEmail != nil && savedPassword != nil){
        emailInput.text = savedEmail;
        passwordInput.text = savedPassword;
    }
}

- (void) initLoginView{
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
    
    _loginActivityIndicator.hidden = NO;
    _signupActivityIndicator.hidden = NO;
    _loginActivityBackground.hidden = YES;
    _signupActivityBackground.hidden = YES;
    
    emailInput.tintColor = [UIColor blueColor];
    passwordInput.tintColor = [UIColor blueColor];
    _signupEmail.tintColor = [UIColor blueColor];
    _signupPassword.tintColor = [UIColor blueColor];
    _signupPasswordC.tintColor = [UIColor blueColor];
    
    if([CLLocationManager locationServicesEnabled]){
        _currentLocation = APPDELEGATE.locationManager.location;
    }
}

#pragma mark - Logins and Signups -

#pragma mark IBActions

- (IBAction)facebookLogin:(id)sender {
    NSString* fbid = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBid"];
    [self performLoginWithRequest:@selector(facebookLoginHelper:)
                        andObject:fbid
                        andObject:nil];
}

- (IBAction)registerLogin:(id)sender {
    [self performLoginWithRequest:@selector(requestRegisterLoginWithEmail:password:)
                        andObject:self.emailInput.text
                        andObject:self.passwordInput.text];
}

- (IBAction)anonymousLogin:(id)sender {
    [self performLoginWithRequest:@selector(requestAnonLogin)
                        andObject:nil andObject:nil];
}

- (IBAction)signUp:(id)sender {
    [self startSignupActivityView];
    [self disableButtons];
    [self performSelector:@selector(enableButtons) withObject:nil afterDelay:2.0];
    [self requestSignUp];
}

- (IBAction)toSignUpPage:(id)sender {
    
}

#pragma mark Helper Methods

- (void)performLoginWithRequest:(SEL)requestSelector andObject:(NSObject*)objectOne andObject:(NSObject *)objectTwo {
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        [self showAlertWithTitle:@"Location Service disabled"
                         message:@"Please turn on Location Services in your device settings."];
    } else {
        [self startLoginActivityView];
        [self disableButtons];
        loginAttemptSuccess = false;
        [self performSelector:@selector(enableButtons) withObject:nil afterDelay:2.0];
        [self performSelector:requestSelector withObject:objectOne withObject:objectTwo];
    }
}

- (void)facebookLoginHelper:(NSString*)FBid {
    if (FBid) [self requestFacebookLogin];
    else [self accessFacebookInfo];
}


#pragma mark Auto Login

- (void) autoLogin
{
    [self startLoginActivityView];
    [self performSelector:@selector(autoLoginFail) withObject:nil afterDelay:5.0];
    NSString *savedEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    [socketIO on: @"connect" callback:^(NSArray * data, SocketAckEmitter *items) {
        NSLog(@"server connected, now try auto login");
        previousLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"];
        if(previousLogin != nil){
            if ([previousLogin isEqualToString:@"REGISTER"]){
                if(savedEmail != nil && savedPassword != nil){
                    [self requestRegisterLoginWithEmail:savedEmail password:savedPassword];
                }
            } else if([previousLogin isEqualToString:@"FACEBOOK"]){
                [self requestFacebookLogin];
            }
        }
    }];
    [self stopLoginActivityView];
}

- (void) autoLoginFail
{
    if(loginAttemptSuccess == false){
        [self showAlertWithTitle:@"Login Fail" message:@"The connection timed out."];
    }
    [self.view sendSubviewToBack:backgroundIV];
}

#pragma mark - Validations

-(BOOL) checkSingupConstraints: (NSString *)email :(NSString *)pssd :(NSString *)pssdc
{
    if (pssd.length < 5){
        [self showAlertWithTitle:@"Signup Failed" message:@"Your password is less than 5 characters."];
        return FALSE;
    } else if (![pssd isEqualToString:pssdc]){
        [self showAlertWithTitle:@"Signup Failed" message:@"Confrimed password doesn't match password."];
        return FALSE;
    } else if (![self isValidEmail:email]){
        [self showAlertWithTitle:@"Signup Failed" message:@"Invalid email."];
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

#pragma mark - View Helpers -

#pragma mark UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField){
        [textField resignFirstResponder];
    }
    return NO;
}

#pragma mark Custom

- (void) disableButtons
{
    [_toSignupButton setEnabled:FALSE];
    [_toLoginButton setEnabled:FALSE];
    [_anonLoginButton setEnabled:FALSE];
}

- (void) enableButtons
{
    [_toSignupButton setEnabled:TRUE];
    [_toLoginButton setEnabled:TRUE];
    [_anonLoginButton setEnabled:TRUE];
}

- (void)startLoginActivityView {
    _loginActivityIndicator.hidden = NO;
    [_loginActivityIndicator startAnimating];
    _loginActivityBackground.hidden = NO;
}

- (void)stopLoginActivityView {
    _loginActivityIndicator.hidden = YES;
    [_loginActivityIndicator stopAnimating];
    _loginActivityBackground.hidden = YES;
}

- (void)startSignupActivityView {
    _signupActivityIndicator.hidden = NO;
    [_signupActivityIndicator startAnimating];
    _signupActivityBackground.hidden = NO;
}

- (void)stopSignupActivityView {
    _signupActivityIndicator.hidden = YES;
    [_signupActivityIndicator stopAnimating];
    _signupActivityBackground.hidden = YES;
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

#pragma mark - Server Communication -

#pragma mark Request Data

-(void) requestSignUp
{
    loginEmail = self.signupEmail.text;
    loginPassword = self.signupPassword.text;
    NSString *passwordConfirm = self.signupPasswordC.text;
    if([self checkSingupConstraints:loginEmail:loginPassword:passwordConfirm]){
        NSDictionary* signupData = @{@"uid" : loginEmail,
                                     @"version": [APPDELEGATE version],
                                     @"password" : loginPassword,
                                     @"lng" : APPDELEGATE.lng,
                                     @"lat" : APPDELEGATE.lat
                                     };
        [socketIO emit:@"signup" withItems:@[signupData]];
    } else {
        [self stopSignupActivityView];
    }
}

-(void) requestAnonLogin
{
    NSDictionary* singinData = @{@"signinType" : @"ANONYMOUS",
                                 @"version": [APPDELEGATE version],
                                 @"uid" : [NSNull null],
                                 @"password" : [NSNull null],
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    [socketIO emit:@"login" withItems:@[singinData]];
    APPDELEGATE.loginType = @"ANONYMOUS";
}

-(void) requestRegisterLoginWithEmail:(NSString*)email password:(NSString*)password
{
    loginEmail = email;
    loginPassword = password;
    NSDictionary* singinData = @{@"signinType" : @"REGISTER",
                                 @"version": [APPDELEGATE version],
                                 @"uid" : email,
                                 @"password" : password,
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    [socketIO emit:@"login" withItems:@[singinData]];
    APPDELEGATE.loginType = @"REGISTER";
}

- (void) requestFacebookLogin
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"FBid"] == nil){
        [self showAlertWithTitle:@"Facebook Login Fail" message:@"FB id not found"];
        [self accessFacebookInfo];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:@"FBemail"] == nil) {
        [self accessFacebookInfo];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:@"FBlink"] == nil) {
        [self accessFacebookInfo];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:@"FBname"] == nil) {
        [self accessFacebookInfo];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:@"FBthumbnailURL"] == nil) {
        [self accessFacebookInfo];
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
        [socketIO emit:@"login" withItems:@[singinData]];
        APPDELEGATE.loginType = @"FACEBOOK";
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

#pragma mark Recieve Data

- (void) socketOnRecievedData
{
    [socketIO onAny:^(SocketAnyEvent* respond) {
        NSString *event = respond.event;
        if([event isEqual:@"disconnect"] || [event isEqual:@"reconnect"] || [event isEqual:@"reconnectAttempt"]){
            return;
        }
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

- (void) receiveSignupResponse:(NSDictionary *)data
{
    if([[data objectForKey:@"respond"] isEqual:@"SIGNUP_SUCCESS"]){
        [[NSUserDefaults standardUserDefaults] setObject:loginEmail forKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setObject:loginPassword forKey:@"password"];
        [_toLoginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        [self showAlertWithTitle:@"Signup Succeeded" message:[data objectForKey:@"displayMessage"]];
    } else{
        [self showAlertWithTitle:@"Signup Failed" message:[data objectForKey:@"displayMessage"]];
    }
    [self stopSignupActivityView];
}

- (void) receiveLoginResponse:(NSDictionary *)data
{
    if([[data objectForKey:@"respond"] isEqual:@"LOGIN_SUCCESS"]){
        loginAttemptSuccess = true;
        APPDELEGATE.userName = [data objectForKey:@"userName"];
        APPDELEGATE.uid = [data objectForKey:@"uid"];
        if([[data objectForKey:@"userType"] isEqualToString:@"REGISTER"]){
            [[NSUserDefaults standardUserDefaults] setObject:loginEmail forKey:@"email"];
            [[NSUserDefaults standardUserDefaults] setObject:loginPassword forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] setObject:@"REGISTER" forKey:@"loginType"];
            [APPDELEGATE setRegularUserConstrains];
        }else if([[data objectForKey:@"userType"] isEqualToString:@"FACEBOOK"]){
            [APPDELEGATE setFacebookUserConstrains];
            [[NSUserDefaults standardUserDefaults] setObject:@"FACEBOOK" forKey:@"loginType"];
        }else{
            [APPDELEGATE setAnonymouseUserConstrains];
            [[NSUserDefaults standardUserDefaults] setObject:@"ANONYMOUS" forKey:@"loginType"];
        }
        UIStoryboard *storyboard = self.storyboard;
        MainViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
        [self presentViewController:mainView  animated:YES completion:nil];
    } else{
        [self showAlertWithTitle:@"Login Failed" message:[data objectForKey:@"displayMessage"]];
        [self.view sendSubviewToBack:backgroundIV];
    }
    [self stopLoginActivityView];
}

#pragma mark Server Alert

- (void)showDefaultServerErrorAlert{
    [self showAlertWithTitle:@"Server Error" message:@"Whoops, something is wrong with our server!"];
}

@end