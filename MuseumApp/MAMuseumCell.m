//
//  MAMuseumCell.m
//  MuseumApp
//
//  Created by Zoran Plesko on 12/16/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import "MAMuseumCell.h"
#import "MATableView.h"
#import "MACommentLoader.h"
#import "Reachability.h"

@implementation MAMuseumCell

@synthesize mainView, firstView, secondView, myScrollView, myScrollContainerView, textich, about, workingHours, tickets, info, distance, pageControl, server_id, comments, st;

@synthesize access = _access;
@synthesize shop = _shop;
@synthesize caffe = _caffe;
@synthesize www = _www;
@synthesize email = _email;
@synthesize gps = _gps;
@synthesize phone = _phone;
@synthesize audio = _audio;
@synthesize avg_rating = _avg_rating;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        crveno = NO;
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) flipCell{
    if([self.mainView isEqual:firstView.superview]){
        if(!htmlComments){
            cl = [[MACommentLoader alloc] init];
            cl.delegate = self;
            [cl loadComments:server_id];
            cl.st = self.st;
        }
        [UIView transitionWithView:self.mainView
                  duration:0.7
                   options:UIViewAnimationOptionTransitionFlipFromLeft
                animations: ^{
                    [self.firstView removeFromSuperview];
                    [self.mainView addSubview:self.secondView];
                }
                completion:NULL];
    }else if([self.mainView isEqual:secondView.superview]){
        [UIView transitionWithView:self.mainView
                          duration:0.7
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations: ^{
                            [self.secondView removeFromSuperview];
                            [self.mainView addSubview:self.firstView];
                        }
                        completion:NULL];
 
    }
}

-(void) closeCell{
    if([self.mainView isEqual:secondView.superview]){
        [UIView transitionWithView:self.mainView
                          duration:0.7
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations: ^{
                            [self.secondView removeFromSuperview];
                            [self.mainView addSubview:self.firstView];
                        }
                        completion:NULL];
        
    }
}

-(void)refreshComments:(NSString *)htmlString{
    [comments loadHTMLString:htmlString baseURL:nil];
    //[comments reload];
}

-(void)webPressed:(id)sender{
    if(![self checkReachability]) return;
    MATableView *tv = (MATableView *)self.superview;
    [tv.delegate tableView:tv webPressed:[tv indexPathForCell:self]];
}

-(void)emailPressed:(id)sender{
    if(![self checkReachability]) return;
    MATableView *tv = (MATableView *)self.superview;
    [tv.delegate tableView:tv emailPressed:[tv indexPathForCell:self]];
}

-(void)gpsPressed:(id)sender{
    if(![self checkReachability]) return;
    MATableView *tv = (MATableView *)self.superview;
    [tv.delegate tableView:tv gpsPressed:[tv indexPathForCell:self]];
}

-(void)phonePressed:(id)sender{
    MATableView *tv = (MATableView *)self.superview;
    [tv.delegate tableView:tv phonePressed:[tv indexPathForCell:self]];
}

-(IBAction)toggleSrcheko:(id)sender{
    if(crveno){
        UIImage *img = [UIImage imageNamed:@"Srce prazno.png"];
        [srcheko setImage:img forState:UIControlStateNormal];
        crveno = NO;
        MATableView *tv = (MATableView *)self.superview;
        [tv.delegate tableView:tv unfavouritedCell:[tv indexPathForCell:self]];
    }else{
        UIImage *img = [UIImage imageNamed:@"Srce puno.png"];
        [srcheko setImage:img forState:UIControlStateNormal];
        crveno = YES;
        MATableView *tv = (MATableView *)self.superview;
        [tv.delegate tableView:tv favouritedCell:[tv indexPathForCell:self]];
    }
}

-(BOOL)checkReachability{
    if(![self reachable]){
        //NSLog(@"message expected here:%@",[self.st locStr:@"It seems your internet connection (or our server?) is down"]);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:[self.st locStr:@"It seems your internet connection is down"]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return NO;
    }
    return YES;
}

//IF WEBSITE IS REACHABLE then IT IS POSSIBLE TO OFFER online services
-(BOOL)reachable {
    Reachability *r = [Reachability reachabilityWithHostName:kCheckMuseumURL];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
        return YES;
    }
    return NO;
}

