//
//  MAViewController.m
//  MuseumApp
//
//  Created by Zoran Plesko on 12/16/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import "MAViewController.h"
#import "MAMuseumCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MAAnnotationView.h"
#import <MessageUI/MessageUI.h>
#import "MAAppDelegate.h"
#import "MATableView.h"
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import "MAInfoViewController.h"
#import "NSData+Additions.h"
#import "MAStringTranslator.h"

@interface MAViewController ()

@end

@implementation MAViewController

@synthesize tData, managedObjectContext, distanceSortBlock, picSortBlock, picturesDictionary, cells, sl, st;

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*UIFont *font = [UIFont systemFontOfSize:kBackFontSize];
    UIColor *blue = [UIColor blueColor];
    attributeStringDictionary = [[NSMutableDictionary alloc] init];
    [attributeStringDictionary setObject:font forKey:NSFontAttributeName];
    [attributeStringDictionary setObject:blue forKey:NSForegroundColorAttributeName];
    [attributeStringDictionary setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];*/
    //UISearchDisplayController
    self.searchDisplayController.searchBar.placeholder = [self.st locStr:@"Search"];
    [self.sl loadStars];
    self.locationManager.delegate=self;
	// Do any additional setup after loading the view, typically from a nib.
    tData = [[NSMutableArray alloc] init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Museum" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [self prepareDistanceSortBlock];
    [self preparePicSortBlock];
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name_hr" ascending:YES];
    //NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    //[fetchRequest setSortDescriptors:sortDescriptors];
    //NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"partnership=nil"];
    //NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"parent=nil"];
    //NSPredicate *predicate=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate1, predicate2, nil]];
    //[fetchRequest setPredicate:predicate];
    NSError *error;
    NSMutableArray *data = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    NSArray *sortedArray = [data sortedArrayUsingComparator:distanceSortBlock];
    data = [sortedArray mutableCopy];
    NSLog(@"Vodafak, koliko muzeja ima u bazi %d", data.count);
    self.tData = data;
    picturesDictionary = [[NSMutableDictionary alloc] init];
    for(NSManagedObject *museum in tData){
        NSMutableSet *pics = [museum valueForKey:@"pictures"];
        NSEnumerator *enumer = [pics objectEnumerator];
        NSManagedObject *pic;
        NSMutableArray *arr=[[NSMutableArray alloc] init];
        while (pic = [enumer nextObject]) {
            [arr addObject:pic];
        }
        [arr sortUsingComparator:picSortBlock];
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        for(NSManagedObject *pict in arr){
            NSString *picpath = [pict valueForKey:@"name"];
            UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:picpath ofType:nil]];
            if(img != nil){
                //NSLog(@"adding image %@, museum %@", picpath, [museum valueForKey:@"name_hr"]);
                [imageArray addObject:img];
            }
        }
        [picturesDictionary setObject:imageArray forKey:[museum objectID]];
    }
    [self cacheCells];
}

-(void)refreshStars:(NSMutableDictionary *)stars{
    //NSLog(@"Kao ucitali smo te zvijezde %@", stars);
    MAAppDelegate *ad = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
    for(int i = 0;i<self.tData.count;i++){
        NSManagedObject *museum = [tData objectAtIndex:i];
        NSString *server_idstring = [museum valueForKey:@"server_id"];
        NSNumber *server_id = [NSNumber numberWithInteger:[server_idstring intValue]];
        NSDecimalNumber *avg_rating = [stars objectForKey:server_id];
        //NSLog(@"avg_rating for server_id:%d is %f", [server_id intValue], [avg_rating doubleValue]);
        [museum setValue:avg_rating forKey:@"avg_rating"];
        [ad saveContext];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        MAMuseumCell *cell = (MAMuseumCell *)[self tableView:self.uit cellForRowAtIndexPath:indexPath];
        cell.avg_rating = avg_rating;
    }
}

-(void)cacheCells{
    //EXTREMELY STUPID AND FUN METHOD PRECACHE EVERYTHING  JUHU!!!
    cells = [[NSMutableDictionary alloc] init];
    /*for(int i=0; i<tData.count;i++){
        //NSManagedObject *obj = [tData objectAtIndex:i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        //MAMuseumCell *cell=(MAMuseumCell *)[self tableView:self.uit cellForRowAtIndexPath:indexPath];
        //NSLog(@"i is %d",i);
        //[cells setObject:cell forKey:[obj objectID]];
    }*/
}

-(void)prepareDistanceSortBlock{
    self.distanceSortBlock = ^(id obj1, id obj2){
        NSDecimalNumber *latitude1 = [((NSManagedObject *)obj1) valueForKey:@"latitude"];
        NSDecimalNumber *longitude1 = [((NSManagedObject *)obj1) valueForKey:@"longitude"];
        NSDecimalNumber *latitude2 = [((NSManagedObject *)obj2) valueForKey:@"latitude"];
        NSDecimalNumber *longitude2 = [((NSManagedObject *)obj2) valueForKey:@"longitude"];
        CLLocation *plocation1=[[CLLocation alloc] initWithLatitude:[latitude1 doubleValue]
                                                          longitude:[longitude1 doubleValue]];
        CLLocation *plocation2=[[CLLocation alloc] initWithLatitude:[latitude2 doubleValue]
                                                          longitude:[longitude2 doubleValue]];
        CLLocationDistance dist1 = [self.currentLocation distanceFromLocation:plocation1];
        CLLocationDistance dist2 = [self.currentLocation distanceFromLocation:plocation2];
        if (dist1 == dist2)
            return NSOrderedSame;
        if (dist1 < dist2)
            return NSOrderedAscending;
        return NSOrderedDescending;
    };
}

