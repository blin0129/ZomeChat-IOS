//
//  ProfilePageViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 1/13/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewPostViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (nonatomic, retain) UIImagePickerController *imgPicker;
@property (weak, nonatomic) IBOutlet UITextView *postMessage;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *addPictureBtn;
@property (weak, nonatomic) IBOutlet UIButton *removePictureBtn;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) UIImage *postingImage;
@property UIImage *oldImage;

@end
