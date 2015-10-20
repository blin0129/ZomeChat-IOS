//
//  PostViewController.m
//  ZomeChat
//
//  Created by Brian Lin on 11/24/14.
//  Copyright (c) 2014 Zome. All rights reserved.
//

#import "PostViewController.h"
#import "UIImage+ProportionalFill.h"
#import "DetailPostTableViewCell.h"
#import "CommentTableViewCell.h"

@implementation PostViewController{
    float yBound;
    UITableViewCell *cellForRowHeightCalculation;
    NSDateFormatter *dateFormat;
    UIBarButtonItem *likeBtn;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        APPDELEGATE.postVC = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [self customNavBar];
    self.postData = [APPDELEGATE.msglistVC selectedData];
    self.postId = [self.postData objectForKey:@"postId"];
    [APPDELEGATE.mainVC requestFeedDetail:self.postId];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = .5;
    longPressGesture.delegate = self;
    [self.view addGestureRecognizer:longPressGesture];
}

- (void) initView
{
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-babyblue"]]];
    self.comments = [[NSMutableArray alloc] init];
    yBound = self.replyContainer.frame.origin.y;
    
    self.commentTable.delegate = self;
    self.commentTable.dataSource = self;
    self.commentTable.backgroundColor = [UIColor clearColor];
    self.commentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.commentTable setAllowsSelection:NO];
    [self.commentTable registerNib:[UINib nibWithNibName:@"DetailPostCell" bundle:nil] forCellReuseIdentifier:@"DetailPostCell"];
    [self.commentTable registerNib:[UINib nibWithNibName:@"CommentCell" bundle:nil] forCellReuseIdentifier:@"CommentCell"];
    [self.replyTextField addTarget:self
                  action:@selector(editingChanged:)
        forControlEvents:UIControlEventEditingChanged];
    self.replyBtn.enabled = NO;

    self.replyContainer.layer.shadowOffset = CGSizeMake(-1, -1);
    self.replyContainer.layer.shadowRadius = 2;
    self.replyContainer.layer.shadowOpacity = 0.3;
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
    
    
}

-(void)tap:(UITapGestureRecognizer *)tapRec{
    [[self view] endEditing: YES];
}

-(void) editingChanged:(id)sender {
    if (self.replyTextField.text.length == 0) {
        self.replyBtn.enabled = NO;
    } else {
        self.replyBtn.enabled = YES;
    }
}



- (void)customNavBar
{
    self.navigationItem.title = @"Feed";
    likeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_icon_like"] style:UIBarButtonItemStylePlain target:self action:@selector(likeThePost)];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
  
    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:negativeSpacer, likeBtn, nil];
}

