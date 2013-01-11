//
//  MALocation.m
//  MuseumApp
//
//  Created by Zoran Plesko on 12/26/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import "MALocation.h"
#import <AddressBook/AddressBook.h>

@implementation MALocation

@synthesize name, address, coordinate, objectID;

- (id)initWithName:(NSString*)inname address:(NSString*)inaddress coordinate:(CLLocationCoordinate2D)incoordinate objectId:(NSManagedObjectID *)inobjectID{
    if ((self = [super init])) {
        if ([inname isKindOfClass:[NSString class]]) {
            self.name = inname;
        } else {
            self.name = @"Unknown charge";
        }
        self.address = inaddress;
        self.theCoordinate = incoordinate;
        self.objectID = inobjectID;
    }
    return self;
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return self.address;
}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : self.address};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end
