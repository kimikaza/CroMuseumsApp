//
//  MAStringTranslator.m
//  MuseumApp
//
//  Created by Zoran Plesko on 1/9/13.
//  Copyright (c) 2013 Zoran Plesko. All rights reserved.
//

#import "MAStringTranslator.h"

@implementation MAStringTranslator

@synthesize languageBundle;
@synthesize language;

-(NSString *)locStr:(NSString *)input{
    return [languageBundle localizedStringForKey:input value:input table:nil];
}


@end
