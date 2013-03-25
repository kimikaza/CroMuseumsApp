//
//  MAInfoViewController.m
//  MuseumApp
//
//  Created by Zoran Plesko on 1/5/13.
//  Copyright (c) 2013 Zoran Plesko. All rights reserved.
//

#import "MAInfoViewController.h"
#import "MAStringTranslator.h"

@interface MAInfoViewController ()

@end

@implementation MAInfoViewController

@synthesize delegate, uisv, pageControl, st;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)changePage:(id)sender{
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.uisv.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.uisv.frame.size;
    [self.uisv scrollRectToVisible:frame animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.uisv.frame.size.width;
    int page = floor((self.uisv.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

-(void)tapped:(id)sender{
    NSLog(@"Tapped");
    [self.delegate dismissModalView:sender];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [upute setImage:[UIImage imageNamed:[self.st locStr:@"InfoScreenUputeEN.png"]]];
    [ikone setImage:[UIImage imageNamed:[self.st locStr:@"InfoScreenIkoneEN.png"]]];
    [praznici setImage:[UIImage imageNamed:[self.st locStr:@"InfoScreenPrazniciEN.png"]]];
    [jezik setImage:[UIImage imageNamed:[self.st locStr:@"InfoScreenJezikEN.png"]]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapGesture setDelegate:self];
    [self.view addGestureRecognizer:tapGesture];
    [self.uisv setContentSize:CGSizeMake(960, 180)];
    pageControl.numberOfPages = 3;
    //[self.background addGestureRecognizer:tapGesture];
    //[self.explanation addGestureRecognizer:tapGesture];
}

-(IBAction)gotoFacebook:(id)sender{
    if(![self checkReachability:kFacebookURL]) return;
    NSString *url = [NSString stringWithFormat:@"http://%@", @"www.facebook.com/CroMuseums?fref=ts"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
-(IBAction)gotoMasinerija:(id)sender{
    if(![self checkReachability:kMasinerijaURL]) return;
     NSString *url = [NSString stringWithFormat:@"http://%@",kMasinerijaURL];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

}

-(BOOL)checkReachability:(NSString *)url{
    if(![self reachable:url]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:[self.st locStr:@"It seems you are not connected to the internet"]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return NO;
    }
    return YES;
}

//IF WEBSITE IS REACHABLE then IT IS POSSIBLE TO OFFER online services
-(BOOL)reachable:(NSString *)url {
    Reachability *r = [Reachability reachabilityWithHostName:url];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    
    if (touch.view == facebookButton || touch.view == masinerijaButton) {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
