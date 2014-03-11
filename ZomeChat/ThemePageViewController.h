//
//  ThemePageViewController.h
//  ZomeChat
//
//  Created by Brian Lin on 1/7/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemePageViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *createRoomButton;
@property int timeSinceLastRoom;
@end