-(void)preparePicSortBlock{
    self.picSortBlock = ^(id obj1, id obj2){
        NSNumber *order1 = [((NSManagedObject *)obj1) valueForKey:@"order"];
        NSNumber *order2 = [((NSManagedObject *)obj2) valueForKey:@"order"];
        return (NSComparisonResult)[ order1 compare: order2];
    };
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [tData count];
        
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row=[indexPath row];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        static NSString *SearchTableIdentifier = @"SearchTableIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchTableIdentifier];
        if(cell==nil){
            cell = [[UITableViewCell alloc] init];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        NSString *text = [[searchResults objectAtIndex:indexPath.row] valueForKey:[self.st locStr:@"name_en"]];
        text = [text stringByAppendingFormat:@", %@", [[searchResults objectAtIndex:indexPath.row] valueForKey:@"city"]];
        CGSize size = cell.textLabel.frame.size;
        while (size.width>cell.textLabel.frame.size.width && cell.textLabel.font.pointSize > 9){
            [cell.textLabel setFont:[UIFont systemFontOfSize:cell.textLabel.font.pointSize-1]];
            size = [text sizeWithFont:cell.textLabel.font];
        }
        if(size.width>cell.textLabel.frame.size.width && cell.textLabel.font.pointSize == 9){
            [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [cell.textLabel setNumberOfLines:0];
        }

        cell.textLabel.text = text;
        //cell.contentView.backgroundColor = [UIColor colorWithRed:0.333 green:0.529 blue:0.635 alpha:1];
        return cell;
    }
    if(row+1<=cells.count){
        NSManagedObjectID *objid = [[tData objectAtIndex:row] objectID];
        MAMuseumCell *cellFromCache = (MAMuseumCell *)[cells objectForKey:objid];
        if(cellFromCache) return cellFromCache;
    }
    
    static NSString *MuseumTableIdentifier = @"MuseumTableIdentifier";
    
    MAMuseumCell *cell = [tableView dequeueReusableCellWithIdentifier:MuseumTableIdentifier];
    
    
    
    if(cell==nil){
        NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MAMuseumCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[MAMuseumCell class]]){
                cell = (MAMuseumCell *) currentObject;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                break;
            }
        }
    }
    NSManagedObject *museum = [tData objectAtIndex:row];
    NSMutableArray *pics = [picturesDictionary objectForKey:[museum objectID]];
    float i = 0;
    for(UIImage *img in pics){
        //NSLog(@"found pics");
        UIImageView *uiv=[[UIImageView alloc] initWithImage:img];
        [uiv setFrame:CGRectMake(0+285*i,0,285,160)];
        [cell.myScrollView addSubview:uiv];
        i++;
    }
    cell.pageControl.numberOfPages = i;
    cell.avg_rating = [museum valueForKey:@"avg_rating"];
    NSString *museumName = [museum valueForKey:[self.st locStr:@"name_en"]];
    museumName = [museumName stringByAppendingFormat:@", %@", [museum valueForKey:@"city"]];
    CGSize size = [museumName sizeWithFont:cell.textich.font];
    while (size.width>cell.textich.frame.size.width && cell.textich.font.pointSize > 9){
        [cell.textich setFont:[UIFont systemFontOfSize:cell.textich.font.pointSize-1]];
        size = [museumName sizeWithFont:cell.textich.font];
    }
    if(size.width>cell.textich.frame.size.width && cell.textich.font.pointSize == 9){
        [cell.textich setLineBreakMode:NSLineBreakByWordWrapping];
        [cell.textich setNumberOfLines:0];
    }
    [cell.textich setText:museumName];
    //NSLog(@"font size is :%f",cell.textich.font.pointSize);
    [cell.about setText:[museum valueForKey:[self.st locStr:@"about_en"]]];
    [cell.about setFont:[cell.about.font fontWithSize:kBackFontSize]];
    NSString *hoursHTML = [self makeHTMLDocFromString:[museum valueForKey:[self.st locStr:@"hours_en"]]];
    [cell.workingHours loadHTMLString:hoursHTML baseURL:nil];
    NSString *price = [museum valueForKey:[self.st locStr:@"price_en"]];
    NSString *guide = [museum valueForKey:[self.st locStr:@"guide_en"]];
    NSString *tickets = [NSString stringWithFormat:@"%@</br></br>%@</br>",price, guide];
    NSString *ticketsHTML = [self makeHTMLDocFromString:tickets];
    
    NSString *stringBaseURL = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] bundlePath] ];
    NSURL *baseURL = [NSURL URLWithString:stringBaseURL];
    [cell.tickets loadHTMLString:ticketsHTML baseURL:baseURL];
    NSString *address = [NSString stringWithFormat:@"<strong>%@:</strong> %@ %@, %@</br>", [self.st locStr:@"Address"],[museum valueForKey:@"street"], [museum valueForKey:@"no"], [museum valueForKey:@"city"]];
    NSString *tel = [NSString stringWithFormat:@"<strong>%@:</strong> %@</br>", [self.st locStr:@"Phone"], [museum valueForKey:@"tel"]];
    NSDecimalNumber *longitude = [museum valueForKey:@"longitude"];
    NSDecimalNumber *latitude = [museum valueForKey:@"latitude"];
    NSString *GPS = [NSString stringWithFormat:@"<strong>%@:</strong> %f, %f</br></br>", @"GPS",latitude.doubleValue, longitude.doubleValue];
    NSString *event = [NSString stringWithFormat:@"%@</br>",[museum valueForKey:[self.st locStr:@"event_en"]]];
    NSString *additional = [NSString stringWithFormat:@"%@</br></br>", [museum valueForKey:[self.st locStr:@"additional_en"]]];
    NSString *comment = [NSString stringWithFormat:@"%@", [museum valueForKey:[self.st locStr:@"comment_en"]]];
    NSString *info = [NSString stringWithFormat:@"%@%@%@%@%@%@", tel, address, GPS, event, additional, comment];
    NSString *infoHTML = [self makeHTMLDocFromString:info];
    [cell.info loadHTMLString:infoHTML baseURL:nil];
    [cell.info setDelegate:self];
    //[cell.info.scrollView addSubview:webutton];
    [cell setAccess:[museum valueForKey:@"access"]];
    [cell setShop:[museum valueForKey:@"shop"]];
    [cell setCaffe:[museum valueForKey:@"cafe"]];
    [cell setWww:[museum valueForKey:@"web"]];
    [cell setEmail:[museum valueForKey:@"mail"]];
    [cell setGps:[NSString stringWithFormat:@"%f, %f", latitude.doubleValue, longitude.doubleValue]];
    [cell setPhone:[museum valueForKey:@"tel"]];
    [cell setAudio:[museum valueForKey:@"audio"]];
    CLLocation *plocation=[[CLLocation alloc] initWithLatitude:[latitude doubleValue]
                                                      longitude:[longitude doubleValue]];
    CLLocationDistance dist = [self.currentLocation distanceFromLocation:plocation];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:1];
    [numberFormatter setDecimalSeparator:@"."];
    NSString *distance=[numberFormatter stringFromNumber:[NSNumber numberWithDouble:(dist/1000)]];
    distance = [distance stringByAppendingString:@"km"];
    [cell.distance setText:distance];
    if([[museum valueForKey:@"favourite"] boolValue])
        [cell toggleSrcheko:nil];
    UITapGestureRecognizer *workingTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [workingTapG setDelegate:self];
    [cell.workingHours addGestureRecognizer:workingTapG];
    UITapGestureRecognizer *ticketsTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [ticketsTapG setDelegate:self];
    [cell.tickets addGestureRecognizer:ticketsTapG];
    UITapGestureRecognizer *infoTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [infoTapG setDelegate:self];
    [cell.info addGestureRecognizer:infoTapG];
    UITapGestureRecognizer *commentTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [commentTapG setDelegate:self];
    [cell.comments addGestureRecognizer:commentTapG];
    UITapGestureRecognizer *aboutTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [cell.about addGestureRecognizer:aboutTapG];
    cell.server_id = [museum valueForKey:@"server_id"];
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [cell.myScrollView addGestureRecognizer:tapG];
    [cell.myScrollView setContentSize:CGSizeMake(i*285,160)];
    [cell.myScrollView setPagingEnabled:YES];
    cell.st = self.st;
    [cells setObject:cell forKey:[museum objectID]];
    //[cell.myScrollContainerView.layer setMasksToBounds:NO];
    //cell.myScrollContainerView.layer.shadowOffset = CGSizeMake(0, 2);
    //cell.myScrollContainerView.layer.shadowRadius = 3;
    //cell.myScrollContainerView.layer.shadowOpacity = 0.5;
    //[cell.mainView addSubview:cell.firstView];
    
    return cell;
    
}