- (void) receiveFeedDetail:(NSDictionary *)data
{
    self.comments = [[data objectForKey:@"comments"] copy];
    self.likes = [[data objectForKey:@"likes"] copy];
    [self.commentTable reloadData];
    [APPDELEGATE.msglistVC updateFeedStatus:[data objectForKey:@"id"]
                                  likeCount:[NSNumber numberWithInteger:self.likes.count]
                               commentCount:[NSNumber numberWithInteger:self.comments.count]];
    if ([self.likes containsObject:APPDELEGATE.uid]) {
        [likeBtn setImage:[UIImage imageNamed:@"bar_icon_like_filled"]];
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

- (IBAction)replayBtnClicked:(id)sender {
    if(APPDELEGATE.commentPost){
        NSString *comment = self.replyTextField.text;
        [APPDELEGATE.mainVC requestPostComment:comment onFeed:self.postId];
        self.replyTextField.text = @"";
    }else{
        [self showAlertBox:APPDELEGATE.commentPostAlertTitle
                   message:APPDELEGATE.commentPostAlertMessage
                    button:@"OK"];
    }
    [[self view] endEditing: YES];
}

- (void)likeThePost
{
    if (APPDELEGATE.likePost) {
        BOOL likedBefore = false;
        if (self.likes) {
            for (NSString *userliked in self.likes){
                if ([userliked isEqualToString:APPDELEGATE.uid] ) {
                    [self showAlertBox:APPDELEGATE.postDoubleLikedAlertTitle
                               message:APPDELEGATE.postDoubleLikedAlertMessage
                                button:@"OK"];
                    likedBefore = true;
                    break;
                }
            }
            if (!likedBefore) {
                [APPDELEGATE.mainVC requestLikeFeed:self.postId];
                [likeBtn setImage:[UIImage imageNamed:@"bar_icon_like_filled"]];
            }
        }
    } else {
        [self showAlertBox:APPDELEGATE.likePostAlertTitle
                   message:APPDELEGATE.likePostAlertMessage
                    button:@"OK"];
    }
}

- (UIImage *) getImageFromURL: (NSString *) imageURL{
    if (imageURL == nil || [imageURL isEqualToString:@""]) {
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


- (UIImage *) resizeImage:(UIImage *)originalImage
{
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

- (UIImage *) resizeImageToThumbnail:(UIImage *)originalImage size:(float) width
{
    CGSize newSize = CGSizeMake(width,width);
    UIImage *newImage =[originalImage imageCroppedToFitSize:newSize];
    return newImage;
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

- (void)keyboardWillHide:(NSNotification *)n
{
    CGSize keyboardSize = [[[n userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // resize the scrollview
    CGRect viewFrame = self.replyContainer.frame;
    viewFrame.origin.y += (keyboardSize.height - self.tabBarController.tabBar.frame.size.height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.replyContainer setFrame:viewFrame];
    [UIView commitAnimations];
    self.replyContainer.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    // get the size of the keyboard
    CGSize keyboardSize = [[[n userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // resize the noteView
    CGRect viewFrame = self.replyContainer.frame;
    viewFrame.origin.y -= (keyboardSize.height - self.tabBarController.tabBar.frame.size.height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.replyContainer setFrame:viewFrame];
    [UIView commitAnimations];
    self.replyContainer.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    if (self.replyTextField.text.length == 0) {
        self.replyBtn.enabled = NO;
    } else {
        self.replyBtn.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.comments count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check the cache first if enabled
#if PERFORMANCE_ENABLE_HEIGHT_CACHE
    NSNumber *cachedHeight = self.rowHeightCache[content.uniqueIdentifier];
    if (cachedHeight != nil) {
        return [cachedHeight floatValue];
    }
#endif
    NSDictionary *data;
    float imageHeight = 0;
    float cellHeight = 0;
    if(indexPath.row == 0){
        data = self.postData;
        cellHeight = 108;
        NSString *imageURL = [self.postData objectForKey:@"imageURL"];
        if (![imageURL isEqualToString:@""]){
            UIImage *image;
            image = [self getImageFromURL:imageURL];
            if(image){
                imageHeight = image.size.height + 5;
            }
        }
    } else {
        cellHeight = 77;
        data = [self.comments objectAtIndex:(indexPath.row-1)];
    }
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[data objectForKey:@"content"] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:13.0]}];
    float viewWidth = tableView.frame.size.width - 40;
    CGRect theSize = [content boundingRectWithSize:CGSizeMake(viewWidth, CGFLOAT_MAX)
                                           options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                           context:nil];
    cellHeight += theSize.size.height + imageHeight;
    
#if PERFORMANCE_ENABLE_HEIGHT_CACHE
    self.rowHeightCache[message.uniqueIdentifier] = @(cellHeight);
#endif
    return cellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
     if (indexPath.row == 0) {
         cellIdentifier = @"DetailPostCell";
         DetailPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell){
            cell = [[DetailPostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setUserInteractionEnabled:NO];
        }
        cell.usernameLabel.text = [self.postData objectForKey:@"ownerName"];
         double time =([[self.postData objectForKey:@"time"] doubleValue]/1000);
         NSString * timeString = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
         cell.timeLabel.text = timeString;
         cell.postContent.text = [self.postData objectForKey:@"content"];
         [cell.postContent sizeToFit];
         [self hashtagColor:cell.postContent];
         
         NSString *thumbnailURL =[self.postData objectForKey:@"ownerImageURL"];
         if(![thumbnailURL isEqual:[NSNull null]] && thumbnailURL != nil){
             if(![thumbnailURL isEqualToString:@""]){
                 UIImage *thumbnail = [self resizeImageToThumbnail:[self getImageFromURL:thumbnailURL] size:70.0f];
                 cell.posterImage.image = thumbnail;
             }
         }
         
         NSString *imageURL = [self.postData objectForKey:@"imageURL"];
         if(![imageURL isEqual:[NSNull null]] && imageURL != nil){
             if(![imageURL isEqualToString:@""]){
                 UIImage *img = [self getImageFromURL:imageURL];
                 cell.posterImage.frame = CGRectMake(cell.postImage.frame.origin.x, cell.posterImage.frame.origin.y, img.size.width, img.size.height);
                 cell.postImage.image = img;
             }
         }
         return cell;
     } else {
         cellIdentifier = @"CommentCell";
         CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
         if (cell == nil){
            cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
             cell.delegate = self;
             cell.backgroundColor = [UIColor clearColor];
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
             [cell setUserInteractionEnabled:NO];
         }
         NSDictionary *commentData = [self.comments objectAtIndex:(indexPath.row-1)];
         cell.usernameLabel.text = [commentData objectForKey:@"ownerName"];
         double time =([[commentData objectForKey:@"time"] doubleValue]/1000);
         NSString * timeString = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
         cell.timeLabel.text = timeString;
         cell.contentTextview.text = [commentData objectForKey:@"content"];
//         [cell.contentTextview sizeToFit];
         
         NSString *thumbnailURL = [commentData objectForKey:@"ownerImageURL"];
         if(thumbnailURL !=(id)[NSNull null] && thumbnailURL != nil){
             if(![thumbnailURL isEqualToString:@""]){
                 NSLog(@"Setting commenter image url %@",thumbnailURL);
                 UIImage *thumbnail =[self resizeImageToThumbnail:[self getImageFromURL:thumbnailURL] size:40.0f];
                 cell.userImage.image = thumbnail;
             }
         }
         return cell;
     }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        CGPoint point = [gestureRecognizer locationInView:self.commentTable];
        NSIndexPath * indexPath = [self.commentTable indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        
        CommentTableViewCell *cell = (CommentTableViewCell *)[self.commentTable cellForRowAtIndexPath:indexPath];
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
        _reportCommentId = [[self.comments objectAtIndex:(indexPath.row-1)] objectForKey:@"commentId"];
        NSString *displayMsg = [[self.comments objectAtIndex:(indexPath.row-1)] objectForKey:@"content"];
        UITextField *reasonTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 245.0, 25.0)];
        UIAlertView *reportAlert = [[UIAlertView alloc] initWithTitle:@"Report This Comment:"
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
//        reasonTextField.delegate = self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.cancelButtonIndex != buttonIndex){
        NSString *reportReason = ((UITextField *)[alertView textFieldAtIndex:0]).text;
        if([reportReason isEqual:@""]){
            [self showAlertBox:@"Report Fail"
                       message:@"Please enter report reason"
                        button:@"OK"];
        } else {
            [APPDELEGATE.mainVC requestReportViolationOf:@"COMMENT" withId:_reportCommentId andReason:reportReason];
            [self showAlertBox:@"Report Succeed"
                       message:@"This comment is going under our inspection list. It will be removed shortly if it violates our terms"
                        button:@"OK"];
        }
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    textView.tintColor = IOS_BLUE;
}

@end
