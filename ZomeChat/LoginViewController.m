//
//  LoginViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController (){
    NSString *loginEmail;
    NSString *loginPassword;
    id<FBGraphUser> facebookUser;
    UIImageView *backgroundIV;
}

@end

@implementation LoginViewController
@synthesize passwordInput;
@synthesize emailInput;
@synthesize fbLoginView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Background
    backgroundIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-darkblue@x2.png"]];
    backgroundIV.frame = self.view.bounds;
    [self.view addSubview:backgroundIV];
    [self initLoginView];
    
    NSString *savedEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedEmail"];
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedPassword"];
    emailInput.text = savedEmail;
    passwordInput.text = savedPassword;
    
    NSString *previousLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"];
//    NSLog(@"previous login :%@",previousLogin);
    if (previousLogin != nil && [previousLogin isEqualToString:@"register"]){
        [self registerLogin:self];
        [self.view bringSubviewToFront:backgroundIV];
        [self performSelector:@selector(loginFail) withObject:nil afterDelay:3.0];
    } else if(previousLogin != nil && [previousLogin isEqualToString:@"facebook"]){
        fbLoginView = [[FBLoginView alloc] initWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]];
        fbLoginView.delegate = self;
        [self.view bringSubviewToFront:backgroundIV];
        [self performSelector:@selector(loginFail) withObject:nil afterDelay:3.0];
    }
}

- (void) initLoginView{
    [self initFacebookLogin];
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
    
    socketIO = APPDELEGATE.socketIO;
    socketIO.delegate = self;
    if([CLLocationManager locationServicesEnabled]){
        _currentLocation = APPDELEGATE.locationManager.location;
    }

}

- (void) loginFail
{
    if(self.isViewLoaded && self.view.window){
    [[[UIAlertView alloc] initWithTitle:@"Login Fail"
                                message: @"Connection Timeout"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    [self.view sendSubviewToBack:backgroundIV];
    }
}

- (void) initFacebookLogin{
    for (UIButton *view in fbLoginView.subviews) {
        if ([view respondsToSelector:@selector(addTarget:action:forControlEvents:)]) {
            fbLoginView = [[FBLoginView alloc] initWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]];
            fbLoginView.delegate = self;
        }
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
    fbLoginView.delegate = Nil;
}

- (void) backgroundTouched:(id)sender
{
    //    [_passwordInput resignFirstResponder];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [_singupUsername resignFirstResponder];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField){
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Connection Timeout"
                                                              message:@"Server is temperary unavailable, please try again shortly"
                                                             delegate:self
                                                    cancelButtonTitle:@"Okay"
                                                    otherButtonTitles:nil];
    [newMessageAlert show];
    
}

- (IBAction)registerLogin:(id)sender {
    [self setButtonsDisable];
    [self performSelector:@selector(setButtonsEnable) withObject:nil afterDelay:2.0];
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Location Service disabled"
                                                                  message:@"Please turn on Location Services in your device setting"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    } else if ([socketIO isConnected] == FALSE){
        [APPDELEGATE connectServer];
        [self performSelector:@selector(requestRegisterLogin) withObject:nil afterDelay:1.0];
    } else {
        [self requestRegisterLogin];
    }
}

- (IBAction)anonymousLogin:(id)sender {
    [self setButtonsDisable];
    [self performSelector:@selector(setButtonsEnable) withObject:nil afterDelay:2.0];
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Location Service disabled"
                                                                  message:@"Please turn on Location Services in your device setting"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    } else if ([socketIO isConnected] == FALSE){
        [APPDELEGATE connectServer];
        [self performSelector:@selector(requestAnonLogin) withObject:nil afterDelay:1.0];
    } else {
        [self requestAnonLogin];
    }
}



- (IBAction)toSignUpPage:(id)sender {
}



-(BOOL) checkSingupConstraints: (NSString *)email :(NSString *)pssd :(NSString *)pssdc
{
    if (pssd.length < 5){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Signup Fail"
                                                                  message:@"Password less than 5 characters"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
        return FALSE;
        
    } else if (![pssd isEqualToString:pssdc]){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Signup Fail"
                                                                  message:@"Confrimed password does not match password"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
        return FALSE;

    } else if (![self isValidEmail:email]){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Signup Fail"
                                                                  message:@"Invalid email"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
        return FALSE;
        
    } else {
        return TRUE;
    }
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

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if ([packet.name isEqual: @"login_response"]){
        [self receiveLoginResponse:packet];
    } else if([packet.name isEqual: @"signup_response"]){
        [self receiveSignupResponse:packet];
    }
}

