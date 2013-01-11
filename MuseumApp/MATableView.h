//
//  MATableView.h
//  MuseumApp
//
//  Created by Zoran Plesko on 12/30/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MATableViewDelegate<UITableViewDelegate>
@required
-(void) tableView:(UITableView *)tableView favouritedCell:(NSIndexPath *)indexPath;
-(void) tableView:(UITableView *)tableView unfavouritedCell:(NSIndexPath *)indexPath;
-(void) tableView:(UITableView *)tableView webPressed:(NSIndexPath *)indexPath;
-(void) tableView:(UITableView *)tableView emailPressed:(NSIndexPath *)indexPath;
-(void) tableView:(UITableView *)tableView gpsPressed:(NSIndexPath *)indexPath;
-(void) tableView:(UITableView *)tableView phonePressed:(NSIndexPath *)indexPath;
-(void) tableView:(UITableView *)tableView vote:(NSIndexPath *)indexPath;
-(void) tableView:(UITableView *)tableView showAddComment:(NSIndexPath *)indexPath;
@end

@interface MATableView : UITableView

@property (nonatomic, assign) id <MATableViewDelegate> delegate;

@end
