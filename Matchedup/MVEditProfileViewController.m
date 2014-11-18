//
//  MVEditProfileViewController.m
//  Matchedup
//
//  Created by Maforo on 13-11-14.
//
//

#import "MVEditProfileViewController.h"

@interface MVEditProfileViewController () <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UITextView *tagLineTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;

@end

@implementation MVEditProfileViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    self.tagLineTextView.delegate = self;
    // Do any additional setup after loading the view.
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if ([objects count] > 0){
            
            PFObject *photo = objects[0];
            
            PFFile *pictureFile = photo[kCCPhotoPictureKey];
            
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                self.profilePictureImageView.image = [UIImage imageWithData:data];
                
            }];
            
        }
        
    }];
    
    self.tagLineTextView.text = [[PFUser currentUser] objectForKey:kCCUserTagLineKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TextView Delegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.tagLineTextView resignFirstResponder];
        [[PFUser currentUser] setObject:self.tagLineTextView.text forKey:kCCUserTagLineKey];
        
        [[PFUser currentUser] saveInBackground];
        
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }else
        return YES;
}
@end
