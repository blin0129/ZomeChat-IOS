//
//  ChatPageViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 12/26/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "ChatPageViewController.h"
#import "MainViewController.h"
#import "Room.h"


@interface ChatPageViewController ()

@property UIImageView *imageView;
@property CGRect messageInputFrame;
@property CGRect inputBoxFrame;
@property int keyboardOffset;
@property NSLayoutConstraint *imageToBottomConstraint;
@property BOOL sendImage;

@end

@implementation ChatPageViewController
@synthesize rooms;
@synthesize carousel;
@synthesize messageInputField;
@synthesize inputBoxView;
@synthesize sendButton;
@synthesize addImageButton;
@synthesize imageView;
@synthesize messageInputFrame;
@synthesize inputBoxFrame;
@synthesize sendImage;
@synthesize keyboardOffset;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        APPDELEGATE.chatVC = self;
        self.rooms = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Add image button size width:%f height:%f", addImageButton.frame.size.width, addImageButton.frame.size.height);
    sendButton.userInteractionEnabled = FALSE;
    addImageButton.userInteractionEnabled = FALSE;
//    addImageButton.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"cam.png"]];

    UIImageView *backgroundIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-lightblue.png"]];
    backgroundIV.frame = self.view.bounds;
    [self.view addSubview:backgroundIV];
    [self.view sendSubviewToBack:backgroundIV];
    
    messageInputField.delegate = self;
    self.carousel.type = iCarouselTypeCoverFlow2;
    sendImage = false;
    
//    iCarouselTypeLinear
//    iCarouselTypeRotary,
//    iCarouselTypeInvertedRotary,
//    iCarouselTypeCylinder,
//    iCarouselTypeInvertedCylinder,
//    iCarouselTypeWheel,
//    iCarouselTypeInvertedWheel,
//    iCarouselTypeCoverFlow,
//    iCarouselTypeCoverFlow2,
//    iCarouselTypeTimeMachine,
//    iCarouselTypeInvertedTimeMachine,
//    iCarouselTypeCustom
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [messageInputField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField){
        [textField resignFirstResponder];
    }
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    //# words constraint
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    
    //# lines constraint
    NSString *temp = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:temp attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:12.0]}];
    CGRect theSize = [content boundingRectWithSize:CGSizeMake(textView.frame.size.width,999)
                                           options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                           context:nil];
    int numLines = theSize.size.height / textView.font.lineHeight;
    return (newLength > 200 || numLines > 5) ? NO : YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) addARoom:(SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    NSString *roomName = [dic objectForKey:@"roomName"];
    NSString *roomKey = [dic objectForKey:@"roomKey"];

    NSInteger roomUserCount = [[dic objectForKey:@"userCount"] integerValue];
    Room *newRoom = [[Room alloc] initWithName:roomName Key:roomKey andUserCount:roomUserCount];
    NSInteger index = MAX(0, carousel.currentItemIndex);
    [rooms insertObject:newRoom atIndex:index];
    [carousel insertItemAtIndex:index animated:YES];
    if(rooms.count > 0){
        sendButton.userInteractionEnabled = TRUE;
        addImageButton.userInteractionEnabled = TRUE;
        [self.noteOne setHidden:TRUE];
        [self.noteTwo setHidden:TRUE];
    }
        //    NSLog(@"new room is added: %@ to index:%d", newRoom.name, newRoom.index);
}

-(Room *) findRoom:(NSString *)roomKey{
    for(Room *room in rooms){
        if([room.key isEqualToString:roomKey]){
            return room;
        }
    }
    return nil;
}

//-(void) loopRooms{
//    NSLog(@"total object in rooms list: %d",rooms.count);
//    for(int i = 0; i < rooms.count; i++){
//        if(rooms[i] != nil){
//            NSLog(@"%d %@",i, ((Room *)rooms[i]).name);
//        } else{
//            NSLog(@"%d is NULL",i);
//        }
//    }
//}

