//
//  MessagePageViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 1/8/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "BulletinPageViewController.h"
#import "UIImage+ProportionalFill.h"
#import "PostTableViewCell.h"

@interface BulletinPageViewController ()

@end

@implementation BulletinPageViewController{
    NSDateFormatter *dateFormat;
}
@synthesize messageList;
@synthesize hashTagDictionary;
@synthesize pictureLoaded;
@synthesize tableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        APPDELEGATE.msglistVC = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customNavBar];
    messageList = [[NSMutableArray alloc] initWithObjects:nil];
    tableData = messageList;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:nil] forCellReuseIdentifier:@"PostCell"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-babyblue"]]];
    [APPDELEGATE.mainVC requestMsgboardData];
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = .5;
    longPressGesture.delegate = self;
    [self.view addGestureRecognizer:longPressGesture];
}

- (void)customNavBar
{
    self.navigationItem.title = @"Feed";
    UIBarButtonItem * item1= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_icon_plus"] style:UIBarButtonItemStylePlain target:self action:@selector(toNewPostPage)];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
        UIBarButtonItem * item2= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_icon_search"] style:UIBarButtonItemStylePlain target:self action:@selector(tagSearchAlert)];

    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:negativeSpacer, item1, nil];
    self.navigationItem.leftBarButtonItems =[NSArray arrayWithObjects:negativeSpacer, item2, nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateMsgboardMessages:(NSDictionary *)data
{
    pictureLoaded = false;
    [messageList removeAllObjects];
    NSArray *receiveList = [self sortMessageList:[data objectForKey:@"messages"]];
    if([receiveList count] == 0){
        [self emptyPostAlert];
        return;
    }
    hashTagDictionary = [[NSMutableDictionary alloc] init];
    for (NSDictionary *obj in receiveList){
        NSMutableDictionary* mObj = [obj mutableCopy];
        [messageList addObject:mObj];
        if ([[obj objectForKey:@"tags"] count] != 0) {
            for(NSString *tag in [obj objectForKey:@"tags"]){
                [self fetchHashTag:tag post:obj];
            }
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSDictionary *obj in receiveList){
            [self getImageFromURL:[obj objectForKey:@"imageURL"]];
        }
        pictureLoaded = true;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });

    tableData = messageList;
    [self.tableView reloadData];
}

- (void) updateFeedStatus:(NSString *)feedId likeCount:(NSNumber *)likesCount commentCount:(NSNumber *) commentsCount
{
    for(NSMutableDictionary *feed in messageList){
        if([[feed objectForKey:@"id"] isEqualToString:feedId]){
            [feed setValue:likesCount forKey:@"likesCount"];
            [feed setValue:commentsCount forKey:@"commentCount"];
            [self.tableView reloadData];
            return;
        }
    }
}

- (void) fetchHashTag:(NSString *)tag post:(NSDictionary *) post{
    if([hashTagDictionary objectForKey:tag] == nil){
        NSMutableArray *postsWithTags = [[NSMutableArray alloc] initWithObjects: post, nil];
        [hashTagDictionary setObject:postsWithTags forKey:tag];
    }else{
        [[hashTagDictionary objectForKey:tag] addObject:post];
    }
}

- (NSArray *) sortMessageList:(NSArray *)receiveList
{
    NSArray *sortedArray = [receiveList sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
        double time1 = [[item1 objectForKey:@"time"] doubleValue];
        double time2 = [[item2 objectForKey:@"time"] doubleValue];
        if (time1 < time2)
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    }];
    return sortedArray;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 200) ? NO : YES;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return tableData.count;
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
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, -3, tableView.bounds.size.width, 30)];
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [sectionView addSubview:titleLabel];
    
    switch (section) {
        case 0:
            titleLabel.text = @"Local feeds";
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[[tableData objectAtIndex:indexPath.row] objectForKey:@"content"] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:13.0]}];
    
    // check the cache first if enabled
#if PERFORMANCE_ENABLE_HEIGHT_CACHE
    NSNumber *cachedHeight = self.rowHeightCache[content.uniqueIdentifier];
    if (cachedHeight != nil) {
        return [cachedHeight floatValue];
    }
