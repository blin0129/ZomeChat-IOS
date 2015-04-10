//
//  ProfilePageViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 1/13/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "NewPostViewController.h"
#import "UIImage+ProportionalFill.h"

@interface NewPostViewController ()

@end

@implementation NewPostViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
//        APPDELEGATE.newPostVC = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"New Post";

    UIView *contentBox = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width - 20, self.view.bounds.size.height - 20)];
    contentBox.backgroundColor = [UIColor whiteColor];
    contentBox.layer.masksToBounds = NO;
    contentBox.layer.cornerRadius = 4;
    [self.view addSubview:contentBox];
    [self.view sendSubviewToBack:contentBox];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-babyblue"]]];
    
    self.postMessage.layer.borderWidth = 1;
    self.postMessage.tintColor = [UIColor lightGrayColor];
    self.postMessage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.postMessage.layer.cornerRadius = 4;
    self.postMessage.delegate = self;

    self.sendButton.tintColor = [UIColor lightGrayColor];
    self.sendButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.sendButton.layer.borderWidth = 1;
    self.sendButton.layer.cornerRadius = 4;
    
    self.cancelButton.tintColor = [UIColor lightGrayColor];
    self.cancelButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.cancelButton.layer.borderWidth = 1;
    self.cancelButton.layer.cornerRadius = 4;
    
    self.addPictureBtn.tintColor = [UIColor lightGrayColor];
    self.addPictureBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.addPictureBtn.layer.borderWidth = 1;
    self.addPictureBtn.layer.cornerRadius = 4;
    self.addPictureBtn.layer.masksToBounds = YES;
    self.addPictureBtn.backgroundColor = [UIColor whiteColor];
    
    self.removePictureBtn.tintColor = [UIColor lightGrayColor];
    self.removePictureBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.removePictureBtn.layer.borderWidth = 1;
    self.removePictureBtn.layer.cornerRadius = 4;
    self.removePictureBtn.layer.masksToBounds = YES;
    self.removePictureBtn.backgroundColor = [UIColor whiteColor];
    self.removePictureBtn.hidden = YES;
    
//    self.addPictureBtn.layer.borderWidth = 1;
    self.postImageView.layer.cornerRadius = 4;
    self.postImageView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:textView.text];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,[string length])];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0f] range:NSMakeRange(0,[string length])];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:textView.text options:0 range:NSMakeRange(0, textView.text.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x5c9fd6) range:wordRange];
    }
    [textView setAttributedText:string];
}

-(void)tap:(UITapGestureRecognizer *)tapRec{
    [[self view] endEditing: YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
    }
    return YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [Picker dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)removePictureBunClick:(id)sender {
    self.removePictureBtn.hidden = YES;
    self.addPictureBtn.hidden = NO;
    self.postingImage = nil;
    self.postImageView.image = nil;
}

- (IBAction)addPictureBtnClick:(id)sender {
    if(APPDELEGATE.postFeedImage){
        self.imgPicker = [[UIImagePickerController alloc] init];
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imgPicker.delegate = self;
        [self presentViewController:self.imgPicker animated:YES completion:nil];
    }else{
        [self showAlertBox:APPDELEGATE.postImageAlertTitle
                   message:APPDELEGATE.postImageAlertMessage
                    button:@"OK"];
    }
}

- (IBAction)postBtnClick:(id)sender {
    NSString *imgString = [self encodeToBase64String:self.postingImage];
    if(imgString == nil){
        imgString = @"";
    }
    if(![self.postMessage.text isEqualToString:@""]){
        [APPDELEGATE.mainVC requestCreateNewMessage:self.postMessage.text withImage:imgString];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    self.postingImage = [self resizeImage:img];
    [self.postImageView setImage:self.postingImage];
    [self.postImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imgPicker dismissViewControllerAnimated:NO completion:nil];
    self.removePictureBtn.hidden = NO;
    self.addPictureBtn.hidden = YES;
}

- (UIImage *) resizeImage:(UIImage *)originalImage {
    float height = originalImage.size.height;
    float width = originalImage.size.width;
    float heightScale = height/[[UIScreen mainScreen] bounds].size.height;
    float weidthScale = width/[[UIScreen mainScreen] bounds].size.width;
    float finalScale = 1;
    if(heightScale > weidthScale && heightScale >= 1){
        finalScale = 0.5 / heightScale;
    } else if (weidthScale > heightScale && weidthScale >= 1) {
        finalScale = 0.5 / weidthScale;
    }
    CGSize newSize = CGSizeMake(width * finalScale, height * finalScale);
    UIImage *newImage =[originalImage imageCroppedToFitSize:newSize];
    return newImage;
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    if(!image)
        return nil;
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
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

@end
