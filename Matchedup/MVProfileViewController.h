//
//  MVProfileViewController.h
//  Matchedup
//
//  Created by Maforo on 13-11-14.
//
//

#import <UIKit/UIKit.h>

@protocol MVProfileViewControllerDelegate <NSObject>

-(void)didPressLike;
-(void)didPressDislike;

@end

@interface MVProfileViewController : UIViewController

@property (strong,nonatomic) PFObject *photo;
@property (weak,nonatomic) id <MVProfileViewControllerDelegate> delegate;

@end
