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
@synthesize socketIO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
            [self requestRegisterLoginWithEmail:savedEmail password:savedPassword];
            //        [self.view bringSubviewToFront:backgroundIV];
            [self performSelector:@selector(loginFail) withObject:nil afterDelay:3.0];
        } else if([previousLogin isEqualToString:@"FACEBOOK"]){
            fbLoginView = [[FBLoginView alloc] initWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]];
            fbLoginView.delegate = self;
            [self.view bringSubviewToFront:backgroundIV];
            [self performSelector:@selector(loginFail) withObject:nil afterDelay:3.0];
        }
    }
    
    //Set socketIO listener
    socketIO = APPDELEGATE.socketIO;
    [self socketOnRecievedData];
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
            [[NSUserDefaults standardUserDefaults] setObject:facebookUser forKey:@"savedFacebookUser"];
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

-(void) requestRegisterLoginWithEmail:(NSString*)email password:(NSString*)pssd
{
//    loginEmail = self.emailInput.text;
//    loginPassword = self.passwordInput.text;
    NSDictionary* singinData = @{@"signinType" : @"REGISTER",
                                 @"version": [APPDELEGATE version],
                                 @"uid" : email,
                                 @"password" : pssd,
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    [socketIO emitObjc:@"login" withItems:@[singinData]];
    APPDELEGATE.loginType = @"register";
}

- (void) requestFacebookLogin:(id<FBGraphUser>)fbUser
{
    NSString *email = [fbUser objectForKey:@"email"];
    if (email == nil) {
        email = @"";
    }
    NSString *fbThumbnailURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fbUser.objectID];
    [[NSUserDefaults standardUserDefaults] setObject:fbThumbnailURL forKey:@"savedFBthumbnailURL"];
    [[NSUserDefaults standardUserDefaults] setObject:fbUser.objectID forKey:@"savedFBuid"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"savedFBemail"];
    [[NSUserDefaults standardUserDefaults] setObject:fbUser.link forKey:@"savedFBlink"];
    [[NSUserDefaults standardUserDefaults] setObject:fbUser.name forKey:@"savedFBname"];
    NSDictionary* singinData = @{@"signinType" : @"FACEBOOK",
                                 @"version": [APPDELEGATE version],
                                 @"uid" : fbUser.objectID,
                                 @"email": email,
                                 @"fbLink":fbUser.link,
                                 @"userName": fbUser.name,
                                 @"thumbnailURL":fbThumbnailURL,
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    [socketIO emitObjc:@"login" withItems:@[singinData]];
    APPDELEGATE.loginType = @"facebook";
}

#pragma mark -Facebook Login Delegate

-(void)fireFbLoginView{
    for(id object in fbLoginView.subviews){
        if([[object class] isSubclassOfClass:[UIButton class]]){
            UIButton* button = (UIButton*)object;
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)fbUser
{
    facebookUser = fbUser;
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        [self showAlertWithTitle:@"Location Service disabled" message:@"Please turn on Location Services in your device setting"];
    }
//    else if ([socketIO isConnected] == FALSE){
//        [APPDELEGATE connectServer];
//        [self performSelector:@selector(requestFacebookLogin:) withObject:fbUser afterDelay:1.0];
//    }
    else {
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
        [self showAlertWithTitle:alertTitle message:alertMessage];
    }
}


@end