-(UIImage *) ChangeViewToImage : (UIView *) view{
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

-(void)tableView:(UITableView *)tableView showAddComment:(NSIndexPath *)indexPath{
    if(![self checkReachability:@"comment"]) return;
    if(activeMuseum) return;
    NSManagedObject *museum = [tData objectAtIndex:[indexPath row]];
    activeMuseum = museum;
    UIView *addCommentView = [[UIView alloc] initWithFrame:CGRectMake(160,190,0,0)];
    [addCommentView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [addCommentView.layer setMasksToBounds:YES];
    [addCommentView.layer setCornerRadius:10];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:[self.st locStr:@"Cancel"] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0,0,0,0)];
    [cancelButton setBackgroundColor:[UIColor colorWithRed:0.11 green:0.635 blue:0.988 alpha:1]];
    [cancelButton.layer setMasksToBounds:YES];
    [cancelButton.layer setCornerRadius:8];
    [cancelButton addTarget:self action:@selector(cancelVote:) forControlEvents:UIControlEventTouchUpInside];
    [addCommentView addSubview:cancelButton];
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:[self.st locStr:@"Comment"] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setFrame:CGRectMake(0,0,0,0)];
    [confirmButton setBackgroundColor:[UIColor colorWithRed:0.11 green:0.635 blue:0.988 alpha:1]];
    [confirmButton.layer setMasksToBounds:YES];
    [confirmButton.layer setCornerRadius:8];
    [confirmButton addTarget:self action:@selector(commentMuseum:) forControlEvents:UIControlEventTouchUpInside];
    [addCommentView addSubview:confirmButton];
    commentField = [[UITextView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [commentField setDelegate:self];
    //[commentField setAlpha:0.7];
    commentField.font = [commentField.font fontWithSize:17];
    [addCommentView addSubview:commentField];
    [self.view addSubview:addCommentView];
    [UIView animateWithDuration:aniDuration animations:^{
        [addCommentView setFrame:CGRectMake(40,60,240,170)];
        [cancelButton setFrame:CGRectMake(30,120,80,30)];
        [confirmButton setFrame:CGRectMake(130,120,80,30)];
        [commentField setFrame:CGRectMake(20,20,200,80)];
    } completion:nil];
    /*[UIView animateWithDuration:aniDuration animations:^{
        [addCommentView setFrame:CGRectMake(10,20,300,250)];
        [cancelButton setFrame:CGRectMake(60,200,80,30)];
        [confirmButton setFrame:CGRectMake(160,200,80,30)];
        [commentField setFrame:CGRectMake(20,20,260,100)];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:aniDuration animations:^{
            [addCommentView setFrame:CGRectMake(50,70,220,150)];
            [cancelButton setFrame:CGRectMake(20,100,80,30)];
            [confirmButton setFrame:CGRectMake(120,100,80,30)];
            [commentField setFrame:CGRectMake(20,20,180,60)];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:aniDuration animations:^{
                [addCommentView setFrame:CGRectMake(40,60,240,170)];
                [cancelButton setFrame:CGRectMake(30,120,80,30)];
                [confirmButton setFrame:CGRectMake(130,120,80,30)];
                [commentField setFrame:CGRectMake(20,20,200,80)];
            }];
        }];
    }];*/
    [self.uit setUserInteractionEnabled:NO];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

-(void)tableView:(UITableView *)tableView vote:(NSIndexPath *)indexPath{
    if(![self checkReachability:@"rate"]) return;
    if(activeMuseum) return;
    NSManagedObject *museum = [tData objectAtIndex:[indexPath row]];
    activeMuseum = museum;
    NSString *voted = [museum valueForKey:@"voted"];
    //NSString *name = [museum valueForKey:[self.st locStr:@"name_hr"]];
    NSString *message = [NSString stringWithFormat:@"%@", [self.st locStr:@"The museum can be rated only once, and you have already rated this one!"]];
    if([voted hasPrefix:@"Y"]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
        [av show];
        activeMuseum = nil;
        [self.uit setUserInteractionEnabled:YES];
    }else{
        UIView *voteView = [[UIView alloc] initWithFrame:CGRectMake(160,230,0,0)];
        [voteView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
        [voteView.layer setMasksToBounds:YES];
        [voteView.layer setCornerRadius:10];
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:[self.st locStr:@"Cancel"] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(0,0,0,0)];
        [cancelButton setBackgroundColor:[UIColor colorWithRed:0.11 green:0.635 blue:0.988 alpha:1]];
        [cancelButton.layer setMasksToBounds:YES];
        [cancelButton.layer setCornerRadius:8];
        [cancelButton addTarget:self action:@selector(cancelVote:) forControlEvents:UIControlEventTouchUpInside];
        [voteView addSubview:cancelButton];
        UIButton *voteButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img1 = [UIImage imageNamed:@"zvijezda.png"];
        [voteButton1 setImage:img1 forState:UIControlStateNormal];
        [voteButton1 setFrame:CGRectMake(0,0,0,0)];
        voteButton1.tag = 1;
        [voteButton1 addTarget:self action:@selector(voteForActiveMuseum:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *voteButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img2 = [UIImage imageNamed:@"star2.png"];
        [voteButton2 setImage:img2 forState:UIControlStateNormal];
        [voteButton2 setFrame:CGRectMake(220,0,0,0)];
        voteButton2.tag = 2;
        [voteButton2 addTarget:self action:@selector(voteForActiveMuseum:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *voteButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img3 = [UIImage imageNamed:@"star3.png"];
        [voteButton3 setImage:img3 forState:UIControlStateNormal];
        [voteButton3 setFrame:CGRectMake(0,0,0,0)];
        voteButton3.tag = 3;
        [voteButton3 addTarget:self action:@selector(voteForActiveMuseum:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *voteButton4 = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img4 = [UIImage imageNamed:@"star4.png"];
        [voteButton4 setImage:img4 forState:UIControlStateNormal];
        [voteButton4 setFrame:CGRectMake(220,0,0,0)];
        voteButton4.tag = 4;
        [voteButton4 addTarget:self action:@selector(voteForActiveMuseum:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *voteButton5 = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img5 = [UIImage imageNamed:@"star5.png"];
        [voteButton5 setImage:img5 forState:UIControlStateNormal];
        [voteButton5 setFrame:CGRectMake(0,0,0,0)];
        voteButton5.tag = 5;
        [voteButton5 addTarget:self action:@selector(voteForActiveMuseum:) forControlEvents:UIControlEventTouchUpInside];
        [voteView addSubview:voteButton1];
        [voteView addSubview:voteButton2];
        [voteView addSubview:voteButton3];
        [voteView addSubview:voteButton4];
        [voteView addSubview:voteButton5];
        [self.view addSubview:voteView];
        [UIView animateWithDuration:aniDuration animations:^{
            [voteView setFrame:CGRectMake(10,60,300,340)];
            [cancelButton setFrame:CGRectMake(110,280,80,30)];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:aniDuration animations:^{
                [voteView setFrame:CGRectMake(50,110,220,240)];
                [cancelButton setFrame:CGRectMake(70,180,80,30)];
            } completion:^(BOOL finished){
                [UIView animateWithDuration:aniDuration animations:^{
                    [voteView setFrame:CGRectMake(40,100,240,260)];
                    [cancelButton setFrame:CGRectMake(80,200,80,30)];
                    [voteButton1 setFrame:CGRectMake(112,30,17,17)];
                    [voteButton2 setFrame:CGRectMake(102,60,35,17)];
                    [voteButton3 setFrame:CGRectMake(93,90,53,17)];
                    [voteButton4 setFrame:CGRectMake(84,120,71,17)];
                    [voteButton5 setFrame:CGRectMake(75,150,89,17)];
                }];
            }];
        }];
        [self.uit setUserInteractionEnabled:NO];
    }
}

-(void)cancelVote:(id)sender{
    UIButton *canc = (UIButton *)sender;
    [canc.superview removeFromSuperview];
    [self.uit setUserInteractionEnabled:YES];
    activeMuseum = nil;
}

- (void)textViewDidChange:(UITextView *)textView{
    
    NSInteger restrictedLength=150;
    
    NSString *temp=textView.text;
    
    if([[textView text] length] > restrictedLength){
        textView.text=[temp substringToIndex:[temp length]-1];
    }
}

-(void)commentMuseum:(id)sender{
    if(![self checkReachability:@"comment"]) return;
    UIButton *confirm = (UIButton *)sender;
    NSString *commenter = @"";
    NSString *commtext = commentField.text;
    [self postMuseumComment:commenter commtext:commtext];
    MAAppDelegate *ad = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad saveContext];
    [confirm.superview removeFromSuperview];
    [self.uit setUserInteractionEnabled:YES];
    activeMuseum = nil;

}

-(void)postMuseumComment:(NSString *)commenter commtext:(NSString *)commtext{
    NSString *authStr = kAuthentication;
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    
    NSString *server_id = [activeMuseum valueForKey:@"server_id"];
    NSString *urlString = [NSString stringWithFormat:@"%@museums/%@/comments.json",kMuseumURL,server_id];
    NSURL *museumURL = [NSURL URLWithString:urlString];
    NSLog(@"will add comment to:%@",museumURL);
    
    NSString *post = [NSString stringWithFormat:@"comment[commenter]=%@&comment[commtext]=%@&comment[museum_id]=%@",commenter, commtext, server_id];
    post = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSLog(@"post is:%@",post);
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:museumURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    if(![[NSURLConnection alloc] initWithRequest:request delegate:self]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"GREŠKA"
                                                     message:@"Ne možete komentirati muzej, provjerite je li sve u redu s vašom internetskom vezom"
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
        [av show];
    }else{
        lastServer_id = server_id;
    }
 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"did finished loading/putting comments");
    if(!lastServer_id){
        //obviously it wasn't a comment, then it is stars...
        [sl loadStars];
        return;
    }
    NSUInteger index = [self.tData indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
        MAMuseumCell *compared = (MAMuseumCell *)obj;
        return [lastServer_id isEqualToString:compared.server_id];
    }];
    //NSLog(@"index is:%d",index);
    NSManagedObject *obj = [tData objectAtIndex:index];
    MAMuseumCell *cell = [cells objectForKey:[obj objectID]];
    [cell reloadComments];
    lastServer_id = nil;
}

/*-(void)voteForActiveMuseum:(id)sender{
    UIButton *canc = (UIButton *)sender;
    NSString *server_id = [activeMuseum valueForKey:@"server_id"];
    NSString *urlString = [NSString stringWithFormat:@"%@museums/%@.json",kMuseumURL,server_id];
    NSURL *museumURL = [NSURL URLWithString:urlString];
    NSLog(@"pitam za podatke od muzeja na:%@",museumURL);
    NSData* data = [NSData dataWithContentsOfURL:
                    museumURL];
    NSNumber *num_ratings;
    NSDecimalNumber *avg_rating;
    NSError *error;
    if(data!=nil) {
        NSDictionary* json = [NSJSONSerialization
                         JSONObjectWithData:data //1
                         options:kNilOptions
                         error:&error];
        num_ratings = (NSNumber *)[json valueForKey:@"num_ratings"];
        NSString *avg_rating_string = [json valueForKey:@"avg_rating"];
        avg_rating = [NSDecimalNumber decimalNumberWithString:avg_rating_string];
        double new_rating = (avg_rating.doubleValue*num_ratings.intValue+((UIButton *)sender).tag)/(num_ratings.intValue+1);
        [self postMuseumRating:new_rating num_ratings:num_ratings.intValue+1];
        [activeMuseum setValue:@"Y" forKey:@"voted"];
        MAAppDelegate *ad = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
        [ad saveContext];
    }else{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"GREŠKA"
                                                     message:@"Ne možete ocijeniti muzej, provjerite je li sve u redu s vašom internetskom vezom"
                                                    delegate:self
                                           cancelButtonTitle:@"U redu"
                                           otherButtonTitles: nil];
        [av show];
    }
    [canc.superview removeFromSuperview];
    //[self.sl loadStars];
    [self.uit setUserInteractionEnabled:YES];
    activeMuseum = nil;

}*/

-(void)voteForActiveMuseum:(id)sender{
    UIButton *voter = (UIButton *)sender;
    NSInteger rate=voter.tag;
    [self postMuseumRate:rate];
    [voter.superview removeFromSuperview];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                 message:[self.st locStr:@"Thank you!"]
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
    
}

-(void)postMuseumRating:(double) avg_rating num_ratings:(int) num_ratings{
    NSString *authStr = kAuthentication;
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    NSString *server_id = [activeMuseum valueForKey:@"server_id"];
    NSString *urlString = [NSString stringWithFormat:@"%@museums/%@.json",kMuseumURL,server_id];
    NSURL *museumURL = [NSURL URLWithString:urlString];
    NSLog(@"will update museum:%@",museumURL);
    
    NSString *post = [NSString stringWithFormat:@"museum[avg_rating]=%f&museum[num_ratings]=%d",avg_rating,num_ratings];
    post = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSLog(@"post is:%@",post);
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:museumURL];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    if(![[NSURLConnection alloc] initWithRequest:request delegate:self]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"GREŠKA"
                                                     message:@"Ne možete ocijeniti muzej, provjerite je li sve u redu s vašom internetskom vezom"
                                                    delegate:self
                                           cancelButtonTitle:@"U redu"
                                           otherButtonTitles: nil];
        [av show];
    }else{
        
    }
}

-(void)postMuseumRate:(int) rate{
    NSString *authStr = kAuthentication;
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    NSString *server_id = [activeMuseum valueForKey:@"server_id"];
    NSString *urlString = [NSString stringWithFormat:@"%@museums/%@.json",kMuseumURL,server_id];
    NSURL *museumURL = [NSURL URLWithString:urlString];
    NSLog(@"will update museum:%@",museumURL);
    
    NSString *post = [NSString stringWithFormat:@"museum[rate]=%d",rate];
    post = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSLog(@"post is:%@",post);
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:museumURL];
    [request setHTTPMethod:@"PUT"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    if(![[NSURLConnection alloc] initWithRequest:request delegate:self]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"GREŠKA"
                                                     message:@"Ne možete ocijeniti muzej, provjerite je li sve u redu s vašom internetskom vezom"
                                                    delegate:self
                                           cancelButtonTitle:@"U redu"
                                           otherButtonTitles: nil];
        [av show];
    }else{
        
    }

}

-(void)tableView:(UITableView *)tableView webPressed:(NSIndexPath *)indexPath{
    NSManagedObject *museum = [tData objectAtIndex:[indexPath row]];
    NSString *webString = [@"http://" stringByAppendingString:[museum valueForKey:@"web"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webString]];
}

-(void)tableView:(UITableView *)tableView emailPressed:(NSIndexPath *)indexPath{
    NSManagedObject *museum = [tData objectAtIndex:[indexPath row]];
    NSString *emailString = [museum valueForKey:@"mail"];
    // make sure this device is setup to send email
    if ([MFMailComposeViewController canSendMail]) {
        // create mail composer object
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        // make this view the delegate
        mailer.mailComposeDelegate = self;
        
        // set recipient
        [mailer setToRecipients:[NSArray arrayWithObject:emailString]];
        
        // generate message body
        NSString *body = [self.st locStr:@"Hello!"];
        
        // add to users signature
        [mailer setMessageBody:body isHTML:NO];
        
        // present user with composer screen
        [self presentModalViewController:mailer animated:YES];
        
    } else {
        // alert to user there is no email support
    }
}

-(void)tableView:(UITableView *)tableView gpsPressed:(NSIndexPath *)indexPath{
    NSManagedObject *museum = [tData objectAtIndex:[indexPath row]];
    //NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : self.address};    
    if([[MKMapItem class] respondsToSelector:@selector(openMapsWithItems:launchOptions:)]){
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[museum valueForKey:@"latitude"] doubleValue];
        coordinate.longitude = [[museum valueForKey:@"longitude" ] doubleValue];
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:coordinate
                              addressDictionary:nil];
        MKMapItem *museumLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
        NSArray *mapitems = [[NSArray alloc] initWithObjects:currentLocation, museumLocation, nil];
        NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
        [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
        [MKMapItem openMapsWithItems:mapitems launchOptions:launchOptions];
    }else{
        MAAppDelegate *ad = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
        CLLocationCoordinate2D coordinate = ad.startLocation.coordinate;
        NSString *lats=[[museum valueForKey:@"latitude"] stringValue];
        NSString *lons=[[museum valueForKey:@"longitude"] stringValue];
        NSString *latlong=[[lats stringByAppendingString:@","] stringByAppendingString:lons];
        NSString *urli=[NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%@", coordinate.latitude,coordinate.longitude,[latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *url = [NSURL URLWithString:urli];
        if (![[UIApplication sharedApplication] openURL:url])
            NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}


-(void)tableView:(UITableView *)tableView phonePressed:(NSIndexPath *)indexPath{
    NSLog(@"phone Pressed");
    NSManagedObject *museum = [tData objectAtIndex:[indexPath row]];
    NSString *phones = [museum valueForKey:@"tel"];
    NSArray *phoneArray = [phones componentsSeparatedByString:@", "];
    NSString *phone = [phoneArray objectAtIndex:0];
    phone = [@"telprompt://" stringByAppendingString:phone];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"phone is :%@", phone);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];

}

-(void)webPressed:(id)sender{
    if([sender isKindOfClass:[UIButton class]]){
    UIButton *but = (UIButton *)sender;
    /*WHEN IOS6 kicks in, then do it like this
     NSAttributedString *webString = [but attributedTitleForState:UIControlStateNormal];
    NSString *webStringString = [@"http://" stringByAppendingString:[webString string]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webStringString]];*/
    NSString *webString = [@"http://" stringByAppendingString:[but titleForState:UIControlStateNormal]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webString]];
    }else{
        NSLog(@"ODI U VRAZJU MATER");
    }
}

-(void) tableView:(UITableView *)tableView favouritedCell:(NSIndexPath *)indexPath{
    NSManagedObject *cellObject = [tData objectAtIndex:[indexPath row]];
    [cellObject setValue:[NSNumber numberWithBool:YES] forKey:@"favourite"];
    MAAppDelegate *ad = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad saveContext];
}

