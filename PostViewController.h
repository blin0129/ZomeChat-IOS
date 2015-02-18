//
//  PostViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 11/24/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessagesKeyboardController.h"

@interface PostViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *postData;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (weak, nonatomic) IBOutlet UIView *replyContainer;
@property (weak, nonatomic) IBOutlet UITextField *replyTextField;
@property (strong, nonatomic) JSQMessagesKeyboardController *keyboardController;
@property (weak, nonatomic) IBOutlet UITableView *commentTable;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSMutableArray *likes;
@property (strong, nonatomic) NSString *feedId;

- (void) receiveFeedDetail:(SocketIOPacket *)packet;

@end
