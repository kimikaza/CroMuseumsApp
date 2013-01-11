//
//  MAStringTranslator.h
//  MuseumApp
//
//  Created by Zoran Plesko on 1/9/13.
//  Copyright (c) 2013 Zoran Plesko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAStringTranslator : NSObject

@property (nonatomic, retain) NSBundle *languageBundle;
@property (nonatomic, retain) NSString *language;

-(NSString *)locStr:(NSString *)input;

@end
