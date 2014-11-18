//
//  MVChatViewController.h
//  Matchedup
//
//  Created by Maforo on 14-11-14.
//
//

#import "JSMessagesViewController.h"

@interface MVChatViewController : JSMessagesViewController <JSMessagesViewDataSource,JSMessagesViewDelegate>

@property (strong,nonatomic) PFObject *chatRoom;
@end