-(void)vote{
    MATableView *tv = (MATableView *)self.superview;
    [tv.delegate tableView:tv vote:[tv indexPathForCell:self]];
}

-(IBAction) addComment:(id)sender{
    //if(![self checkReachability]) return;
    MATableView *tv = (MATableView *)self.superview;
    [tv.delegate tableView:tv showAddComment:[tv indexPathForCell:self]];
}

-(void)reloadComments{
    [cl loadComments:server_id];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
    NSLog(@"touch cell");
    // If not dragging, send event to next responder
    [self.nextResponder touchesEnded: touches withEvent:event];
}

-(IBAction)changePage:(id)sender{
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.myScrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.myScrollView.frame.size;
    [self.myScrollView scrollRectToVisible:frame animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.myScrollView.frame.size.width;
    int page = floor((self.myScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}


-(void)removeIcons{
    [accessView removeFromSuperview];
    [shopView removeFromSuperview];
    [caffeView removeFromSuperview];
    [wwwView removeFromSuperview];
    [emailView removeFromSuperview];
    [gpsView removeFromSuperview];
    [phoneView removeFromSuperview];
    [audioView removeFromSuperview];
    [crta removeFromSuperview];
 
}

-(IBAction) museumTabPressed:(id)sender{
    [museumButton setImage:[UIImage imageNamed:@"MuzejW.png"] forState:UIControlStateNormal];
    [hourButton setImage:[UIImage imageNamed:@"SatB.png"] forState:UIControlStateNormal];
    [ticketButton setImage:[UIImage imageNamed:@"Ticket.png"] forState:UIControlStateNormal];
    [infoButton setImage:[UIImage imageNamed:@"InfoB.png"] forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"KomentarB.png"] forState:UIControlStateNormal];
    [workingHours removeFromSuperview];
    [tickets removeFromSuperview];
    [info removeFromSuperview];
    [comments removeFromSuperview];
    [UIView animateWithDuration:aniDuration animations:^{
        [invisibleAddComment setFrame:CGRectMake(219,14,0,0)];
    }];
    [self removeIcons];
    [about setFrame:kBackFrame];
    [secondView addSubview:about];
    
}

-(IBAction) workingHoursTabPressed:(id)sender{
    [museumButton setImage:[UIImage imageNamed:@"MuzejB.png"] forState:UIControlStateNormal];
    [hourButton setImage:[UIImage imageNamed:@"SatW.png"] forState:UIControlStateNormal];
    [ticketButton setImage:[UIImage imageNamed:@"Ticket.png"] forState:UIControlStateNormal];
    [infoButton setImage:[UIImage imageNamed:@"InfoB.png"] forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"KomentarB.png"] forState:UIControlStateNormal];
    [about removeFromSuperview];
    [tickets removeFromSuperview];
    [info removeFromSuperview];
    [comments removeFromSuperview];
    [UIView animateWithDuration:aniDuration animations:^{
        [invisibleAddComment setFrame:CGRectMake(219,14,0,0)];
    }];
    [self removeIcons];
    [workingHours setFrame:kBackFrame];
    [secondView addSubview:workingHours];
    
}

-(IBAction) ticketsTabPressed:(id)sender{
    [museumButton setImage:[UIImage imageNamed:@"MuzejB.png"] forState:UIControlStateNormal];
    [hourButton setImage:[UIImage imageNamed:@"SatB.png"] forState:UIControlStateNormal];
    [ticketButton setImage:[UIImage imageNamed:@"TicketW.png"] forState:UIControlStateNormal];
    [infoButton setImage:[UIImage imageNamed:@"InfoB.png"] forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"KomentarB.png"] forState:UIControlStateNormal];
    [about removeFromSuperview];
    [workingHours removeFromSuperview];
    [info removeFromSuperview];
    [comments removeFromSuperview];
    [UIView animateWithDuration:aniDuration animations:^{
        [invisibleAddComment setFrame:CGRectMake(219,14,0,0)];
    }];
    [self removeIcons];
    [tickets setFrame:kBackFrame];
    [secondView addSubview:tickets];
}