-(void) printMessage:(NSString *)message inRoom:(NSString *)roomKey{
    Room *currentRoom = [self findRoom:roomKey];
    [currentRoom addContent:message];
    for(NSNumber *index in carousel.indexesForVisibleItems){
        [carousel reloadItemAtIndex:[index integerValue] animated:FALSE];
    }
    //    [carousel reloadItemAtIndex:carousel.currentItemIndex animated:FALSE];
}

-(void) printImage:(NSString *)imageString inRoom:(NSString *)roomKey fromSender:(NSString *)sender{
    Room *currentRoom = [self findRoom:roomKey];
    NSString *name = [NSString stringWithFormat:@"%@:",sender];
    [currentRoom addImageSender:name];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [[UIImage alloc] initWithData:data];
    [currentRoom addImage:image];
//    NSString *encodedImage = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    for(NSNumber *index in carousel.indexesForVisibleItems){
        [carousel reloadItemAtIndex:[index integerValue] animated:FALSE];
    }
//    [carousel reloadItemAtIndex:carousel.currentItemIndex animated:FALSE];
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    keyboardOffset = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height - (APPDELEGATE.mainVC.tabBar.frame.size.height);
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES withTime:0.4];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO withTime:0.1];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height-( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

//-(void)textFieldDidBeginEditing:(UITextField *)sender
//{
//    if ([sender isEqual:messageInputField]){
//        if  (self.view.frame.origin.y >= 0)
//        {
//            [self setViewMovedUp:YES withTime:0.4];
//        }
//    }
//}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)up withTime:(float) sec
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:sec];
    
    CGRect rect = self.view.frame;
    if (up){
        rect.origin.y -= keyboardOffset;
    } else {
        rect.origin.y += keyboardOffset;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}



- (IBAction)sendMessage:(id)sender {
    NSString *roomKey = ((Room *)rooms[carousel.currentItemIndex]).key;
    if(sendImage){
        NSData *imageData = UIImageJPEGRepresentation(imageView.image, 1.0);
        NSString *encodedImage = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//        NSString *encodedImage = [imageData base64Encoding];
        [APPDELEGATE.mainVC requestSendImage:encodedImage inRoom:roomKey];
        [self closeImage];
    } else {
        NSString *message = self.messageInputField.text;
        self.messageInputField.text = nil;
        //    NSLog(@"sending message at room:%@", roomKey);
        if(![message isEqualToString:@""]){
            [APPDELEGATE.mainVC requestSendMessage:message inRoom:roomKey];
        }
    }
    [messageInputField resignFirstResponder];
}

