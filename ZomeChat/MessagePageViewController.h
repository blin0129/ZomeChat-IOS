//
//  MessagePageViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 1/8/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagePageViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *createMessageButton;
@property int timeSinceLastMessage;
@end
