//
//  ProfilePageViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 1/13/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ProfilePageViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate,FBLoginViewDelegate>{
    UIImagePickerController *picker;
}

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *editUserNameBtn;
@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (weak, nonatomic) IBOutlet UIButton *LogoutBtn;
@property UIImage *oldImage;

-(void) receiveMyProfile: (NSDictionary *)packet;
-(void) receiveProfileUpdateRespond: (NSDictionary *)packet;
-(void) updateProfileImage: (NSString *)imageURL;
@end
