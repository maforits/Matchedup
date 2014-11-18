//
//  MVConstants.h
//  Matchedup
//
//  Created by Maforo on 13-11-14.
//
//

#import <Foundation/Foundation.h>

@interface MVConstants : NSObject

#pragma - mark User
extern NSString *const kCCUserProfileKey;

extern NSString *const kCCUserProfileNameKey;

extern NSString *const kCCUserProfileFirstNameKey;

extern NSString *const kCCUserProfileLocationKey;

extern NSString *const kCCUserProfileGenderKey;

extern NSString *const kCCUserProfileBirthdayKey;

extern NSString *const kCCUserProfileInterestedInKey;

extern NSString *const kCCUserProfilePictureURL;

extern NSString *const kCCUserProfileRelationshipStatusKey;

extern NSString *const kCCUserProfileAgeKey;

extern NSString *const kCCUserTagLineKey;

#pragma mark - Photo Class

extern NSString *const kCCPhotoClassKey;

extern NSString *const kCCPhotoUserKey;

extern NSString *const kCCPhotoPictureKey;

#pragma - mark Activity

extern NSString *const kCCActivityClassKey;

extern NSString *const kCCActivityTypeKey;

extern NSString *const kCCActivityFromUserKey;

extern NSString *const kCCActivityToUserKey;

extern NSString *const kCCActivityPhotoKey;

extern NSString *const kCCActivityTypeLikeKey;

extern NSString *const kCCActivityTypeDislikeKey;

#pragma mark - Settings

extern NSString *const kCCMenEnabledKey;

extern NSString *const kCCWomenEnabledKey;

extern NSString *const kCCSingleEnabledKey;

extern NSString *const kCCAgeMaxKey;

#pragma mark - ChatRoom

extern NSString *const kCCChatRoomClassKey;

extern NSString *const kCCChatRoomUser1Key;

extern NSString *const kCCChatRoomUser2Key;

#pragma mark - Chat

extern NSString *const kCCChatClassKey;

extern NSString *const kCCChatChatroomKey;

extern NSString *const kCCChatFromUserKey;

extern NSString *const kCCChatToUserKey;

extern NSString *const kCCChatTextKey;
@end
