//
//  MAStarLoader.h
//  MuseumApp
//
//  Created by Zoran Plesko on 1/6/13.
//  Copyright (c) 2013 Zoran Plesko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MAStarLoaderDelegate <NSObject>
@required
-(void)refreshStars:(NSMutableDictionary *)stars;
@end


@interface MAStarLoader : NSObject{
    NSMutableDictionary *starsRatings;
}

@property (nonatomic, retain) id<MAStarLoaderDelegate> delegate;

-(void)loadStars;
-(void)finishedFetchingData:(NSMutableDictionary *)starsDictionary;

@end
