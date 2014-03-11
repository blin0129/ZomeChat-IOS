//
//  ThemePageViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 1/7/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "ThemePageViewController.h"

@interface ThemePageViewController ()

@end

@implementation ThemePageViewController
@synthesize createRoomButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *backgroundIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-lightblue.png"]];
    backgroundIV.frame = self.view.bounds;
    [self.view addSubview:backgroundIV];
    [self.view sendSubviewToBack:backgroundIV];
    
    createRoomButton.layer.borderWidth = 2;
    createRoomButton.layer.borderColor = [UIColor whiteColor].CGColor;
    createRoomButton.layer.cornerRadius = 8;
    createRoomButton.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 20) ? NO : YES;
}

- (IBAction)createNewRoom:(id)sender {
    if([APPDELEGATE.loginType isEqualToString:@"Anonymous"]){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Register Require"
                                                                  message:@"Plase register to use this feature "
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    } else {
        NSDate *lastRoomTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastRoomCreatedTime"];
        _timeSinceLastRoom = -1 * [lastRoomTime timeIntervalSinceNow];
        NSLog(@"Time since last room %d", _timeSinceLastRoom);
        
        if (APPDELEGATE.chatVC.ownedRoomName != nil) {
            UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"You already create a room"
                                                                      message:@"Leave the room to create new one "
                                                                     delegate:self
                                                            cancelButtonTitle:@"Okay"
                                                            otherButtonTitles:nil];
            [newMessageAlert show];
        } else if (_timeSinceLastRoom < 300 && lastRoomTime != nil){
            NSString *message = [NSString stringWithFormat:@"Please wait for %d min", (5 - (_timeSinceLastRoom/60))];
            UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"You just create a room"
                                                                      message:message
                                                                     delegate:self
                                                            cancelButtonTitle:@"Okay"
                                                            otherButtonTitles:nil];
            [newMessageAlert show];
        }else {
            UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
            UIAlertView *newRoomAlert = [[UIAlertView alloc] initWithTitle:@"New Theme Room"
                                                                   message:@""
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                         otherButtonTitles:@"Create", nil];
            [newRoomAlert addSubview:nameField];
            newRoomAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [newRoomAlert show];
        }
    }
}

-(void)willPresentAlertView:(UIAlertView *)alertView {
    if(![APPDELEGATE.loginType isEqualToString:@"Anonymous"]){
        if(_timeSinceLastRoom >= 300 && APPDELEGATE.chatVC.ownedRoomName == nil){
            UITextField *nameField = [alertView textFieldAtIndex:0];
            [nameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Room Name"]];
            nameField.delegate = self;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.cancelButtonIndex == buttonIndex){
        NSLog(@"canceled");
    } else {
        NSLog(@"new room created");
        NSString *newRoomName = ((UITextField *)[alertView textFieldAtIndex:0]).text;
        APPDELEGATE.chatVC.ownedRoomName = newRoomName;
        [APPDELEGATE.mainVC requestCreatingNewRoom:newRoomName];
    }
}

@end
