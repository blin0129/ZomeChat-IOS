//
//  ThemePageViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 1/7/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "ChatroomListViewController.h"
#import "ChatViewController.h"
#import "ChatroomTableViewCell.h"

@interface ChatroomListViewController ()

@end

@implementation ChatroomListViewController

#pragma mark - Instance Variables

@synthesize choosedRoomKey;
@synthesize choosedRoomName;
@synthesize mapContainer;



-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        APPDELEGATE.chatroomListVC = self;
    }
    return self;
}

- (void)viewDidLoad
{
//    APPDELEGATE.chatroomListVC = self;
    [super viewDidLoad];
    [self customNavBar];
    [self loadMap];
    [APPDELEGATE.mainVC requestChatroomList];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-babyblue"]]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = .5;
    longPressGesture.delegate = self;
    [self.view addGestureRecognizer:longPressGesture];
}

- (void)customNavBar
{
    self.navigationItem.title = @"Nearby Chatrooms";
    
    UIBarButtonItem * plus= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_icon_plus"] style:UIBarButtonItemStylePlain target:self action:@selector(createNewRoom)];
    UIBarButtonItem * reload= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_icon_reload"] style:UIBarButtonItemStylePlain target:self action:@selector(requestChatroomListUpdate)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,plus ,nil];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,reload ,nil];
}

-(void)loadMap{
    mapContainer.frame = [APPDELEGATE.mainVC mapView].frame;
    [mapContainer addSubview:[APPDELEGATE.mainVC mapView]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 20) ? NO : YES;
}

- (void) requestChatroomListUpdate
{
    [APPDELEGATE.mainVC requestChatroomList];
}

- (void) updateChatroomList:(NSDictionary *)data
{
    APPDELEGATE.mainVC.defaultRoomList = [[NSMutableArray alloc] initWithObjects: nil];
    APPDELEGATE.mainVC.customRoomList = [[NSMutableArray alloc] initWithObjects: nil];

    NSArray *receiveList = [data objectForKey:@"chatrooms"];
    
    [APPDELEGATE.mainVC cleanAllMarkerFromMap];
    for(int i=0;i<receiveList.count;i++)
    {
        NSDictionary *roomInfo = [receiveList objectAtIndex:i];
        NSString *roomType = [roomInfo objectForKey:@"roomType"];
        if ([roomType isEqualToString:@"MANUAL"] || [roomType isEqualToString:@"DEFAULT"]){
            [APPDELEGATE.mainVC.defaultRoomList addObject:roomInfo];
        } else if([roomType isEqualToString:@"CUSTOM"]){
            [APPDELEGATE.mainVC.customRoomList addObject:roomInfo];
        } else {
            [APPDELEGATE.mainVC.customRoomList addObject:roomInfo];
        }
        
        //Add marks on google map
        float lng = [[roomInfo objectForKey:@"lng"] floatValue];
        float lat = [[roomInfo objectForKey:@"lat"] floatValue];
        [APPDELEGATE.mainVC addMapMarkerWithLongitude:lng latitude:lat roomName:[roomInfo objectForKey:@"roomName"]];
    }
    [self.tableView reloadData];
    if (receiveList.count == 1) {
        [self performSelector:@selector(suggestCreateNewRoom) withObject:self afterDelay:0.5];
    }
}

-(void)suggestCreateNewRoom
{
    _popupType = @"SUGGESTCREATE";
    NSString *title = @"No Chatrooms Exist!";
    NSString *message = @"Do you wish to create one?";
    UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:title
                                                              message:message
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Create", nil];
    [newMessageAlert show];
}

