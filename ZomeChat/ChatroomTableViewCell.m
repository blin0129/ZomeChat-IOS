//
//  ChatroomTableViewCell.m
//  ZomeChat
//
//  Created by Brian Lin on 4/10/15.
//  Copyright (c) 2015 Zome. All rights reserved.
//

#import "ChatroomTableViewCell.h"

@implementation ChatroomTableViewCell

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(report:))
    {
        return YES;
    }
    return NO;
}

-(void)report:(id)sender
{
    UIView* v = self;
    do {
        v = v.superview;
    } while (![v isKindOfClass:[UITableView class]]);
    UITableView* cv = (UITableView*) v;
    // ask it what index path we are
    NSIndexPath* ip = [cv indexPathForCell:self];
    if (cv.delegate && [cv.delegate respondsToSelector: @selector(tableView:performAction:forRowAtIndexPath:withSender:)]){
        [cv.delegate tableView:cv performAction:_cmd forRowAtIndexPath:ip withSender:sender];
    }
}


@end
