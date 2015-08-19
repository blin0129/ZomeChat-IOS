//
//  LoginViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatroomUserTable.h"
#import "UIImage+ProportionalFill.h"
#import "ChatImageViewController.h"

@implementation ChatViewController{
    UIBarButtonItem *saveBtn;
    UIBarButtonItem *settingsBtn;
}

@synthesize roomKey;
@synthesize roomName;
@synthesize userCount;
@synthesize chatroomUsers;
@synthesize userImageDictionary;
@synthesize imgPicker;
@synthesize sendingImage;
@synthesize zoomImageURL;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        APPDELEGATE.chatVC = self;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    APPDELEGATE.chatVC = self;
    [super viewDidLoad];
    self.roomName =[APPDELEGATE.chatroomListVC choosedRoomName];
    self.roomKey =[APPDELEGATE.chatroomListVC choosedRoomKey];
    self.navigationItem.title = self.roomName;
    self.senderId = APPDELEGATE.uid;
    self.userImageDictionary = [[NSMutableDictionary alloc] init];
    self.collectionView.delegate = self;
    
    //Background
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-babyblue"]]];
    
    UIButton *cameraButton = [[UIButton alloc] init];
    [cameraButton setImage:[UIImage imageNamed:@"btn_cam"] forState:UIControlStateNormal];
    self.inputToolbar.contentView.leftBarButtonItem = cameraButton;
    
    // Nav Bar Buttons
    saveBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_icon_like"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:nil];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    
    settingsBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_icon_group"]
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(receiveMessagePressed:)];
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, settingsBtn, saveBtn];
    
    self.chatData = [[ChatroomData alloc] init];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(50, 50);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closePressed:)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self view] endEditing: YES];
}

-(void)tap:(UITapGestureRecognizer *)tapRec{
    [[self view] endEditing: YES];
}

-(void) receiveMessage:(NSDictionary *)data
{
    [self fetchMessage:data];
    [self finishReceivingMessage];
}

-(void) updateChatroomUserList:(NSDictionary *)data
{
    self.chatroomUsers = [data objectForKey:@"users"];
    [self fetchUserAvatar:self.chatroomUsers];
}

-(void) initRoom:(NSDictionary *)data
{
    self.roomKey = [data objectForKey:@"roomKey"];
    self.roomName = [data objectForKey:@"roomName"];
    self.chatroomUsers = [data objectForKey:@"chatroomUsers"];
    [self fetchUserAvatar:[data objectForKey:@"chatroomUsers"]];
    self.userCount = [[data objectForKey:@"userCount"] integerValue];

    [self fetchMessageHistory:[data objectForKey:@"messageHistory"]];
    [self finishReceivingMessage];
    self.title = self.roomName;

}

-(void) fetchMessageHistory:(NSArray *)history
{
    if(history == nil){
        return;
    }
    for(NSDictionary *obj in history){
        [self fetchMessage:obj];
    }
}

-(void) fetchMessage:(NSDictionary *)messageObj
{
    NSString *msgSenderName = [messageObj objectForKey:@"senderName"];
    NSString *msgSenderId = [messageObj objectForKey:@"senderId"];
    NSString *senderImageURL = [messageObj objectForKey:@"senderImageURL"];
    NSString *msgId = [messageObj objectForKey:@"messageId"];

    if(senderImageURL != nil){
        [userImageDictionary setObject:senderImageURL forKey:msgSenderId];
    }
    
    float messageSentTime = [[messageObj objectForKey:@"time"] floatValue] / 1000;
    NSDate *timeInNSDate = [NSDate dateWithTimeIntervalSince1970:messageSentTime];

    if([[messageObj objectForKey:@"isImage"] boolValue] == YES){
        NSString *imageURL = [messageObj objectForKey:@"message"];
        UIImage *image = [APPDELEGATE.imageCache objectForKey:imageURL];
        if(!image){
            image = [self getImageFromURL:imageURL];
        }
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
        JSQMediaMessage *photoMessage = [JSQMediaMessage messageWithSenderId:msgSenderId
                                                                 displayName:msgSenderName
                                                                       media:photoItem];
        [photoMessage setMessageId:msgId];
        [photoItem setImageURL:imageURL];
        [self.chatData.messages addObject:photoMessage];

    }else{
        NSString *receivedMessage = [messageObj objectForKey:@"message"];
        JSQTextMessage *message = [[JSQTextMessage alloc] initWithSenderId:msgSenderId
                                                         senderDisplayName:msgSenderName
                                                                      date:timeInNSDate
                                                                      text:receivedMessage];
        [message setMessageId: msgId];
        [self.chatData.messages addObject:message];
    }
}



-(void) fetchUserAvatar:(NSArray *)userList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSDictionary *obj in userList){
            NSString *userName = [obj objectForKey:@"username"];
            NSString *photoLink = [obj objectForKey:@"imageURL"];
            if (photoLink != nil) {
                [userImageDictionary setObject:photoLink forKey:self.senderId];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });

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
    return [self resizeImage:img];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [APPDELEGATE.mainVC requestLeaveChatroom:roomKey];
    }
    [super viewWillDisappear:animated];
}



