//
//  MALocation.h
//  MuseumApp
//
//  Created by Zoran Plesko on 12/26/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MALocation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;
@property (nonatomic, retain) NSManagedObjectID *objectID;

- (id)initWithName:(NSString*)inname address:(NSString*)inaddress coordinate:(CLLocationCoordinate2D)incoordinate objectId:(NSManagedObjectID *)inobjectID;
- (MKMapItem*)mapItem;


@end
