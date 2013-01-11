//
//  MACommentLoader.h
//  MuseumApp
//
//  Created by Zoran Plesko on 1/7/13.
//  Copyright (c) 2013 Zoran Plesko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAStringTranslator.h"

@protocol MACommentLoaderDelegate <NSObject>
@required
-(void)refreshComments:(NSString *)htmlString;
@end


@interface MACommentLoader : NSObject{
    NSString *htmlString;
}

@property (nonatomic, retain) id<MACommentLoaderDelegate> delegate;
@property (nonatomic, retain) MAStringTranslator *st;

-(void)loadComments:(NSString *)server_id;
-(void)finishedFetchingData:(NSString *)input;

@end