#pragma mark - Actions

- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    ChatroomUserTable *chatroomUserTVC =  [[ChatroomUserTable alloc] init];
    [self.navigationController pushViewController:chatroomUserTVC animated:YES];
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissJSQDemoViewController:self];
}


#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    if(APPDELEGATE.chatroomConversation){
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        [APPDELEGATE.mainVC requestSendMessage:text inRoom:roomKey];
        [self finishSendingMessage];
    }else{
        [self showAlertBox:APPDELEGATE.chatroomConversationAlertTitle
                   message:APPDELEGATE.chatroomConversationAlertMessage
                    button:@"OK"];
    }
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    if(APPDELEGATE.chatroomSendImage){
        imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.delegate = self;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }else{
        [self showAlertBox:APPDELEGATE.chatroomSendImageAlertTitle
                   message:APPDELEGATE.chatroomSendImageAlertMessage
                    button:@"OK"];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    sendingImage = [self resizeImage:img];
    [self sendImageAlert:sendingImage];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)sendImageAlert:(UIImage *)image{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    float imgRatio  = imgView.bounds.size.width / imgView.bounds.size.height;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:imgView attribute:NSLayoutAttributeHeight multiplier:imgRatio constant:0.0f];
    
    [imgView addConstraint:constraint];
    _popupType = @"PICTURE";
    UIAlertView *sendingImageAlert = [[UIAlertView alloc] initWithTitle:@"Sending Image"
                                                           message:@""
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Send", nil];
    [sendingImageAlert setValue:imgView forKey:@"accessoryView"];
    [sendingImageAlert show];
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
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.chatData.messages objectAtIndex:indexPath.item];
}

//- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [self.messages objectAtIndex:indexPath.item];
//}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.chatData.outgoingBubbleImageData;
    }
    
    return self.chatData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
    if([message.senderId isEqualToString:self.senderId]){
        return nil;
    }else{
        NSString *imageLink = [userImageDictionary objectForKey:message.senderId];
        UIImage *img = [self getImageFromURL:imageLink];
        if(img != nil){
            return [JSQMessagesAvatarImageFactory avatarImageWithImage:img
                                                   diameter:40.0f];
        }
        img = [UIImage imageNamed:@"anonymous"];
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:img
                                                          diameter:40.0f];
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.chatData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    JSQMessage *msg = [self.chatData.messages objectAtIndex:indexPath.item];
    
    if ([msg.senderId isEqualToString:self.senderId]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.chatData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    JSQMessage *message = [self.chatData.messages objectAtIndex:indexPath.item];
    if([message isMediaMessage] == YES){
        JSQPhotoMediaItem *photoMessage = (JSQPhotoMediaItem *)[message media];
        zoomImageURL =[photoMessage getImageURL];
//        ChatImageViewController *vc = [ChatImageViewController self];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        ChatImageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChatImage"];
        [self.navigationController pushViewController:vc animated:YES];
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

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    if (action == NSSelectorFromString(@"copy:")) {
        return YES;
    }
    return NO;
}

- (void)collectionView:(JSQMessagesViewController *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if(action == NSSelectorFromString(@"copy:")){
        id<JSQMessageData> messageData = [self collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:[messageData text]];
    } else if(action == NSSelectorFromString(@"report:")){
        _popupType = @"REPORT";
        JSQMessage *reportedMsg = [self.chatData.messages objectAtIndex:indexPath.item];
        _reportMessageId =[[self.chatData.messages objectAtIndex:indexPath.item] getMessageId];
        NSString *displayMsg = @"";
        if(reportedMsg.isMediaMessage){
            displayMsg = @"(Picture)";
        } else {
            displayMsg = reportedMsg.text;
        }
        UITextField *reasonTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 245.0, 25.0)];
        UIAlertView *reportAlert = [[UIAlertView alloc] initWithTitle:@"Report This Message:"
                                                               message:displayMsg
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Report", nil];
        [reportAlert addSubview:reasonTextField];
        reportAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [reportAlert show];
    }
}

-(void)willPresentAlertView:(UIAlertView *)alertView {
    UITextField *reasonTextField = [alertView textFieldAtIndex:0];
    [reasonTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Reason"]];
    reasonTextField.delegate = self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.cancelButtonIndex != buttonIndex){
        if([_popupType isEqualToString:@"PICTURE"]){
            [APPDELEGATE.mainVC requestSendImage:[self encodeToBase64String:sendingImage] inRoom:roomKey];
        } else if([_popupType isEqualToString:@"REPORT"]) {
            NSString *reportReason = ((UITextField *)[alertView textFieldAtIndex:0]).text;
            if([reportReason isEqual:@""]){
                [self showAlertBox:@"Report Fail"
                           message:@"Please enter report reason"
                            button:@"OK"];
            } else {
                [APPDELEGATE.mainVC requestReportViolationOf:@"MESSAGE" withId:_reportMessageId andReason:reportReason];
                [self showAlertBox:@"Report Succeed"
                           message:@"This message is going under our inspection list. It will be removed shortly if it violates our terms"
                            button:@"OK"];
            }
        }
        _popupType = @"";
    }
}


@end