-(IBAction) infoTabPressed:(id)sender{
    [museumButton setImage:[UIImage imageNamed:@"MuzejB.png"] forState:UIControlStateNormal];
    [hourButton setImage:[UIImage imageNamed:@"SatB.png"] forState:UIControlStateNormal];
    [ticketButton setImage:[UIImage imageNamed:@"Ticket.png"] forState:UIControlStateNormal];
    [infoButton setImage:[UIImage imageNamed:@"InfoW.png"] forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"KomentarB.png"] forState:UIControlStateNormal];
    [about removeFromSuperview];
    [workingHours removeFromSuperview];
    [tickets removeFromSuperview];
    [comments removeFromSuperview];
    [UIView animateWithDuration:aniDuration animations:^{
        [invisibleAddComment setFrame:CGRectMake(219,14,0,0)];
    }];
    [info setFrame:kBackFrameNarrow];
    [secondView addSubview:info];
    [wwwView setFrame:CGRectMake(20,155,30,30)];
    [emailView setFrame:CGRectMake(20+35,155,30,30)];
    [phoneView setFrame:CGRectMake(20+35*2,155,30,30)];
    [gpsView setFrame:CGRectMake(20+35*3,155,30,30)];
    NSMutableArray *rightIcons = [[NSMutableArray alloc] initWithObjects:accessView, shopView, caffeView, audioView, nil];
    int position=0;
    for(int i = 0; i<rightIcons.count; i++){
        UIImageView *currentView = [rightIcons objectAtIndex:i];
        if([currentView image]!=nil){
            [currentView setFrame:CGRectMake(273-35*position,155,30,30)];
            position++;
        }
    }
    //[accessView setFrame:CGRectMake(273,155,30,30)];
    //[shopView setFrame:CGRectMake(273-35,155,30,30)];
    //[caffeView setFrame:CGRectMake(273-35*2,155,30,30)];
    //[audioView setFrame:CGRectMake(273-35*3,155,30,30)];
    crta = [[UIView alloc] initWithFrame:CGRectMake(20,146,280,1)];
    [crta setBackgroundColor:[UIColor colorWithRed:0.333 green:0.529 blue:0.635 alpha:1]];
    [secondView addSubview:crta];
    [secondView addSubview:wwwView];
    [secondView addSubview:emailView];
    [secondView addSubview:gpsView];
    [secondView addSubview:accessView];
    [secondView addSubview:shopView];
    [secondView addSubview:caffeView];
    [secondView addSubview:phoneView];
    [secondView addSubview:audioView];
}

-(IBAction) commentsTabPressed:(id)sender{
    [museumButton setImage:[UIImage imageNamed:@"MuzejB.png"] forState:UIControlStateNormal];
    [hourButton setImage:[UIImage imageNamed:@"SatB.png"] forState:UIControlStateNormal];
    [ticketButton setImage:[UIImage imageNamed:@"Ticket.png"] forState:UIControlStateNormal];
    [infoButton setImage:[UIImage imageNamed:@"InfoB.png"] forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"KomentarW.png"] forState:UIControlStateNormal];
    [about removeFromSuperview];
    [workingHours removeFromSuperview];
    [tickets removeFromSuperview];
    [info removeFromSuperview];
    [invisibleAddComment setFrame:CGRectMake(219,14,0,0)];
    [self removeIcons];
    [comments setFrame:kBackFrame];
    [secondView addSubview:comments];
    [UIView animateWithDuration:aniDuration animations:^{
        [invisibleAddComment setFrame:CGRectMake(242,0,40,30)];
        //[invisibleAddComment setBackgroundColor:[UIColor redColor]];
    }];
}

-(void)setAccess:(NSString *)access{
    _access = access;
    UIImage *img;
    if([_access  hasPrefix:@"Y"]){
        img = [UIImage imageNamed:@"Access.png" ];
    }else if([_access  hasPrefix:@"P"]){
        img = [UIImage imageNamed:@"AccessP.png"];
    }else{
        img = [UIImage imageNamed:@"AccessNo.png" ];
    }
    accessView = [[UIImageView alloc] initWithImage:img];
}

