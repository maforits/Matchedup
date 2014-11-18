//
//  MVMatchViewController.h
//  Matchedup
//
//  Created by Maforo on 14-11-14.
//
//

#import <UIKit/UIKit.h>
@protocol MVMatchViewControllerDelegate <NSObject>

-(void)presentMatchesViewController;

@end

@interface MVMatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;

@property (weak, nonatomic) id <MVMatchViewControllerDelegate> delegate;
@end