-(void) initRoommate:(SocketIOPacket *)packet{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    
    NSString *roomKey = [dic objectForKey:@"roomKey"];
//    NSInteger roomUserCount = [[dic objectForKey:@"userCount"] integerValue];
    NSArray *receiveList = [dic objectForKey:@"users"];
    Room *theRoom = [self findRoom:roomKey];
    
    if (theRoom != Nil){
        for(NSDictionary *object in receiveList)
        {
            User *newRoommate = [[User alloc] initWithName:[object objectForKey:@"userName"]];
            float receivedLat = [[object objectForKey:@"lat"] floatValue];
            float receivedLng = [[object objectForKey:@"lng"] floatValue];
            [newRoommate addCoordinate:receivedLng :receivedLat];
            double distance = [APPDELEGATE.mainVC.currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:receivedLat longitude:receivedLng]];
            NSLog(@"%f distance",distance);
            [newRoommate addDistance:distance];
            if([object objectForKey:@"photo"] != nil && [object objectForKey:@"photo"] != [NSNull null]){
                NSData *data = [[NSData alloc] initWithBase64EncodedString:[object objectForKey:@"photo"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage *image = [[UIImage alloc] initWithData:data];
                [newRoommate addThumbnail:image];
            }
            [theRoom addARoommate:newRoommate];
        }
        [carousel reloadItemAtIndex:carousel.currentItemIndex animated:FALSE];
    }
}

-(void) addARoommate:(SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    NSString *roomKey = [dic objectForKey:@"roomKey"];
    Room *theRoom = [self findRoom:roomKey];
    NSDictionary *theUser = [dic objectForKey:@"user"];

    User *newRoommate = [[User alloc] initWithName:[theUser objectForKey:@"userName"]];
    float receivedLat = [[theUser objectForKey:@"lat"] floatValue];
    float receivedLng = [[theUser objectForKey:@"lng"] floatValue];
    [newRoommate addCoordinate:receivedLng :receivedLat];
    double distance = [APPDELEGATE.mainVC.currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:receivedLat longitude:receivedLng]];
    NSLog(@"%f distance",distance);
    [newRoommate addDistance:distance];
    if([theUser objectForKey:@"photo"] != nil){
        NSData *data = [[NSData alloc] initWithBase64EncodedString:[theUser objectForKey:@"photo"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [[UIImage alloc] initWithData:data];
        [newRoommate addThumbnail:[self squareImage:image]];
    }
    [theRoom addARoommate:newRoommate];
    for(NSNumber *index in carousel.indexesForVisibleItems){
        [carousel reloadItemAtIndex:[index integerValue] animated:FALSE];
    }

    //    [carousel reloadItemAtIndex:carousel.currentItemIndex animated:FALSE];
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
    image = nil;
    return newImage;
}


-(void) removeARoommate:(SocketIOPacket *)packet
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[[packet.args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    NSString *roomKey = [dic objectForKey:@"roomKey"];
    Room *theRoom = [self findRoom:roomKey];
    [theRoom removeARoommate:[dic objectForKey:@"uid"]];
    for(NSNumber *index in carousel.indexesForVisibleItems){
        [carousel reloadItemAtIndex:[index integerValue] animated:FALSE];
    }
    //    [carousel reloadItemAtIndex:carousel.currentItemIndex animated:FALSE];

}

- (IBAction)selectImageButtonClick:(id)sender {
    if([APPDELEGATE.loginType isEqualToString:@"Anonymous"]){
        UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"Register Require"
                                                                  message:@"Plase register to use this feature "
                                                                 delegate:self
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil];
        [newMessageAlert show];
    } else {
    messageInputFrame = messageInputField.frame;
    inputBoxFrame = inputBoxView.frame;
    
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
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [Picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image
{
    CGSize newSize = [self newImageSize:image.size.width:image.size.height];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = nil;
    return newImage;
}

-(CGSize) newImageSize:(float)originalWidth :(float)originalHeight
{
    int maxRatio = 1;
    int widthRatio = (originalWidth / messageInputField.bounds.size.width) * 2 + 1;
    int heightRatio = (originalHeight/ messageInputField.bounds.size.width) * 2 + 1;
    
    if(widthRatio >= heightRatio){
        maxRatio = widthRatio;
    } else {
        maxRatio = heightRatio;
    }
    
    return CGSizeMake(originalWidth/maxRatio, originalHeight/maxRatio);
}

- (void)imagePickerController:(UIImagePickerController *) Picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    NSLog(@"image selected");
    [Picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [self resizeImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
//    float startX = addImageButton.frame.origin.x + addImageButton.frame.size.width + 5;
    float startX = self.view.frame.size.width/2 - image.size.width/2;
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(startX, 10, image.size.width, image.size.height)];
    imageView.image = image;

    UIButton *closeImageButton = [[UIButton alloc] initWithFrame:CGRectMake(image.size.width-20,0,20,20)];
    closeImageButton.layer.borderWidth = 2;
    closeImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
    closeImageButton.layer.cornerRadius = 8;
    closeImageButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];

    [closeImageButton setTitle:@"X" forState:UIControlStateNormal];
    [closeImageButton addTarget:self
                    action:@selector(closeImage)
          forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    
    [imageView addSubview:closeImageButton];
    imageView.userInteractionEnabled = YES;
    
    [messageInputField setHidden:TRUE];
    [inputBoxView addSubview:imageView];
    
    _imageToBottomConstraint = [NSLayoutConstraint constraintWithItem:imageView
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:inputBoxView
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:-10];
    [inputBoxView addConstraint:_imageToBottomConstraint];
    
    sendImage = true;
}

-(void) closeImage{
    sendImage = false;
    [imageView setHidden:TRUE];
    imageView.image = nil;
    [messageInputField setHidden:FALSE];
    [inputBoxView removeConstraint:_imageToBottomConstraint];
}


#pragma mark -
#pragma mark iCarousel methods
//Cover Flow Animation

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [rooms count];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionSpacing: {
            return 0.08;
        }
        case iCarouselOptionTilt: {
            return 1.17;
        }
        default:{
            return value;
        }
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UITextField *label = nil;
    UITableView *tableView = nil;
    UITextView *textView = nil;
    UIButton *closeButton = nil;
    UIButton *userButton = nil;
    UILabel *roomKey = nil;

    if (view == nil)
    {
//        NSLog(@"Float width = %f", self.carousel.contentView.bounds.size.width);
//        NSLog(@"Float height = %f", self.carousel.contentView.bounds.size.height);
        view = [[UIView alloc] initWithFrame:self.carousel.contentView.bounds];
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        
        //Close button
        closeButton = [[UIButton alloc] init];
        closeButton.layer.borderWidth = 2;
        closeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        closeButton.layer.cornerRadius = 8;        [closeButton setTitle:@"X" forState:UIControlStateNormal];
        [closeButton addTarget:self
                        action:@selector(closeCurrentChatBox)
              forControlEvents:(UIControlEvents)UIControlEventTouchDown];
        closeButton.tag = 2;
        
        //Room Name
        label = [[UITextField alloc] init];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:24];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 1;
        
        //Users button
        userButton = [[UIButton alloc] init];
        userButton.layer.borderWidth = 2;
        userButton.layer.borderColor = [UIColor whiteColor].CGColor;
        userButton.layer.cornerRadius = 8;
        userButton.layer.masksToBounds = YES;
        [userButton addTarget:self
                       action:@selector(switchBoxContent)
             forControlEvents:(UIControlEvents)UIControlEventTouchDown];
        userButton.tag = 3;
        
        //RoomKey (Hidden)
        roomKey = [[UILabel alloc] init];
        roomKey.tag = 6;

        [view addSubview:label];
        [view addSubview:closeButton];
        [view addSubview:userButton];
        [view addSubview:roomKey];
        [roomKey setHidden:TRUE];
        
        [textView setHidden:FALSE];
        [tableView setHidden:TRUE];
        
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [userButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    } else {
        //get a reference to the label in the recycled view
        label = (UITextField *)[view viewWithTag:1];
        closeButton = (UIButton *) [view viewWithTag:2];
        userButton = (UIButton *) [view viewWithTag:3];
//        textView = (UITextView *) [view viewWithTag:4];
//        tableView = (UITableView *) [view viewWithTag:5];
        roomKey = (UILabel *) [view viewWithTag:6];
    }
    
    [userButton setTitle:[NSString stringWithFormat:@"%ld", (long)((Room *)rooms[index]).userCount] forState:UIControlStateNormal];
    
    tableView = ((Room *)rooms[index]).userTableView;
    tableView.tag = 5;
    [view addSubview:tableView];
    [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];

    textView = ((Room *)rooms[index]).contentView;
    textView.tag = 4;
    [view addSubview:textView];
    [textView setTranslatesAutoresizingMaskIntoConstraints:NO];

    label.text = [self checkRoomnameLength:((Room *)rooms[index]).name];
    roomKey.text = ((Room *)rooms[index]).key;

    [self chatboxConstrain:view:label:closeButton:userButton:textView:tableView];
    return view;
}

-(NSString *) checkRoomnameLength:(NSString *)roomname
{
    if (roomname.length > 12) {
        return [NSString stringWithFormat:@"%@ ...",  [roomname substringWithRange:NSMakeRange(0, 11)]];
    } else {
        return roomname;
    }
}

- (void) switchBoxContent
{
    //if textview is showing, switching to tableview
    if ([carousel.currentItemView viewWithTag:5].isHidden) {
        [[carousel.currentItemView viewWithTag:5] setHidden:FALSE];
        [[carousel.currentItemView viewWithTag:4] setHidden:TRUE];
        UIButton *button = (UIButton *) [carousel.currentItemView viewWithTag:3];
        button.backgroundColor = [UIColor lightGrayColor];
    } else{
        [[carousel.currentItemView viewWithTag:4] setHidden:FALSE];
        [[carousel.currentItemView viewWithTag:5] setHidden:TRUE];
        UIButton *button = (UIButton *) [carousel.currentItemView viewWithTag:3];
        button.backgroundColor = [UIColor clearColor];
    }
}

- (void) closeCurrentChatBox
{
    NSString *roomKey = ((UILabel *)[carousel.currentItemView viewWithTag:6]).text;
    Room *theRoom;
    for(Room *room in rooms){
        if (room != nil &&[room.key isEqualToString:roomKey])
        {
            if([room.name isEqualToString:self.ownedRoomName]){
                self.ownedRoomName = nil;
            }
            theRoom = room;
            break;
        }
    }
    [[carousel.currentItemView viewWithTag:4] removeFromSuperview];
    [[carousel.currentItemView viewWithTag:5] removeFromSuperview];
    [carousel removeItemAtIndex:[carousel currentItemIndex] animated:YES];
    [APPDELEGATE.mainVC requestLeaveRoom:theRoom.key];
    [theRoom cleanRoom];
    [rooms removeObject:theRoom];
    if(rooms.count == 0){
        sendButton.userInteractionEnabled = FALSE;
        addImageButton.userInteractionEnabled = FALSE;
        [self.noteOne setHidden:FALSE];
        [self.noteTwo setHidden:FALSE];
    }
}


- (void) chatboxConstrain: (UIView *)view :(UITextField *)label :(UIButton *)closeButton :(UIButton *)userButton :(UITextView *)textView :(UITableView *)tableView
{
    //closeButton align left of view
    [view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:5]];
    
    //closeButton align top of view
    [view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:5]];
    
    //roomName label align baseline of userButton
    [view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeBaseline
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:userButton
                                                     attribute:NSLayoutAttributeBaseline
                                                    multiplier:1
                                                      constant:0]];
    
    //center roomName label horizontally
    [view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];

    //userButton align right of view
    [view addConstraint:[NSLayoutConstraint constraintWithItem:userButton
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1
                                                      constant:-5]];
    //userButton align top of view
    [view addConstraint:[NSLayoutConstraint constraintWithItem:userButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:5]];

    
    
    //align top of textView to buttom of label
    [view addConstraint:[NSLayoutConstraint constraintWithItem:textView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:userButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:5]];
    
    //align bottom of textView to buttom of view
    [view addConstraint:[NSLayoutConstraint constraintWithItem:textView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:-5]];
    
    //align bottom of textView to left of view
    [view addConstraint:[NSLayoutConstraint constraintWithItem:textView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1
                                                      constant:5]];
    
    //align bottom of textView to right of view
    [view addConstraint:[NSLayoutConstraint constraintWithItem:textView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1
                                                      constant:-5]];

    //align top of tableView to buttom of label
    [view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:userButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:5]];
    
    //align bottom of tableView to buttom of view
    [view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:-5]];
    
    //align bottom of tableView to left of view
    [view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1
                                                      constant:5]];
    
    //align bottom of tableView to right of view
    [view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1
                                                      constant:-5]];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

@end
