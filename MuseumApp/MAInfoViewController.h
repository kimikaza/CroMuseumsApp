//
//  MAInfoViewController.h
//  MuseumApp
//
//  Created by Zoran Plesko on 1/5/13.
//  Copyright (c) 2013 Zoran Plesko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAStringTranslator.h"
#import "Reachability.h"

@protocol MAInfoViewControllerDelegate <NSObject>
@required
-(void)dismissModalView:(id)sender;
@end

@interface MAInfoViewController : UIViewController{
    IBOutlet UIImageView *upute;
    IBOutlet UIImageView *ikone;
    IBOutlet UIImageView *praznici;
    IBOutlet UIImageView *jezik;
    IBOutlet UIButton *masinerijaButton;
    IBOutlet UIButton *facebookButton;

}

@property (nonatomic, retain) id<MAInfoViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIImageView *background;
@property (nonatomic, retain) IBOutlet UIScrollView *uisv;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet MAStringTranslator *st;

-(void)tapped:(id)sender;
-(IBAction)changePage:(id)sender;
-(IBAction)gotoFacebook:(id)sender;
-(IBAction)gotoMasinerija:(id)sender;
-(BOOL)checkReachability:(NSString *)url;
-(BOOL)reachable:(NSString *)url;
@end
