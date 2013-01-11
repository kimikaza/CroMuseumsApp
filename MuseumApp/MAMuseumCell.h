//
//  MAMuseumCell.h
//  MuseumApp
//
//  Created by Zoran Plesko on 12/16/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MACommentLoader.h"
#import "MAStringTranslator.h"

@interface MAMuseumCell : UITableViewCell<UIScrollViewDelegate, MACommentLoaderDelegate>
{
    IBOutlet UIButton *museumButton;
    IBOutlet UIButton *hourButton;
    IBOutlet UIButton *ticketButton;
    IBOutlet UIButton *infoButton;
    IBOutlet UIButton *commentButton;
    IBOutlet UIButton *invisibleAddComment;
    IBOutlet UIScrollView *myScrollView;
    IBOutlet UIButton *srcheko;
    IBOutlet UITextView *about;
    IBOutlet UIWebView *workingHours;
    IBOutlet UIWebView *tickets;
    IBOutlet UIWebView *info;
    IBOutlet UIWebView *comments;
    NSString *htmlComments;
    MACommentLoader *cl;
    IBOutlet UIImageView *accessView;
    IBOutlet UIImageView *shopView;
    IBOutlet UIImageView *caffeView;
    IBOutlet UIButton *wwwView;
    IBOutlet UIButton *emailView;
    IBOutlet UIButton *gpsView;
    IBOutlet UIButton *phoneView;
    UIView *crta;
    IBOutlet UIImageView *audioView;
    BOOL crveno;
    NSMutableArray *stars;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *firstView;
@property (nonatomic, retain) IBOutlet UIView *secondView;
@property (nonatomic, retain) IBOutlet UIScrollView *myScrollView;
@property (nonatomic, retain) IBOutlet UIView *myScrollContainerView;
@property (nonatomic, retain) IBOutlet UILabel *textich;
@property (nonatomic, retain) IBOutlet UITextView *about;
@property (nonatomic, retain) IBOutlet UIWebView *workingHours;
@property (nonatomic, retain) IBOutlet UIWebView *tickets;
@property (nonatomic, retain) IBOutlet UIWebView *info;
@property (nonatomic, retain) IBOutlet UIWebView *comments;
@property (nonatomic, retain) NSString *access;
@property (nonatomic, retain) NSString *shop;
@property (nonatomic, retain) NSString *caffe;
@property (nonatomic, retain) NSString *www;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *gps;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *audio;
@property (nonatomic, retain) IBOutlet UILabel *distance;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) NSDecimalNumber *avg_rating;
@property (nonatomic, retain) NSString *server_id;
@property (nonatomic, retain) MAStringTranslator *st;




-(void) flipCell;
-(void) closeCell;
-(IBAction) museumTabPressed:(id)sender;
-(IBAction) workingHoursTabPressed:(id)sender;
-(IBAction) ticketsTabPressed:(id)sender;
-(IBAction) infoTabPressed:(id)sender;
-(IBAction) commentsTabPressed:(id)sender;
-(IBAction) toggleSrcheko:(id)sender;
-(void)webPressed:(id)sender;
-(void)emailPressed:(id)sender;
-(void)gpsPressed:(id)sender;
-(void)phonePressed:(id)sender;
-(void)removeIcons;
-(IBAction)changePage:(id)sender;
-(void)vote;
-(IBAction) addComment:(id)sender;
-(void)reloadComments;
-(BOOL)reachable;
-(BOOL)checkReachability;

@end