#endif
    
    float viewWidth = tableView.frame.size.width - 40;
    CGRect theSize = [content boundingRectWithSize:CGSizeMake(viewWidth, CGFLOAT_MAX)
                                           options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                           context:nil];
    float calculatedHeight = theSize.size.height+72;
    NSString *imageURL = [[tableData objectAtIndex:indexPath.row] objectForKey:@"imageURL"];
    if (![imageURL isEqualToString:@""]){
        UIImage *image;
        if(pictureLoaded){
            image = [self getImageFromURL:imageURL];
        }else{
            image = [UIImage imageNamed:@"loading"];
        }
        if(image){
            calculatedHeight += image.size.height;
        }
    }
    
#if PERFORMANCE_ENABLE_HEIGHT_CACHE
    self.rowHeightCache[message.uniqueIdentifier] = @(calculatedHeight);
#endif
    return calculatedHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"PostCell";
    PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [[PostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.usernameLabel.text = [[tableData objectAtIndex:indexPath.row] objectForKey:@"ownerName"];
    [cell.usernameLabel sizeToFit];
    double time =([[[tableData objectAtIndex:indexPath.row] objectForKey:@"time"] doubleValue]/1000);
    NSString * timeString = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    cell.timeLabel.text = timeString;
    cell.contentTextview.text = [[tableData objectAtIndex:indexPath.row] objectForKey:@"content"];
//    [cell.contentTextview sizeToFit];
    [self hashtagColor:cell.contentTextview];
    
    NSNumber *likesCount = [[tableData objectAtIndex:indexPath.row] objectForKey:@"likesCount"];
    NSNumber *commentCount = [[tableData objectAtIndex:indexPath.row] objectForKey:@"commentCount"];
    cell.likeCountLabel.text = [NSString stringWithFormat:@"%@",likesCount];
    cell.replyCountLabel.text = [NSString stringWithFormat:@"%@",commentCount];
    [cell.likeCountLabel sizeToFit];
    [cell.replyCountLabel sizeToFit];
    
    NSString *imageURL = [[tableData objectAtIndex:indexPath.row] objectForKey:@"imageURL"];
    if(![imageURL isEqualToString:@""]){
        UIImage *image;
        if(pictureLoaded){
            image = [self getImageFromURL:imageURL];
        } else {
            image = [UIImage imageNamed:@"loading"];
        }
        if(image){
            cell.postImageView.hidden = NO;
            cell.postImageView.image = image;
            [cell.postImageView setFrame:CGRectMake(cell.postImageView.frame.origin.x, cell.postImageView.frame.origin.y, image.size.width, image.size.height)];
        }
    }else {
        cell.postImageView.hidden = YES;
    }
    
    return cell;
    
}


- (void) hashtagColor:(UITextView *)textView{
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:textView.text];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,[string length])];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0f] range:NSMakeRange(0,[string length])];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:textView.text options:0 range:NSMakeRange(0, textView.text.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x5c9fd6) range:wordRange];
    }
    [textView setAttributedText:string];
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

