//
//  LoginViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"

@interface LoginViewController (){
    NSString *requestUserName;
    NSString *requestPassword;
//    UITextField *tempUserNameInput;
//    UITextField *tempPasswordInput;
}

@end

@implementation LoginViewController
@synthesize passwordInput;
@synthesize usernameInput;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Background
    UIImageView *backgroundIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-darkblue.png"]];
    backgroundIV.frame = self.view.bounds;
    [self.view addSubview:backgroundIV];
    [self.view sendSubviewToBack:backgroundIV];
//    tempUserNameInput = usernameInput;
//    tempPasswordInput = passwordInput;
    
    //Buttons
    _toLoginButton.layer.borderWidth = 2;
    _toLoginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _toLoginButton.layer.cornerRadius = 8;
    _toLoginButton.layer.masksToBounds = YES;
    
    _toSignupButton.layer.borderWidth = 2;
    _toSignupButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _toSignupButton.layer.cornerRadius = 8;
    _toSignupButton.layer.masksToBounds = YES;
    
    
    usernameInput.delegate = self;
    passwordInput.delegate = self;
    _signupPassword.delegate = self;
    _signupPasswordC.delegate = self;
    _signupEmail.delegate = self;
    _singupUsername.delegate = self;
    
    socketIO = APPDELEGATE.socketIO;
    socketIO.delegate = self;
    if([CLLocationManager locationServicesEnabled]){
        _currentLocation = APPDELEGATE.locationManager.location;
    }
    
}

- (void) viewDidAppear:(BOOL)animated{
    //Auto fillin name and password
    NSString *savedName = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedName"];
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedPassword"];
    if (savedName != nil && savedPassword != nil){
        usernameInput.text = savedName;
        passwordInput.text = savedPassword;
    }
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
    // Dispose of any resources that can be recreated.
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if ([packet.name isEqual: @"login_response"]){
        [self receiveLoginResponse:packet];
    } else if([packet.name isEqual: @"signup_response"]){
        [self receiveSignupResponse:packet];
    }
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

-(void) receiveSignupResponse:(SocketIOPacket *)packet
{
    if([[packet.args objectAtIndex:0] isEqual:@"SIGNUP_SUCCESS"]){
        [[NSUserDefaults standardUserDefaults] setObject:requestUserName forKey:@"savedName"];
        [[NSUserDefaults standardUserDefaults] setObject:requestPassword forKey:@"savedPassword"];
        [_toLoginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Signup succeed"
                                                                  message:[packet.args objectAtIndex:0]
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    } else{
//        NSLog(@"textfields name:%@ password:%@",usernameInput.text,passwordInput.text);
        NSLog(@"signup failed: %@",[packet.args objectAtIndex:0]);
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Signup failed"
                                                                  message:[packet.args objectAtIndex:0]
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    }
}

-(void) receiveLoginResponse:(SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    if([[dic objectForKey:@"status"] isEqual:@"LOGIN_SUCCESS"]){
        APPDELEGATE.userName = [dic objectForKey:@"userName"];
        if([APPDELEGATE.loginType isEqualToString:@"Register"]){
            [[NSUserDefaults standardUserDefaults] setObject:requestUserName forKey:@"savedName"];
            [[NSUserDefaults standardUserDefaults] setObject:requestPassword forKey:@"savedPassword"];
        }
        MainViewController *mainView = [self.storyboard instantiateViewControllerWithIdentifier:@"MainView"];
        [self presentViewController:mainView  animated:YES completion:NULL];
    } else{
        NSLog(@"login failed, %@",[packet.args objectAtIndex:0]);
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Login failed"
                                                                  message:[dic objectForKey:@"displayMessage"]
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    }
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
    }
    else if ([socketIO isConnected] == FALSE){
        [APPDELEGATE serverReconnect];
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
    }
    else if ([socketIO isConnected] == FALSE){
        [APPDELEGATE serverReconnect];
        [self performSelector:@selector(requestAnonLogin) withObject:nil afterDelay:1.0];
    } else {
        [self requestAnonLogin];
    }
}

-(void) requestAnonLogin
{
//    NSString *lng = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.longitude];
//    NSString *lat = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.latitude];
    NSNull *userName = [NSNull null];
    NSNull *password = [NSNull null];
    requestUserName = nil;
    requestPassword = nil;
    NSDictionary* singinData = @{@"signinType" : @"anonymous",
                                 @"uid" : userName,
                                 @"password" : password,
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    NSLog(@"send login event");
    
    [socketIO sendEvent:@"login" withData:singinData];
    APPDELEGATE.loginType = @"Anonymous";
}

-(void) requestRegisterLogin
{
//    NSString *lng = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.longitude];
//    NSString *lat = [NSString stringWithFormat:@"%+.6f", _currentLocation.coordinate.latitude];
    requestUserName = self.usernameInput.text;
    requestPassword = self.passwordInput.text;
    NSDictionary* singinData = @{@"signinType" : @"register",
                                 @"uid" : requestUserName,
                                 @"password" : requestPassword,
                                 @"lng" : APPDELEGATE.lng,
                                 @"lat" : APPDELEGATE.lat
                                 };
    
    [socketIO sendEvent:@"login" withData:singinData];
    APPDELEGATE.loginType = @"Register";
}

- (IBAction)toSignUpPage:(id)sender {
}

- (IBAction)signUp:(id)sender {
    [self setButtonsDisable];
    [self performSelector:@selector(setButtonsEnable) withObject:nil afterDelay:2.0];
    if ([socketIO isConnected] == FALSE){
        [APPDELEGATE serverReconnect];
        [self performSelector:@selector(requestSignUp) withObject:nil afterDelay:1.0];
    } else {
        [self requestSignUp];
    }

}

-(void) requestSignUp
{
    requestUserName = self.singupUsername.text;
    requestPassword = self.signupPassword.text;
    NSString *passwordConfirm = self.signupPasswordC.text;
    NSString *email = self.signupEmail.text;

    if([self checkSingupConstraints:requestUserName:requestPassword:passwordConfirm:email]){
        NSDictionary* signupData = @{@"uid" : requestUserName,
                                     @"password" : requestPassword,
                                     @"email" : email,
                                     @"lng" : APPDELEGATE.lng,
                                     @"lat" : APPDELEGATE.lat
                                     };
        
        [socketIO sendEvent:@"signup" withData:signupData];
    }
}

-(BOOL) checkSingupConstraints: (NSString *)name :(NSString *)pssd :(NSString *)pssdc :(NSString *)email
{
    if (name.length < 5){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Signup Fail"
                                                                  message:@"User name less than 5 characters"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
        return FALSE;

    } else if (pssd.length < 5){
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

    } else if (![self NSStringIsValidEmail:email]){
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

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
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
    [_signUpButton setEnabled:FALSE];
    [_registerLoginButton setEnabled:FALSE];
    [_anonLoginButton setEnabled:FALSE];
}

- (void) setButtonsEnable
{
    [_signUpButton setEnabled:TRUE];
    [_registerLoginButton setEnabled:TRUE];
    [_anonLoginButton setEnabled:TRUE];
}




@end
