//
//  MVHomeViewController.m
//  Matchedup
//
//  Created by Maforo on 13-11-14.
//
//

#import "MVHomeViewController.h"
#import "MVTestUser.h"
#import "MVProfileViewController.h"
#import "MVMatchViewController.h"

@interface MVHomeViewController () <MVMatchViewControllerDelegate,MVProfileViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;

@end

@implementation MVHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [MVTestUser saveTestUserToParse];
    [self setupViews];
}

-(void)viewDidAppear:(BOOL)animated
{
    //Initializing the variables
    self.photoImageView.image = nil;
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
    self.likeButton.enabled = NO;
    
    self.dislikeButton.enabled = NO;
    
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    
    [query whereKey:kCCPhotoUserKey notEqualTo:[PFUser currentUser]];
    
    [query includeKey:kCCPhotoUserKey];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            
            if ([self allowPhoto] == NO) {
                [self setupNextPhoto];
            }else{
                [self queryForCurrentPhotoIndex];
            }
        }else{
            NSLog(@"%@",error);
        }
    }];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}

-(void)addShadowForView:(UIView *)view
{
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 4;
    view.layer.shadowRadius = 1;
    view.layer.shadowOffset = CGSizeMake(0,1);
    view.layer.shadowOpacity = 0.25;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"])
        
    {
        
        MVProfileViewController *profileVC = segue.destinationViewController;
        
        profileVC.photo = self.photo;
        profileVC.delegate = self;
        
    }else if ([segue.identifier isEqualToString:@"homeToMatchSegue"])
        
    {
        
        MVMatchViewController *matchVC = segue.destinationViewController;
        
        matchVC.matchedUserImage = self.photoImageView.image;
        
        matchVC.delegate = self;
        
    }
}


#pragma mark - IBActions
- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self checkDislike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}
- (IBAction)chatButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
}

#pragma mark - Helper Methods
- (void)queryForCurrentPhotoIndex

{
    
    if ([self.photos count] > 0) {
        
        self.photo = self.photos[self.currentPhotoIndex];
        
        PFFile *file = self.photo[kCCPhotoPictureKey];
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                
                self.photoImageView.image = image;
                [self updateView];
            }else{
                NSLog(@"%@",error);
            }
        }];
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:kCCActivityClassKey];
        
        [queryForLike whereKey:kCCActivityTypeKey equalTo:kCCActivityTypeLikeKey];
        
        [queryForLike whereKey:kCCActivityPhotoKey equalTo:self.photo];
        
        [queryForLike whereKey:kCCActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kCCActivityClassKey];
        
        [queryForDislike whereKey:kCCActivityTypeKey equalTo:kCCActivityTypeDislikeKey];
        
        [queryForDislike whereKey:kCCActivityPhotoKey equalTo:self.photo];
        
        [queryForDislike whereKey:kCCActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error){
                
                self.activities = [objects mutableCopy];
                
                if ([self.activities count] == 0) {
                    
                    self.isLikedByCurrentUser = NO;
                    
                    self.isDislikedByCurrentUser = NO;
                    
                } else {
                    
                    PFObject *activity = self.activities[0];
                    
                    if ([activity[kCCActivityTypeKey] isEqualToString:kCCActivityTypeLikeKey]){
                        
                        self.isLikedByCurrentUser = YES;
                        
                        self.isDislikedByCurrentUser = NO;
                        
                    }
                    
                    else if ([activity[kCCActivityTypeKey] isEqualToString:kCCActivityTypeDislikeKey]){
                        
                        self.isLikedByCurrentUser = NO;
                        
                        self.isDislikedByCurrentUser = YES;
                        
                    }
                    
                    else {
                        
                        //Some other type of activity
                        
                    }
                    
                }
                
                self.likeButton.enabled = YES;
                
                self.dislikeButton.enabled = YES;
                
                self.infoButton.enabled = YES;
            }
            
        }];
        
    }
}

- (void)updateView

{
    
    self.firstNameLabel.text = self.photo[kCCPhotoUserKey][kCCUserProfileKey][kCCUserProfileFirstNameKey];
    
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kCCPhotoUserKey][kCCUserProfileKey][kCCUserProfileAgeKey]];    
}

-(void)setupNextPhoto

{
    
    if (self.currentPhotoIndex + 1 <self.photos.count)
        
    {
        
        self.currentPhotoIndex ++;
        
        if ([self allowPhoto] == NO) {
            [self setupNextPhoto];
        }else{
            [self queryForCurrentPhotoIndex];
        }
    }
    
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users to View" message:@"Check Back Later for more People!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [alert show];
        
    }
    
}


