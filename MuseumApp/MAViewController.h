//
//  MAViewController.h
//  MuseumApp
//
//  Created by Zoran Plesko on 12/16/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MAMapViewController.h"
#import <MessageUI/MessageUI.h>
#import "MATableView.h"
#import "MAInfoViewController.h"
#import "MAStarLoader.h"
#import "MAStringTranslator.h"

@interface MAViewController : UIViewController<UITableViewDataSource, MATableViewDelegate, CLLocationManagerDelegate, MAMapViewControllerDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, MFMailComposeViewControllerDelegate, MAInfoViewControllerDelegate, MAStarLoaderDelegate, UITextViewDelegate>{
    NSMutableArray *tData;
    BOOL tappable;
    NSArray *searchResults;
    NSMutableDictionary *attributeStringDictionary;
    NSManagedObject *activeMuseum;
    UITextView *commentField;
    NSString *lastServer_id;
}

@property (nonatomic, retain) NSMutableArray *tData;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic, strong) NSComparator distanceSortBlock;
@property (nonatomic, strong) NSComparator picSortBlock;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) IBOutlet UITableView *uit;
@property (nonatomic, retain) NSMutableDictionary *picturesDictionary;
@property (nonatomic, retain) NSMutableDictionary *cells;
@property (nonatomic, retain) MAStarLoader *sl;
@property (nonatomic, retain) MAStringTranslator *st;

- (void)handleSingleTap:(UITapGestureRecognizer *)tap;
-(void)prepareDistanceSortBlock;
-(void)preparePicSortBlock;
-(NSString *)makeHTMLDocFromString:(NSString *)input;
-(IBAction)orderByAlphabet:(id)sender;
-(IBAction)orderByRating:(id)sender;
-(IBAction)showFavourites:(id)sender;
-(IBAction)orderByLocation:(id)sender;
-(void)cacheCells;
-(void)webPressed:(id)sender;
-(UIImage *) ChangeViewToImage : (UIView *) view;
-(void)voteForActiveMuseum:(id)sender;
-(void)postMuseumRating:(double) avg_rating num_ratings:(int) num_ratings;
-(void)postMuseumRate:(int) rate;
-(void)commentMuseum:(id)sender;
-(void)postMuseumComment:(NSString *) commenter commtext:(NSString *) commtext;
-(BOOL)checkReachability:(NSString *)rateorcomment;
//IF WEBSITE IS REACHABLE then IT IS POSSIBLE TO OFFER online services
-(BOOL)reachable;
@end