//TODO REDEFINED THIS METHOD
-(NSArray *) sortThemeList:(NSArray *)receiveList
{
    NSArray *sortedArray = [receiveList sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
        float dist1 = [[item1 objectForKey:@"distance"] floatValue];
        float dist2 = [[item2 objectForKey:@"distance"] floatValue];
        if (dist1 > dist2)
            return NSOrderedDescending;
        else if (dist1 < dist2)
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    return sortedArray;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return APPDELEGATE.mainVC.defaultRoomList.count;
            break;
        case 1:
            return APPDELEGATE.mainVC.customRoomList.count;
            break;
        default:
            return 0;
            break;
    }
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [sectionView setBackgroundColor:UIColorFromRGB(0xcbe1ed)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, -3, tableView.bounds.size.width, 30)];
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [sectionView addSubview:titleLabel];
    
    switch (section) {
        case 0:
            titleLabel.text = @"Based on Your Locaiton";
            break;
        case 1:
            titleLabel.text = @"Other Local Chatrooms";
            break;
        default:
            titleLabel.text = @"";
            break;
    }

    return sectionView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatroomListCell";
    UILabel *userCountLabel;
    ChatroomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[ChatroomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        
        userCountLabel = [[UILabel alloc] init];
        userCountLabel.font = [UIFont systemFontOfSize:14];
        userCountLabel.textColor = [UIColor whiteColor];
        userCountLabel.tag = 2;
        [cell.contentView addSubview:userCountLabel];
        
        [userCountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:userCountLabel
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:-10]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:userCountLabel
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0]];
        
    } else {
        userCountLabel = (UILabel *)[cell.contentView viewWithTag:2];
    }
    
    cell.imageView.image = [[UIImage imageNamed:@"icon_chat_bubble"] jsq_imageMaskedWithColor:[UIColor whiteColor]];
    
    if (indexPath.section == 0) {
        NSString *userCountString = [NSString stringWithFormat:@"%@ users",[[APPDELEGATE.mainVC.defaultRoomList objectAtIndex:indexPath.row] objectForKey:@"userCount"]];
        userCountLabel.text = userCountString;
        [userCountLabel sizeToFit];
        cell.textLabel.text = [[APPDELEGATE.mainVC.defaultRoomList objectAtIndex:indexPath.row] objectForKey:@"roomName"];
    } else if(indexPath.section == 1){
        NSString *userCountString = [NSString stringWithFormat:@"%@ users",[[APPDELEGATE.mainVC.customRoomList objectAtIndex:indexPath.row] objectForKey:@"userCount"]];
        userCountLabel.text = userCountString;
        [userCountLabel sizeToFit];
        cell.textLabel.text = [[APPDELEGATE.mainVC.customRoomList objectAtIndex:indexPath.row] objectForKey:@"roomName"];
    }
    
    
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *list;
    if(indexPath.section == 0){
        list = APPDELEGATE.mainVC.defaultRoomList;
    } else if(indexPath.section == 1){
        list = APPDELEGATE.mainVC.customRoomList;
    }
    choosedRoomName = [[list objectAtIndex:indexPath.row] objectForKey:@"roomName"];
    choosedRoomKey = [[list objectAtIndex:indexPath.row] objectForKey:@"roomKey"];
    
    [APPDELEGATE.mainVC requestEnterChatroom:choosedRoomKey];
    
    ChatViewController *vc = [ChatViewController messagesViewController];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void) createNewRoom{
    if(APPDELEGATE.createChatroom){
        NSDate *lastRoomTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastRoomCreatedTime"];
        _timeSinceLastRoom = -1 * [lastRoomTime timeIntervalSinceNow];
        if (_timeSinceLastRoom < APPDELEGATE.creatingChatroomTimerOffset && lastRoomTime != nil){
            NSString *message = [NSString stringWithFormat:@"Please wait for %d min", (2 - (_timeSinceLastRoom/60))];
            [self showAlertBox:@"You Just Created a Room"
                       message:message
                        button:@"Okay"];
        } else {
            _popupType = @"NEWROOM";
            UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 245.0, 25.0)];
            UIAlertView *newRoomAlert = [[UIAlertView alloc] initWithTitle:@"New Chatroom"
                                                                   message:@"Class, Event, Interest, etc "
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                         otherButtonTitles:@"Create", nil];
            [newRoomAlert addSubview:nameField];
            newRoomAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [newRoomAlert show];
        }
    }else{
        [self showAlertBox:APPDELEGATE.createChatroomAlertTitle
                   message:APPDELEGATE.createChatroomAlertMessage
                    button:@"OK"];
    }
}



- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        
        ChatroomTableViewCell *cell = (ChatroomTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:cell.frame inView:cell.superview];
        [menu setMenuVisible:YES animated:YES];
        [cell becomeFirstResponder]; //here set the cell as the responder of the menu action
    }
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if(indexPath.section != 0){
        if (action == NSSelectorFromString(@"report:")) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if(indexPath.section != 0){
        if(action == NSSelectorFromString(@"report:")){
            NSString *displayMsg = [[APPDELEGATE.mainVC.customRoomList objectAtIndex:indexPath.row] objectForKey:@"roomName"];
            _popupType = @"REPORT";
            _reportChatroomId =[[APPDELEGATE.mainVC.customRoomList objectAtIndex:indexPath.row] objectForKey:@"roomKey"];
            UITextField *reasonTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 245.0, 25.0)];
            UIAlertView *reportAlert = [[UIAlertView alloc] initWithTitle:@"Report This Chatroom:"
                                                                  message:displayMsg
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:@"Report", nil];
            [reportAlert addSubview:reasonTextField];
            reportAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [reportAlert show];
        }
    }
}

-(void)willPresentAlertView:(UIAlertView *)alertView {
    if([_popupType isEqualToString:@"REPORT"]){
        UITextField *reasonTextField = [alertView textFieldAtIndex:0];
        [reasonTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Reason"]];
        reasonTextField.delegate = self;
    } else if([_popupType isEqualToString:@"NEWROOM"]){
        if(APPDELEGATE.createChatroom){
            UITextField *nameField = [alertView textFieldAtIndex:0];
            [nameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Room Title"]];
            nameField.delegate = self;
        }
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.cancelButtonIndex != buttonIndex){
        if([_popupType isEqualToString:@"REPORT"]){
            NSString *reportReason = ((UITextField *)[alertView textFieldAtIndex:0]).text;
            if([reportReason isEqual:@""]){
                [self showAlertBox:@"Report Fail"
                           message:@"Please enter report reason"
                            button:@"OK"];
            } else {
                [APPDELEGATE.mainVC requestReportViolationOf:@"CHATROOM" withId:_reportChatroomId andReason:reportReason];
                [self showAlertBox:@"Report Succeed"
                           message:@"This Chatroom is going under our inspection list. It will be removed shortly if it violates our terms"
                            button:@"OK"];
            }
        } else if([_popupType isEqualToString:@"NEWROOM"]){
            NSString *newRoomName = ((UITextField *)[alertView textFieldAtIndex:0]).text;
            ChatViewController *vc = [ChatViewController messagesViewController];
            [self.navigationController pushViewController:vc animated:YES];
            [APPDELEGATE.mainVC requestCreateNewRoom:newRoomName];
        } else if([_popupType isEqualToString:@"SUGGESTCREATE"]) {
            [self createNewRoom];
        }
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


@end
