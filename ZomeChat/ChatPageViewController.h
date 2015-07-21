//
//  ChatPageViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 12/26/13.
//  Copyright (c) 2013 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Base64.h"

@class Room;

@interface ChatPageViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController *picker;
}


@property (weak, nonatomic) IBOutlet UILabel *noteOne;
@property (weak, nonatomic) IBOutlet UILabel *noteTwo;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UIBarItem *orientationBarItem;
@property (nonatomic, strong) IBOutlet UIBarItem *wrapBarItem;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *inputBoxView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UITextView *messageInputField;
@property (nonatomic, strong) NSMutableArray *rooms;
@property NSString *ownedRoomName;

-(void) printMessage:(NSString *)message inRoom:(NSString *)roomKey;
-(void) printImage:(NSString *)imageString inRoom:(NSString *)roomKey fromSender:(NSString *)sender;
//-(void) removeARoommate:(SocketIOPacket *)packet;
//-(void) addARoommate:(SocketIOPacket *)packet;
//-(void) initRoommate:(SocketIOPacket *)packet;
//-(void) addARoom:(SocketIOPacket *)packet;

- (IBAction)selectImageButtonClick:(id)sender;

@end