-(void) tableView:(UITableView *)tableView unfavouritedCell:(NSIndexPath *)indexPath{
    NSManagedObject *cellObject = [tData objectAtIndex:[indexPath row]];
    [cellObject setValue:[NSNumber numberWithBool:NO] forKey:@"favourite"];
    MAAppDelegate *ad = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad saveContext];
}

- (BOOL)webView:(UIWebView *)sender shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
	if ([request.URL.scheme isEqualToString:@"mailto"]) {
         NSLog(@"WTF!!!");
         // make sure this device is setup to send email
         if ([MFMailComposeViewController canSendMail]) {
             // create mail composer object
             MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
             
             // make this view the delegate
             mailer.mailComposeDelegate = self;
             
             // set recipient
             [mailer setToRecipients:[NSArray arrayWithObject:request.URL.resourceSpecifier]];
             
             // generate message body
             NSString *body = [self.st locStr:@"Hello!"];
             
             // add to users signature
             [mailer setMessageBody:body isHTML:NO];

             // present user with composer screen
             [self presentModalViewController:mailer animated:YES];
             
         } else {
             // alert to user there is no email support
         }
         
         // don't load url in this webview
         return NO;
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *URL = [request URL];
        NSString *lauba = [URL relativeString];
        NSLog(@"lauba is %@", lauba);
        //lauba = [lauba stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:lauba]];
        NSLog(@"url is:%@", URL);
        return NO;
    }
         
         return YES;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSLog(@"WTF2");
    [self dismissModalViewControllerAnimated:YES];
    
    NSLog (@"mail finished");
}

