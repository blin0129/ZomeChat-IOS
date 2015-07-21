//
//  ProfilePageViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 1/13/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "ProfilePageViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@interface ProfilePageViewController ()

@end

@implementation ProfilePageViewController
@synthesize saveButton;
@synthesize thumbnail;
@synthesize oldImage;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        APPDELEGATE.profileVC = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [APPDELEGATE.mainVC requestProfile];
}

- (void)initView
{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-babyblue"]]];
    if([APPDELEGATE.loginType isEqualToString:@"facebook"]){
        self.userIdLabel.text = @"Facebook User";
    }else{
        self.userIdLabel.text = [APPDELEGATE uid];
    }
    self.userNameLabel.text = [APPDELEGATE userName];
    if ([APPDELEGATE.loginType isEqualToString:@"Anonymous"]) {
        self.userIdLabel.text = @"Browsing Mode";
    }
    
    saveButton.layer.borderWidth = 2;
    saveButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    saveButton.layer.cornerRadius = 8;
    
    thumbnail.layer.cornerRadius = 75;
    thumbnail.layer.borderWidth = 5;
    thumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
    thumbnail.layer.masksToBounds = YES;
    
    if (APPDELEGATE.changeUserImage == YES) {
        [thumbnail setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectProfilePicture)];
        [thumbnail addGestureRecognizer:tap];
    }
    
    if (APPDELEGATE.changeUsername == NO) {
        saveButton.hidden = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) receiveMyProfile: (NSDictionary *)data
{
    if([data objectForKey:@"imageURL"] != nil){
        NSString *imageURL = [data objectForKey:@"imageURL"];
        if(![imageURL isEqual:[NSNull null]] && imageURL != nil){
            if(![imageURL isEqualToString:@""]){
                UIImage *image = [self getImageFromURL:imageURL];
                [thumbnail setImage:image];
                oldImage = image;
            }
        }
    } else {
        [thumbnail setBackgroundColor:[UIColor lightGrayColor]];
    }
}

-(void) receiveProfileUpdateRespond: (NSDictionary *)data
{
    if([[data objectForKey:@"respond"] isEqual:@"RESPOND_OKAY"]){
        APPDELEGATE.userName = [data objectForKey:@"username"];
        self.userNameLabel.text = [data objectForKey:@"username"];
        thumbnail.image = [self getImageFromURL:[data objectForKey:@"imageURL"]];
        oldImage = thumbnail.image;
        
        NSString* imageURL = [data objectForKey:@"imageURL"];
        if(![imageURL isEqual:[NSNull null]] && imageURL != nil){
            if(![imageURL isEqualToString:@""]){
                [APPDELEGATE.imageCache setObject:thumbnail.image forKey:imageURL];
            }
        }
    } else {
        [thumbnail setImage:oldImage];
        //TODO: Alart, update faile
    }
}

- (IBAction)helpBtnClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.zomeapp.com/qa.html"]];
}

- (IBAction)termBtnClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.zomeapp.com/terms.html"]];
}

- (IBAction)aboutZomeBtnClicked:(id)sender {
    NSString *title = [NSString stringWithFormat:@"Current Version V%@", APPDELEGATE.version];
    NSString *message = [NSString stringWithFormat:@"Latest Version V%@", APPDELEGATE.version];
    [self showAlertBox:title
               message:message
                button:@"OK"];
}

- (void)selectProfilePicture{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [Picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [Picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [thumbnail setImage:[self squareImage:image]];
    
    NSData *imageData = UIImageJPEGRepresentation(thumbnail.image, 1.0);
    NSString *encodedImage = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [APPDELEGATE.mainVC requestProfileUpdate:encodedImage];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) updateProfileImage: (NSString *)imageURL
{
    [thumbnail setImage:[self getImageFromURL:imageURL]];
}

- (IBAction)logout:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"loginType"];
    NSLog(@"set loginType to nil");
    [APPDELEGATE disconnectServer];
    [self performSelector:@selector(toLoginView) withObject:nil afterDelay:0.0];
}

- (void) toLoginView
{
//    [self dismissViewControllerAnimated:YES completion:nil];
//    LoginViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
//    [self presentViewController:loginView  animated:YES completion:nil];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    LoginViewController *rootView = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    [appDel.window setRootViewController:rootView];
}


- (UIImage *) getImageFromURL: (NSString *) imageURL{
    if ([imageURL isEqualToString:@""]) {
        return nil;
    }
    UIImage *img = [APPDELEGATE.imageCache objectForKey:imageURL];
    if(!img){
        img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: imageURL]]];
        if(img){
            [APPDELEGATE.imageCache setObject:img forKey:imageURL];
        }
    }
    return [self squareImage:img];
}

- (UIImage *)squareImage:(UIImage *)image
{
    CGSize newSize = CGSizeMake(120, 120);
    double ratio;
    double delta;
    CGPoint offset;
    
    CGSize sz = CGSizeMake(newSize.width, newSize.width);

    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)editUsernameBtnClick:(id)sender {
    UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 245.0, 25.0)];
    UIAlertView *changeNameAlert = [[UIAlertView alloc] initWithTitle:@"Edit Username"
                                                              message:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Save", nil];
    [changeNameAlert addSubview:nameField];
    changeNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [changeNameAlert show];
}

-(void)willPresentAlertView:(UIAlertView *)alertView {
    if(![APPDELEGATE.loginType isEqualToString:@"Anonymous"]){
        //        if(_timeSinceLastRoom >= 300 && APPDELEGATE.chatVC.ownedRoomName == nil){
        UITextField *nameField = [alertView textFieldAtIndex:0];
        [nameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"New Username"]];
        nameField.delegate = self;
        //        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.cancelButtonIndex == buttonIndex){
        NSLog(@"canceled");
    } else {
        NSString *newUsername = ((UITextField *)[alertView textFieldAtIndex:0]).text;
        [APPDELEGATE.mainVC requestUsernameChange:newUsername];
        [alertView removeFromSuperview];
    }
}

-(void)showAlertBox:(NSString *)title message:(NSString *)message button:(NSString *)buttonTitle
{
    UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:title
                                                              message:message
                                                             delegate:self
                                                    cancelButtonTitle:buttonTitle
                                                    otherButtonTitles:nil];
    [newMessageAlert show];
}

//- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
//    [FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, nil]];
//    if (FBSession.activeSession.isOpen) {
//        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection,id<FBGraphUser> fbUser,NSError *error) {
//            if (!error) {
//                NSString *fbID = fbUser.objectID;
//                NSLog(@"UserID: %@",fbID);
//                NSLog(@"TESTING: %@",fbUser.name);
//            }
//        }];
//    }
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"loginType"];
//    [APPDELEGATE disconnectServer];
//    [self toLoginView];
//}


@end