- (void) receiveSignupResponse:(SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    if([[dic objectForKey:@"respond"] isEqual:@"SIGNUP_SUCCESS"]){
        [[NSUserDefaults standardUserDefaults] setObject:loginEmail forKey:@"savedEmail"];
        [[NSUserDefaults standardUserDefaults] setObject:loginPassword forKey:@"savedPassword"];
        [_toLoginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Signup succeed"
                                                                  message:[dic objectForKey:@"displayMessage"]
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    } else{
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Signup failed"
                                                                  message:[dic objectForKey:@"displayMessage"]
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    }
}

- (void) receiveLoginResponse:(SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    if([[dic objectForKey:@"status"] isEqual:@"LOGIN_SUCCESS"]){
        APPDELEGATE.userName = [dic objectForKey:@"userName"];
        APPDELEGATE.uid = [dic objectForKey:@"uid"];
        if([APPDELEGATE.loginType isEqualToString:@"register"]){
            [[NSUserDefaults standardUserDefaults] setObject:loginEmail forKey:@"savedEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:loginPassword forKey:@"savedPassword"];
            [[NSUserDefaults standardUserDefaults] setObject:@"register" forKey:@"loginType"];
            [APPDELEGATE setRegularUserConstrains];
        }else if([APPDELEGATE.loginType isEqualToString:@"facebook"]){
            [APPDELEGATE setFacebookUserConstrains];
            [[NSUserDefaults standardUserDefaults] setObject:@"facebook" forKey:@"loginType"];
            [[NSUserDefaults standardUserDefaults] setObject:facebookUser forKey:@"savedFacebookUser"];
        }else{
            [APPDELEGATE setAnonymouseUserConstrains];
        }
        UIStoryboard *storyboard = self.storyboard;
        MainViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
        [self presentViewController:mainView  animated:YES completion:nil];
    } else{
        NSLog(@"login failed, %@",[packet.args objectAtIndex:0]);
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Login failed"
                                                                  message:[dic objectForKey:@"displayMessage"]
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
        [self.view sendSubviewToBack:backgroundIV];
    }
}

- (IBAction)signUp:(id)sender {
    [self setButtonsDisable];
    [self performSelector:@selector(setButtonsEnable) withObject:nil afterDelay:2.0];
    if ([socketIO isConnected] == FALSE){
        [APPDELEGATE connectServer];
        [self performSelector:@selector(requestSignUp) withObject:nil afterDelay:1.0];
    } else {
        [self requestSignUp];
    }
}

-(void) requestSignUp
{
    loginEmail = self.signupEmail.text;
    loginPassword = self.signupPassword.text;
    NSString *passwordConfirm = self.signupPasswordC.text;
    NSString *email = self.signupEmail.text;
    
    if([self checkSingupConstraints:loginEmail:loginPassword:passwordConfirm]){
        NSDictionary* signupData = @{@"uid" : loginEmail,
                                     @"password" : loginPassword,
                                     @"lng" : APPDELEGATE.lng,
                                     @"lat" : APPDELEGATE.lat
                                     };
        
        [socketIO sendEvent:@"signup" withData:signupData];
    }
}

-(void) requestAnonLogin
{
    NSNull *email = [NSNull null];
    NSNull *password = [NSNull null];
    loginEmail = nil;
    loginPassword = nil;
    NSDictionary* singinData = @{@"signinType" : @"anonymous",
                                 @"version": [APPDELEGATE version],
                                 @"uid" : email,
                                 @"password" : password,
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    [socketIO sendEvent:@"login" withData:singinData];
    APPDELEGATE.loginType = @"anonymous";
}

-(void) requestRegisterLogin
{
    loginEmail = self.emailInput.text;
    loginPassword = self.passwordInput.text;
    NSDictionary* singinData = @{@"signinType" : @"register",
                                 @"version": [APPDELEGATE version],
                                 @"uid" : loginEmail,
                                 @"password" : loginPassword,
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    
    [socketIO sendEvent:@"login" withData:singinData];
    APPDELEGATE.loginType = @"register";
}

- (void) requestFacebookLogin:(id<FBGraphUser>)fbUser
{
    NSString *email = [fbUser objectForKey:@"email"];
    if (email == nil) {
        email = @"";
    }
    NSString *fbThumbnailURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fbUser.objectID];
    NSDictionary* singinData = @{@"signinType" : @"facebook",
                                 @"version": [APPDELEGATE version],
                                 @"uid" : fbUser.objectID,
                                 @"email": email,
                                 @"fbLink":fbUser.link,
                                 @"userName": fbUser.name,
                                 @"thumbnailURL":fbThumbnailURL,
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    [socketIO sendEvent:@"login" withData:singinData];
    APPDELEGATE.loginType = @"facebook";
}

#pragma mark -Facebook Login Delegate

-(void)fireFbLoginView{
    NSLog(@"fireFbLoginView called");
    for(id object in fbLoginView.subviews){
        if([[object class] isSubclassOfClass:[UIButton class]]){
            UIButton* button = (UIButton*)object;
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)fbUser
{
    NSLog(@"loginViewFetchedUserInfo called");
    facebookUser = fbUser;
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Location Service disabled"
                                                                  message:@"Please turn on Location Services in your device setting"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    } else if ([socketIO isConnected] == FALSE){
        [APPDELEGATE connectServer];
        [self performSelector:@selector(requestFacebookLogin:) withObject:fbUser afterDelay:1.0];
    } else {
        [self requestFacebookLogin:fbUser];
    }
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"facebook logged in");
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.profileID = nil;
    self.nameLabel.text = @"";
    self.statusLabel.text= @"You're not logged in!";
    [FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, nil]];
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection,id<FBGraphUser> fbUser,NSError *error) {
            if (!error) {
                NSString *fbID = fbUser.objectID;
                NSLog(@"UserID: %@",fbID);
                NSLog(@"TESTING: %@",fbUser.name);
            }
        }];
    }
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


@end
