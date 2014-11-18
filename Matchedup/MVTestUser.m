//
//  MVTestUser.m
//  Matchedup
//
//  Created by Maforo on 14-11-14.
//
//

#import "MVTestUser.h"

@implementation MVTestUser
+(void)saveTestUserToParse

{
    
    PFUser *newUser = [PFUser user];
    
    newUser.username = @"user1";
    
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSLog(@"sign up %@", error);
        
        NSDictionary *profile = @{@"age" : @28, @"birthday" : @"11/22/1985", @"firstName" : @"Julie", @"gender" : @"female", @"location" : @"Berlin, Germany", @"name" : @"Julie Adams"};
        
        [newUser setObject:profile forKey:@"profile"];
        
        [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            UIImage *profileImage = [UIImage imageNamed:@"Cheetah_portrait_Whipsnade_Zoo.png"];
            
            NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
            
            PFFile *photoFile = [PFFile fileWithData:imageData];
            
            [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded){
                    
                    PFObject *photo = [PFObject objectWithClassName:kCCPhotoClassKey];
                    
                    [photo setObject:newUser forKey:kCCPhotoUserKey];
                    
                    [photo setObject:photoFile forKey:kCCPhotoPictureKey];
                    
                    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        NSLog(@"Photo saved successfully");
                        
                    }];
                    
                }
                
            }];
            
        }];
        
    }];
    
}
@end
