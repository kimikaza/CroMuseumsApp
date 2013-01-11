//
//  MACommentLoader.m
//  MuseumApp
//
//  Created by Zoran Plesko on 1/7/13.
//  Copyright (c) 2013 Zoran Plesko. All rights reserved.
//

#import "MACommentLoader.h"

@implementation MACommentLoader

@synthesize delegate, st;

-(void)loadComments:(NSString *)server_id{
    dispatch_async(kBgQueue, ^{
        NSString *urlString = [NSString stringWithFormat:@"%@museums/%@/comments.json", kMuseumURL, server_id];
        NSURL *museumURL = [NSURL URLWithString:urlString];
        NSLog(@"loadam komentare za museumURL:%@", museumURL);
        NSData* data = [NSData dataWithContentsOfURL:
                        museumURL];
        NSError *error;
        htmlString = @"";
        if(data!=nil) {
            NSArray* json = [NSJSONSerialization
                             JSONObjectWithData:data //1
                             options:kNilOptions
                             error:&error];
            for(NSDictionary *comment in json){
                //NSLog(@"%d muzeja do sad", i);
                //NSString *commenter = (NSString *)[comment objectForKey:@"commenter"];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *timestamp = (NSString *)[comment objectForKey:@"created_at"];
                NSString *commtext = (NSString *)[comment objectForKey:@"commtext"];
                timestamp = [timestamp stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                timestamp = [timestamp stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                NSDate *date = [df dateFromString:timestamp];
                NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
                [df2 setDateFormat:@"dd.MM.yyyy"];
                NSDateFormatter *df3 = [[NSDateFormatter alloc] init];
                [df3 setDateFormat:@"HH:mm"];
                NSString *item = [NSString stringWithFormat:@"<strong>%@</strong>&nbsp;&nbsp;%@</br>%@</br></br>", [df2 stringFromDate:date], [df3 stringFromDate:date], commtext];
                NSLog(@"%@",commtext);
                htmlString = [htmlString stringByAppendingString:item];
            }
            if(htmlString.length==0) htmlString = [self.st locStr:@"No one has commented on this museum yet :(</br></br>(or you can't see the comments because you are not connected to the internet)"];
            htmlString = [NSString stringWithFormat:@"<html> \n"
             "<head> \n"
             "<meta name=\"format-detection\" content=\"telephone=no\">"
             "<style type=\"text/css\"> \n"
             "body {font-family: \"%@\"; font-size: %@;}\n"
             "</style> \n"
             "</head> \n"
             "<body>%@</body> \n"
             "</html>", @"helvetica", [NSNumber numberWithInt:kBackFontSize], htmlString];
            //NSLog(@"procito komentare:%@",htmlString);
            [self performSelectorOnMainThread:@selector(finishedFetchingData:) withObject:htmlString waitUntilDone:YES];
        }else{
            htmlString = [self.st locStr:@"No one has commented on this museum yet :(</br></br>(or you can't see the comments because you are not connected to the internet)"];
            htmlString = [NSString stringWithFormat:@"<html> \n"
                          "<head> \n"
                          "<meta name=\"format-detection\" content=\"telephone=no\">"
                          "<style type=\"text/css\"> \n"
                          "body {font-family: \"%@\"; font-size: %@;}\n"
                          "</style> \n"
                          "</head> \n"
                          "<body>%@</body> \n"
                          "</html>", @"helvetica", [NSNumber numberWithInt:kBackFontSize], htmlString];
            //NSLog(@"procito komentare:%@",htmlString);
            [self performSelectorOnMainThread:@selector(finishedFetchingData:) withObject:htmlString waitUntilDone:YES];
        }
    });
    
}


-(void)finishedFetchingData:(NSString *)input{
    NSLog(@"calling delegate for comments");
    [self.delegate refreshComments:input];
}


@end
