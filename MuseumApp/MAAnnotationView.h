//
//  MAAnnotationView.h
//  MuseumApp
//
//  Created by Zoran Plesko on 12/27/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MAAnnotationView : MKAnnotationView

@property (nonatomic, retain) NSManagedObjectID *objectID;

@end
