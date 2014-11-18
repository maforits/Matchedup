//
//  MVChatViewController.m
//  Matchedup
//
//  Created by Maforo on 14-11-14.
//
//

#import "MVChatViewController.h"

@interface MVChatViewController ()
@property (strong, nonatomic) PFUser *withUser;

@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSTimer *chatsTimer;

@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;
@end

@implementation MVChatViewController

-(NSMutableArray *)chats

{
    
    if (!_chats){
        
        _chats = [[NSMutableArray alloc] init];
        
    }
    
    return _chats;
    
}

- (void)viewDidLoad {
    self.delegate = self;
    self.dataSource = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[JSBubbleView appearance] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    
    self.messageInputView.textView.placeHolder = @"New Message";
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser = [PFUser currentUser];
    
    PFUser *testUser1 = self.chatRoom[kCCChatRoomUser1Key];
    
    if ([testUser1.objectId isEqual:self.currentUser.objectId]){
        
        self.withUser = self.chatRoom[kCCChatRoomUser2Key];
        
    }
    
    else {
        
        self.withUser = self.chatRoom[kCCChatRoomUser1Key];
        
    }
    
    self.title = self.withUser[kCCUserProfileKey][kCCUserProfileFirstNameKey];
    
    self.initialLoadComplete = NO;
    
    [self checkForNewChats];
    
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated

{
    
    [self.chatsTimer invalidate];
    
    self.chatsTimer = nil;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    
    return [self.chats count];
    
}

#pragma mark - Table view delegate REQUIRED

- (void)didSendText:(NSString *)text

{
    
    if (text.length != 0) {
        
        PFObject *chat = [PFObject objectWithClassName:kCCChatClassKey];
        
        [chat setObject:self.chatRoom forKey:kCCChatChatroomKey];
        
        [chat setObject:[PFUser currentUser] forKey:kCCChatFromUserKey];
        
        [chat setObject:self.withUser forKey:kCCChatToUserKey];
        
        [chat setObject:text forKey:kCCChatTextKey];
        
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            NSLog(@"save complete");
            
            [self.chats addObject:chat];
            
            [JSMessageSoundEffect playMessageSentSound];
            
            [self.tableView reloadData];
            
            [self finishSend];
            
            [self scrollToBottomAnimated:YES];
            
        }];
        
    }
    
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    /* If we are doing the sending return JSBubbleMessageTypeOutgoing
     
     else JSBubbleMessageTypeIncoming
     
     */
    
    PFObject *chat = self.chats[indexPath.row];
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFUser *testFromUser = chat[kCCChatFromUserKey];
    
    if ([testFromUser.objectId isEqual:currentUser.objectId])
        
    {
        
        return JSBubbleMessageTypeOutgoing;
        
        ;
        
    }
    
    else{
        
        return JSBubbleMessageTypeIncoming;
        
    }
    
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type

                       forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    PFObject *chat = self.chats[indexPath.row];
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFUser *testFromUser = chat[kCCChatFromUserKey];
    
    if ([testFromUser.objectId isEqual:currentUser.objectId])
        
    {
        
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                
                                                          color:[UIColor js_bubbleGreenColor]];
        
    }
    
    else{
        
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                
                                                          color:[UIColor js_bubbleLightGrayColor]];
        
    }
}

- (JSMessagesViewTimestampPolicy)timestampPolicy

{
    
    return JSMessagesViewTimestampPolicyAll
    
    ;
    
}

- (JSMessagesViewAvatarPolicy)avatarPolicy

{
    
    /* JSMessagesViewAvatarPolicyNone */
    
    return JSMessagesViewAvatarPolicyAll;
    
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy

{
    
    return JSMessagesViewSubtitlePolicyAll;
    
}

- (JSMessageInputViewStyle)inputViewStyle

{
    
    /* change style */
    
    return JSMessageInputViewStyleFlat;
    
}

#pragma mark - Messages View Delegate OPTIONAL

- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath

{
    
    if([cell messageType] == JSBubbleMessageTypeOutgoing) {
        
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
    }
    
}


- (BOOL)shouldPreventScrollToBottomWhileUserScrolling

{
    
    return YES;
    
}

#pragma mark - Messages view data source: REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    PFObject *chat = self.chats[indexPath.row];
    
    NSString *message = chat[kCCChatTextKey];
    
    return message;
    
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return nil;
    
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return nil;
    
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return nil;
    
}

#pragma mark - Helper Methods

-(void) checkForNewChats

{
    
    int oldChatCount = [self.chats count];
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:kCCChatClassKey];
    
    [queryForChats whereKey:kCCChatChatroomKey equalTo:self.chatRoom];
    
    [queryForChats orderByAscending:@"createdAt"];
    
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            if (self.initialLoadComplete == NO || oldChatCount != [objects count]){
                
                self.chats = [objects mutableCopy];
                
                if (self.initialLoadComplete == YES){
                    
                    [JSMessageSoundEffect playMessageReceivedSound];
                    
                }
                
                [self.tableView reloadData];
                
                self.initialLoadComplete = YES;
                
                [JSMessageSoundEffect playMessageReceivedSound];
                
                [self scrollToBottomAnimated:YES];
                
            }
            
        }
        
    }];
    
}

@end
