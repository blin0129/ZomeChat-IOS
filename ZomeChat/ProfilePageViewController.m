//
//  ProfilePageViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 1/13/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "ProfilePageViewController.h"

@interface ProfilePageViewController ()

@end

@implementation ProfilePageViewController
@synthesize saveButton;
@synthesize cancelButton;
@synthesize thumbnail;
@synthesize changePicButton;

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
    
    UIImageView *backgroundIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-lightblue.png"]];
    backgroundIV.frame = self.view.bounds;
    [self.view addSubview:backgroundIV];
    [self.view sendSubviewToBack:backgroundIV];
    
    changePicButton.layer.borderWidth = 2;
    changePicButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    changePicButton.layer.cornerRadius = 8;
    changePicButton.layer.masksToBounds = YES;
    [changePicButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    cancelButton.layer.borderWidth = 2;
    cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    cancelButton.layer.cornerRadius = 8;
    
    saveButton.layer.borderWidth = 2;
    saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    saveButton.layer.cornerRadius = 8;
    [APPDELEGATE.mainVC requestProfile];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:saveButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:10]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:-10]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) receiveMyProfile: (SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    
    if([dic objectForKey:@"photo"] != nil &&  [dic objectForKey:@"photo"] != [NSNull null]){
        NSData *data = [[NSData alloc] initWithBase64EncodedString:[dic objectForKey:@"photo"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [[UIImage alloc] initWithData:data];
        [thumbnail setImage:image];
        //        thumbnailView.backgroundColor = [UIColor blueColor];
        //        NSLog(@"photo size width:%f height:%f", image.size.width, image.size.height);
    } else {
        [thumbnail setBackgroundColor:[UIColor lightGrayColor]];
    }
}

- (IBAction)saveButtonClick:(id)sender {
    NSData *imageData = UIImageJPEGRepresentation(thumbnail.image, 1.0);
    NSString *encodedImage = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [APPDELEGATE.mainVC requestProfileUpdate:encodedImage];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)profileChangeButtonClick:(id)sender {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    } else{
//        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    }
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [Picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *) Picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //    NSLog(@"image selected");
    [Picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [thumbnail setImage:[self squareImage:image]];
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


@end