//method to allow us to  tap on web view. it ensures that tap doesn't get stopped in uiwebview

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(NSString *)makeHTMLDocFromString:(NSString *)input{
    return [NSString stringWithFormat:@"<html> \n"
     "<head> \n"
     "<meta name=\"format-detection\" content=\"telephone=no\">"
     "<style type=\"text/css\"> \n"
     "body {font-family: \"%@\"; font-size: %@;}\n"
     "ul {border: 0px solid #000;"
     "margin-left: 2em;"
     "margin-top: 0em;"
     "margin-bottom: 0em;"
     "padding: 0px;}\n"
     "</style> \n"
     "</head> \n"
     "<body>%@</body> \n"
     "</html>", @"helvetica", [NSNumber numberWithInt:kBackFontSize], input];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    NSIndexPath *indexPath;
    NSLog(@"tapkam");
    //Sluzi za prenijeti tap do uitableviewcell jer scroll view ni uitextView to ne radi po defaultu
    if([tap.view isKindOfClass:[UITextView class]] || [tap.view isKindOfClass:[UIWebView class]]){
        NSLog(@"tapkam text");
        UIScrollView *scrollView = (UIScrollView *)tap.view;
        MAMuseumCell *cell = (MAMuseumCell *)scrollView.superview.superview.superview.superview;
        indexPath = [self.uit indexPathForCell:cell];
    }else{
        UIScrollView *scrollView = (UIScrollView *)tap.view;
        MAMuseumCell *cell = (MAMuseumCell *)scrollView.superview.superview.superview.superview.superview;
        indexPath = [self.uit indexPathForCell:cell];
    }
    [self tableView:self.uit didSelectRowAtIndexPath:indexPath];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self.searchDisplayController isActive]) {
            [self.searchDisplayController setActive:NO];
            
        }
        NSManagedObjectID *objectID = [[searchResults objectAtIndex:[indexPath row]] objectID];
        NSUInteger row=[self.tData indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
            NSManagedObject *elementOfArray = (NSManagedObject *)obj;
            if([[elementOfArray objectID] isEqual:objectID]){
                return YES;
            }else{
                return NO;
            }
        }];
        NSLog(@"NAdjeni muzej je %@",[[tData objectAtIndex:row] valueForKey:@"name_hr"]);
        NSIndexPath *nsip = [NSIndexPath indexPathForRow:row inSection:0];
        MAMuseumCell *cell = (MAMuseumCell *)[self.uit cellForRowAtIndexPath:nsip];
        if([cell.mainView isEqual:cell.firstView.superview]){
            [cell flipCell];
        }
        [self.uit scrollToRowAtIndexPath:nsip atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        return;
    }
    NSLog(@"FLIPAM DJIPAM");
    MAMuseumCell *cell = (MAMuseumCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell flipCell];
    
}

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
        self.currentLocation = newLocation;
}