-(BOOL)allowPhoto
{
    int maxAge = [[NSUserDefaults standardUserDefaults] integerForKey:kCCAgeMaxKey];
    BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kCCMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kCCWomenEnabledKey];
    BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kCCSingleEnabledKey];
    
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kCCPhotoUserKey];
    
    int userAge = [user[kCCUserProfileKey][kCCUserProfileAgeKey] intValue];
    NSString *gender = user[kCCUserProfileKey][kCCUserProfileGenderKey];
    NSString *relationshipStatus = user[kCCUserProfileKey][kCCUserProfileRelationshipStatusKey];
    
    if (userAge > maxAge) {
        return NO;
    }else if (men == NO && [gender isEqualToString:@"male"]){
        return NO;
    }else if (women == NO && [gender isEqualToString:@"female"]){
        return NO;
    }else if (single == NO && ([relationshipStatus isEqualToString:@"single"] || relationshipStatus == nil)){
        return NO;
    }else
        return YES;
}

- (void)saveLike {
    
    PFObject *likeActivity = [PFObject objectWithClassName:kCCActivityClassKey];
    
    [likeActivity setObject:kCCActivityTypeLikeKey forKey:kCCActivityTypeKey];
    
    [likeActivity setObject:[PFUser currentUser] forKey:kCCActivityFromUserKey];
    
    [likeActivity setObject:[self.photo objectForKey:kCCPhotoUserKey] forKey:kCCActivityToUserKey];
    
    [likeActivity setObject:self.photo forKey:kCCActivityPhotoKey];
    
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     
    {
        
        self.isLikedByCurrentUser = YES;
        
        self.isDislikedByCurrentUser = NO;
        
        [self.activities addObject: likeActivity];
        
        [self checkForPhotoUserLikes];
        
        [self setupNextPhoto];
        
    }];
    
}

- (void)saveDislike

{
    
    PFObject *dislikeActivity = [PFObject objectWithClassName:kCCActivityClassKey];
    
    [dislikeActivity setObject:kCCActivityTypeDislikeKey forKey:kCCActivityTypeKey];
    
    [dislikeActivity setObject:[PFUser currentUser] forKey:kCCActivityFromUserKey];
    
    [dislikeActivity setObject:[self.photo objectForKey:kCCPhotoUserKey] forKey:kCCActivityToUserKey];
    
    [dislikeActivity setObject:self.photo forKey:kCCActivityPhotoKey];
    
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        self.isLikedByCurrentUser = NO;
        
        self.isDislikedByCurrentUser = YES;
        
        [self.activities addObject: dislikeActivity];
        
        [self setupNextPhoto];
        
    }];
    
}

- (void)checkLike

{
    
    if (self.isLikedByCurrentUser){
        
        [self setupNextPhoto];
        
        return;
        
    }
    
    else if (self.isDislikedByCurrentUser){
        
        for (PFObject *activity in self.activities) {
            
            [activity deleteInBackground];
            
        }
        
        [self.activities removeLastObject];
        
        [self saveLike];
        
    }
    
    else [self saveLike];
    
}

- (void)checkDislike

{
    
    if (self.isDislikedByCurrentUser){
        
        [self setupNextPhoto];
        
        return;
        
    }
    
    else if (self.isLikedByCurrentUser){
        
        for (PFObject *activity in self.activities) {
            
            [activity deleteInBackground];
            
        }
        
        [self.activities removeLastObject];
        
        [self saveDislike];
        
    }
    
}

- (void)checkForPhotoUserLikes

{
    
    PFQuery *query = [PFQuery queryWithClassName:kCCActivityClassKey];
    
    [query whereKey:kCCActivityFromUserKey equalTo:self.photo[kCCPhotoUserKey]];
    
    [query whereKey:kCCActivityToUserKey equalTo:[PFUser currentUser]];
    
    [query whereKey:kCCActivityTypeKey equalTo:kCCActivityTypeLikeKey];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if ([objects count] > 0){
            
            [self createChatRoom];
            
        }
        
    }];
    
}

- (void)createChatRoom

{
    
    NSLog(@"create called");
    
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kCCChatRoomClassKey];
    
    [queryForChatRoom whereKey:kCCChatRoomUser1Key equalTo:[PFUser currentUser]];
    
    [queryForChatRoom whereKey:kCCChatRoomUser2Key equalTo:self.photo[kCCPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:kCCChatRoomClassKey];
    
    [queryForChatRoomInverse whereKey:kCCChatRoomUser1Key equalTo:self.photo[kCCPhotoUserKey]];
    
    [queryForChatRoomInverse whereKey:kCCChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if ([objects count] == 0) {
            
            PFObject *chatroom = [PFObject objectWithClassName:kCCChatRoomClassKey];
            
            [chatroom setObject:[PFUser currentUser] forKey:kCCChatRoomUser1Key];
            
            [chatroom setObject:self.photo[kCCPhotoUserKey] forKey:kCCChatRoomUser2Key];
            
            [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
                
            }];
            
        }
        
    }];
    
}

#pragma mark - MVMatchViewController Delegate

-(void)presentMatchesViewController

{
    
    [self dismissViewControllerAnimated:NO completion:^{
        
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
        
    }];
    
}

#pragma mark - MVProfileViewController Delegate
-(void)didPressLike

{
    
    [self.navigationController popViewControllerAnimated:NO];
    
    [self checkLike];
    
}

-(void)didPressDislike

{
    
    [self.navigationController popViewControllerAnimated:NO];
    
    [self checkDislike];
    
}
@end
