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

@interface ChatViewController : JSQMessagesViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;
@property (copy, nonatomic) NSDictionary *avatars;
@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@property (strong, nonatomic) NSString *roomKey;
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSMutableDictionary *chatroomUsers;
@property (strong, nonatomic) NSMutableDictionary *userImageDictionary;
//@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) ChatroomData *chatData;
@property (nonatomic, retain) UIImagePickerController *imgPicker;
@property (nonatomic, retain) UIImage *sendingImage;
@property (nonatomic, retain) NSString *zoomImageURL;
@property int userCount;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;
- (void)closePressed:(UIBarButtonItem *)sender;

-(void) initRoom:(SocketIOPacket *)packet;
-(void) receiveMessage:(SocketIOPacket *)packet;
-(void) updateChatroomUserList:(SocketIOPacket *)packet;

//-(void) receivedImage:(NSString *)imageString inRoom:(NSString *)roomKey fromSender:(NSString *)sender;


@end
