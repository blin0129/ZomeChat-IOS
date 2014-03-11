//
//  ProfilePageViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 1/13/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilePageViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController *picker;
}

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *changePicButton;

-(void) receiveMyProfile: (SocketIOPacket *)packet;

@end