- (UIImage *) resizeImage:(UIImage *)originalImage {
    float width = originalImage.size.width;
    float weidthScale = width/([[UIScreen mainScreen] bounds].size.width - 30);
    float finalScale = 1;
    if (weidthScale >= 1) {
        finalScale = 1 / weidthScale;
    }
    CGSize newSize = CGSizeMake(width * finalScale, originalImage.size.height * finalScale);
    UIImage *newImage =[originalImage imageCroppedToFitSize:newSize];
    return newImage;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedData = [tableData objectAtIndex:indexPath.row];
    NewPostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Post"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) toNewPostPage
{
    if(APPDELEGATE.postFeed){
        NSDate *lastMessageTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastMessageCreatedTime"];
        _timeSinceLastMessage = -1 * [lastMessageTime timeIntervalSinceNow];
        if (_timeSinceLastMessage < APPDELEGATE.postingFeedTimerOffset && lastMessageTime != nil){
            int waitingTime = (APPDELEGATE.postingFeedTimerOffset - _timeSinceLastMessage)/60 + 1;
            NSString *message = [NSString stringWithFormat:@"Please wait for %d min", waitingTime];
            UIAlertView *newMessageAlert = [[UIAlertView alloc] initWithTitle:@"You just create a message"
                                                                      message:message
                                                                     delegate:self
                                                            cancelButtonTitle:@"Okay"
                                                            otherButtonTitles:nil];
            [newMessageAlert show];
        } else {
            NewPostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NewPost"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [self showAlertBox:APPDELEGATE.postFeedAlertTitle
                   message:APPDELEGATE.postFeedAlertMessage
                    button:@"OK"];
    }
}

- (void) tagSearchAlert{
    _popupType = @"TAGSEARCH";
    UITextField *messageField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
//    messageField.placeholder = @"Search for a hashtag";
//    [messageField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@""]];
    UIAlertView *newSearchAlert = [[UIAlertView alloc] initWithTitle:@"Hashtag Search"
                                                              message:@"Search for posts with specific hashtag"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Search", nil];
    [newSearchAlert addSubview:messageField];
    newSearchAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newSearchAlert show];
    
}

- (void) updateListWithTag:(NSString *)tagString{
    NSMutableArray *tagPosts = (NSMutableArray *)[hashTagDictionary objectForKey:tagString];
    if(tagPosts != nil){
        tableData = tagPosts;
        [self showAllPostIcon];
        [self.tableView reloadData];
    } else {
        [self showAlertBox:APPDELEGATE.noTaggedFeedAlertTitle
                   message:APPDELEGATE.noTaggedFeedAlertMessage
                    button:@"OK"];
    }
}

- (void) emptyPostAlert{
    _popupType = @"NEWPOST";
    UIAlertView *newPostAlert = [[UIAlertView alloc] initWithTitle:APPDELEGATE.firstPostAlertTitle
                                                              message:APPDELEGATE.firstPostAlertMessage
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"New Post", nil];
    [newPostAlert show];
}

- (void) showAllPostIcon{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    UIBarButtonItem * item2= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(displayAllPosts)];
        self.navigationItem.leftBarButtonItems =[NSArray arrayWithObjects:negativeSpacer, item2, nil];
}

- (void) displayAllPosts{
    tableData = messageList;
    [self.tableView reloadData];
    [self customNavBar];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        CGPoint point = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        
        PostTableViewCell *cell = (PostTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:cell.frame inView:cell.superview];
        [menu setMenuVisible:YES animated:YES];
        [cell becomeFirstResponder]; //here set the cell as the responder of the menu action
    }
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    return (action == NSSelectorFromString(@"report:"));
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == NSSelectorFromString(@"report:"));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if(action == NSSelectorFromString(@"report:")){
        _popupType = @"REPORT";
        _reportPostId = [[tableData objectAtIndex:indexPath.row] objectForKey:@"postId"];
        NSString *displayMsg = [[tableData objectAtIndex:indexPath.row] objectForKey:@"content"];
        UITextField *reasonTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 245.0, 25.0)];
        UIAlertView *reportAlert = [[UIAlertView alloc] initWithTitle:@"Report This Post:"
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
    if([_popupType isEqualToString:@"REPORT"]){
        UITextField *reasonTextField = [alertView textFieldAtIndex:0];
        [reasonTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Reason"]];
        reasonTextField.delegate = self;
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
                [APPDELEGATE.mainVC requestReportViolationOf:@"POST" withId:_reportPostId andReason:reportReason];
                [self showAlertBox:@"Report Succeed"
                           message:@"This post is going under our inspection list. It will be removed shortly if it violates our terms"
                            button:@"OK"];
            }
        } else if([_popupType isEqualToString:@"TAGSEARCH"]){
            NSString *searchedTag = ((UITextField *)[alertView textFieldAtIndex:0]).text;
            [self updateListWithTag:searchedTag];
        } else if([_popupType isEqualToString:@"NEWPOST"]){
            [self toNewPostPage];

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
