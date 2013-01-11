//
//  MAStarLoader.m
//  MuseumApp
//
//  Created by Zoran Plesko on 1/6/13.
//  Copyright (c) 2013 Zoran Plesko. All rights reserved.
//

#import "MAStarLoader.h"


@implementation MAStarLoader

@synthesize delegate;

-(void)loadStars{
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        kMuseumsURL];
        starsRatings = [[NSMutableDictionary alloc] init];
        NSError *error;
        if(data!=nil) {
            NSArray* json = [NSJSONSerialization
                              JSONObjectWithData:data //1
                              options:kNilOptions
                              error:&error];
            int i=0;
            for(NSDictionary *museum in json){
                i++;
                //NSLog(@"%d muzeja do sad", i);
                NSNumber *server_id = (NSNumber *)[museum objectForKey:@"id"];
                NSString *avg_ratingstring = (NSString *)[museum objectForKey:@"avg_rating"];
                NSDecimalNumber *avg_rating = [NSDecimalNumber decimalNumberWithString:avg_ratingstring];
                [starsRatings setObject:avg_rating forKey:server_id];
            }
            //NSLog(@"procito muzeje, pozvat cu finishedFetchingData sa starsDictionary:%@",starsRatings);
            [self performSelectorOnMainThread:@selector(finishedFetchingData:) withObject:starsRatings waitUntilDone:YES];
        }
    });
    
}

-(void)finishedFetchingData:(NSMutableDictionary *)starsDictionary{
    //NSLog(@"calling delegate for stars");
    [self.delegate refreshStars:starsDictionary];
}

@end