-(void)setShop:(NSString *)shop{
    _shop = shop;
    UIImage *img;
    if([_shop  hasPrefix:@"Y"]){
        img = [UIImage imageNamed:@"Shop.png" ];
        shopView = [[UIImageView alloc] initWithImage:img];
    }else{
        shopView = [[UIImageView alloc] init];
    }
}

-(void)setCaffe:(NSString *)caffe{
    _caffe = caffe;
    UIImage *img;
    if([_caffe  hasPrefix:@"Y"]){
        img = [UIImage imageNamed:@"Cafe.png" ];
        caffeView = [[UIImageView alloc] initWithImage:img];
    }else{
        caffeView = [[UIImageView alloc] init];
    }
}

-(void)setWww:(NSString *)www{
    _www = www;
    UIImage *img = [UIImage imageNamed:@"web.png"];
    wwwView = [UIButton buttonWithType:UIButtonTypeCustom];
    [wwwView setImage:img forState:UIControlStateNormal];
    [wwwView addTarget:self action:@selector(webPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setEmail:(NSString *)email{
    _email = email;
    UIImage *img = [UIImage imageNamed:@"mail.png"];
    emailView = [UIButton buttonWithType:UIButtonTypeCustom];
    [emailView setImage:img forState:UIControlStateNormal];
    [emailView addTarget:self action:@selector(emailPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setGps:(NSString *)gps{
    _gps = gps;
    UIImage *img = [UIImage imageNamed:@"lokacijaIkona.png"];
    gpsView = [UIButton buttonWithType:UIButtonTypeCustom];
    [gpsView setImage:img forState:UIControlStateNormal];
    [gpsView addTarget:self action:@selector(gpsPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setPhone:(NSString *)phone{
    _phone = phone;
    UIImage *img = [UIImage imageNamed:@"telefon.png"];
    phoneView = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneView setImage:img forState:UIControlStateNormal];
    [phoneView addTarget:self action:@selector(phonePressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setAudio:(NSString *)audio{
    _audio = audio;
    UIImage *img;
    if([_audio  hasPrefix:@"Y"]){
        img = [UIImage imageNamed:@"Audio.png" ];
        audioView = [[UIImageView alloc] initWithImage:img];
    }else{
        audioView = [[UIImageView alloc] init];
    }
}

-(void)setAvg_rating:(NSDecimalNumber *)avg_rating{
    _avg_rating = avg_rating;
    if(stars!=nil){
        for(UIView *uiv in stars){
            [uiv removeFromSuperview];
        }
    }
    stars = [[NSMutableArray alloc] init];
    double whole = floor([_avg_rating doubleValue]);
    double dec = _avg_rating.doubleValue - floor([_avg_rating doubleValue]);
    UIImage *img = [UIImage imageNamed:@"zvijezda.png"];
    UIImage *img2 = [UIImage imageNamed:@"zvijezdaPola.png"];
    UIImage *img3 = [UIImage imageNamed:@"StarPrazni.png"];
    double i;
    for(i=0;i<whole;i++){
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        [iv setFrame:CGRectMake(23+19*i,155,16,16)];
        [firstView addSubview:iv];
        [stars addObject:iv];
    }
    if(dec>=0.25 && dec<0.75){
        UIImageView *iv = [[UIImageView alloc] initWithImage:img2];
        [iv setFrame:CGRectMake(23+19*i,155,8,16)];
        [firstView addSubview:iv];
        [stars addObject:iv];
    }else if(dec>=0.75){
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        [iv setFrame:CGRectMake(23+19*i,155,16,16)];
        [firstView addSubview:iv];
        [stars addObject:iv];
    }
    if( i==0){
        UIImageView *iv = [[UIImageView alloc] initWithImage:img3];
        [iv setFrame:CGRectMake(23,154,90,18)];
        [firstView addSubview:iv];
        [stars addObject:iv];
 
    }
    UIButton *invisibleRatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [invisibleRatingButton setFrame:CGRectMake(23,149,118,32)];
    [invisibleRatingButton addTarget:self action:@selector(vote) forControlEvents:UIControlEventTouchUpInside];
    [firstView addSubview:invisibleRatingButton];
    [stars addObject:invisibleRatingButton];
    
}




@end
