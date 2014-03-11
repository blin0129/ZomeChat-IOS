//
//  MessagePageViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 1/8/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "MessagePageViewController.h"
#import "SocketIOPacket.h"

@interface MessagePageViewController ()

@end

@implementation MessagePageViewController
@synthesize createMessageButton;

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
    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImageView *backgroundIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-lightblue.png"]];
    backgroundIV.frame = self.view.bounds;
    [self.view addSubview:backgroundIV];
    [self.view sendSubviewToBack:backgroundIV];
    
    createMessageButton.layer.borderWidth = 2;
    createMessageButton.layer.borderColor = [UIColor whiteColor].CGColor;
    createMessageButton.layer.cornerRadius = 8;
    createMessageButton.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 200) ? NO : YES;
}

- (IBAction)leaveMessage:(id)sender {
    if([APPDELEGATE.loginType isEqualToString:@"Anonymous"]){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Register Require"
                                                                  message:@"Plase register to use this feature "
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    } else {
        NSDate *lastMessageTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastMessageCreatedTime"];
        _timeSinceLastMessage = -1 * [lastMessageTime timeIntervalSinceNow];
        NSLog(@"Time since last msg %d", _timeSinceLastMessage);
        if (_timeSinceLastMessage < 1800 && lastMessageTime != nil){
            NSString *message = [NSString stringWithFormat:@"Please wait for %d min", (30 - (_timeSinceLastMessage/60))];
            UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"You just create a message"
                                                                      message:message
                                                                     delegate:self
                                                            cancelButtonTitle:@"Okay"
                                                            otherButtonTitles:nil];
            [newMessageAlert show];
        } else {
            UITextField *messageField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
            UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"New Message"
                                                           message:@""
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Create", nil];
            [newMessageAlert addSubview:messageField];
            newMessageAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [newMessageAlert show];
        }
    }
}


-(void)willPresentAlertView:(UIAlertView *)alertView {
    if(![APPDELEGATE.loginType isEqualToString:@"Anonymous"])
    {
        if (_timeSinceLastMessage >= 1800){
            UITextField *messageField = [alertView textFieldAtIndex:0];
            [messageField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"New Message"]];
            messageField.delegate =self;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.cancelButtonIndex == buttonIndex){
        NSLog(@"canceled");
    } else {
        NSLog(@"new message created");
        [APPDELEGATE.mainVC requestCreateNewMessage:((UITextField *)[alertView textFieldAtIndex:0]).text];
    }
}


@end
