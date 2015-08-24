//
//  LoginViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 12/15/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import "JSQMessages.h"
#import "JSQMessageData.h"
#import "ChatroomData.h"

@class ChatViewController;


@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(ChatViewController *)vc;

@end

@interface ChatViewController : JSQMessagesViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, JSQMessagesCollectionViewCellDelegate>

@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;
@property (copy, nonatomic) NSDictionary *avatars;
@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@property (strong, nonatomic) NSString *roomKey;
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSMutableArray *chatroomUsers;
@property (strong, nonatomic) NSMutableDictionary *userImageDictionary;
//@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) ChatroomData *chatData;
@property (nonatomic, retain) UIImagePickerController *imgPicker;
@property (nonatomic, retain) UIImage *sendingImage;
@property (nonatomic, retain) NSString *zoomImageURL;
@property (nonatomic, retain) NSString *popupType;
@property (nonatomic, retain) NSString *reportMessageId;
@property int userCount;

@property int roomIndex;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;
- (void)closePressed:(UIBarButtonItem *)sender;

-(void) initRoom:(NSDictionary *)packet;
-(void) receiveMessage:(NSDictionary *)packet;
-(void) updateChatroomUserList:(NSDictionary *)packet;

//-(void) receivedImage:(NSString *)imageString inRoom:(NSString *)roomKey fromSender:(NSString *)sender;
- (void)appendToSavedChatroomsList;


@end