-(IBAction)orderByAlphabet:(id)sender{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Museum" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSMutableArray *data = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    self.tData = data;
        NSComparator alphabetSortBlock = ^(id obj1, id obj2){
            NSString *order1 = [((NSManagedObject *)obj1) valueForKey:[self.st locStr:@"name_en"]];
            NSString *order2 = [((NSManagedObject *)obj2) valueForKey:[self.st locStr:@"name_en"]];
            order1 = [order1 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            order2 = [order2 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            return (NSComparisonResult)[ order1 compare: order2];
        };
    [tData sortUsingComparator:alphabetSortBlock];
    //[self cacheCells];
    [self.uit reloadData];
    [self.uit scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    for(NSManagedObject *museum in tData){
        MAMuseumCell *cell = (MAMuseumCell *)[cells objectForKey:[museum objectID]];
        [cell closeCell];
    }
}

-(IBAction)orderByRating:(id)sender{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Museum" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSMutableArray *data = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    self.tData = data;
    NSComparator ratingSortBlock = ^(id obj1, id obj2){
        NSDecimalNumber *order1 = [((NSManagedObject *)obj1) valueForKey:@"avg_rating"];
        NSDecimalNumber *order2 = [((NSManagedObject *)obj2) valueForKey:@"avg_rating"];
        return (NSComparisonResult)[ order2 compare: order1];
    };
    [tData sortUsingComparator:ratingSortBlock];
    //[self cacheCells];
    [self.uit reloadData];
    [self.uit scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    for(NSManagedObject *museum in tData){
        MAMuseumCell *cell = (MAMuseumCell *)[cells objectForKey:[museum objectID]];
        [cell closeCell];
    }
}

-(IBAction)showFavourites:(id)sender{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Museum" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favourite=YES"];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSMutableArray *data = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if(data.count==0){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:[self.st locStr:@"You haven't added any museum to your favourites yet :("]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    NSLog(@"Fetch error %@", [error userInfo]);
    NSArray *sortedArray = [data sortedArrayUsingComparator:distanceSortBlock];
    data = [sortedArray mutableCopy];
    self.tData = data;
    //[self cacheCells];
    [self.uit reloadData];
    [self.uit scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    for(NSManagedObject *museum in tData){
        MAMuseumCell *cell = (MAMuseumCell *)[cells objectForKey:[museum objectID]];
        [cell closeCell];
    }
}

-(IBAction)orderByLocation:(id)sender{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Museum" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSMutableArray *data = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    self.tData = data;
    [tData sortUsingComparator:distanceSortBlock];
    //[self cacheCells];
    [self.uit reloadData];
    [self.uit scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    for(NSManagedObject *museum in tData){
        MAMuseumCell *cell = (MAMuseumCell *)[cells objectForKey:[museum objectID]];
        [cell closeCell];
    }
}

- (void) dismissModalView:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    searchText = [searchText uppercaseString];
    NSString *spaceSearchText = [NSString stringWithFormat:@" %@", searchText];
    NSString *quoteSearchText = [NSString stringWithFormat:@"\"%@", searchText];
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithBlock:^(id evaluatedObject, NSDictionary *bindings) {
                                        NSManagedObject *obj = (NSManagedObject *)evaluatedObject;
                                        NSString *searchedText = [[obj valueForKey:[self.st locStr:@"name_en"]] uppercaseString];
                                        searchedText = [searchedText stringByAppendingFormat:@", %@" , [[obj valueForKey:@"city"] uppercaseString]];
                                        if([searchedText hasPrefix:searchText] || [searchedText rangeOfString:spaceSearchText].location != NSNotFound || [searchedText rangeOfString:quoteSearchText].location != NSNotFound){
                                            return YES;
                                        }else{
                                            return NO;
                                        }
                                    }];
    searchResults = [tData filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void) dismissModalViewAndPositionTable:(id)sender{
    UIButton *buttonPressed = (UIButton *)sender;
    MAAnnotationView *anotView = (MAAnnotationView *)[[buttonPressed superview] superview];
    NSManagedObjectID *objectID = [anotView objectID];
    //- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
    NSUInteger row=[self.tData indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
        NSManagedObject *elementOfArray = (NSManagedObject *)obj;
        if([[elementOfArray objectID] isEqual:objectID]){
            NSLog(@"Nađen MUZEJ");
            return YES;
        }else{
            return NO;
        }
    }];
    NSLog(@"NAdjeni muzej je %@",[[tData objectAtIndex:row] valueForKey:@"name_hr"]);
    NSIndexPath *nsip = [NSIndexPath indexPathForRow:row inSection:0];
    [self.uit scrollToRowAtIndexPath:nsip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    MAMuseumCell *cell = (MAMuseumCell *)[self.uit cellForRowAtIndexPath:nsip];
    if([cell.mainView isEqual:cell.firstView.superview]){
        [cell flipCell];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MapSegue"]) {
        MAMapViewController *mvc = segue.destinationViewController;
        mvc.st = self.st;
        [mvc setDelegate:self];
        [mvc setTData:self.tData];
    }else if([segue.identifier isEqualToString:@"Info"]){
        MAInfoViewController *mvc = segue.destinationViewController;
        mvc.st = self.st;
        [mvc setDelegate:self];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)checkReachability:(NSString *)rateorcomment{
    if(![self reachable]){
        NSString *message;
        if([rateorcomment hasPrefix:@"rate"])
            message = [self.st locStr:@"To rate the museum, you need internet connection!"];
        else if([rateorcomment hasPrefix:@"comment"])
            message = [self.st locStr:@"To post a comment, you need internet connection!"];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:message
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
    Reachability *r = [Reachability reachabilityWithHostName:@"www.cromuseums.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
        return YES;
    }
    return NO;
}


@end
