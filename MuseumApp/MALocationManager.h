//
//  MALocationManager.h
//  OrderUp
//
//  Created by Ivana Rast on 2/12/13.
//  Copyright (c) 2013 masinerija. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol MALocationManagerDelegate <NSObject>

@required
-(void)refreshLocation:(CLLocation *) newLocation;
@end

@interface MALocationManager : NSObject <CLLocationManagerDelegate>{
    NSMutableArray *locationMeasurements;
    CLLocation *bestEffortAtLocation;
}

@property(nonatomic, retain) id<MALocationManagerDelegate> delegate;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) double desiredAccuracy;

-(void)stopUpdatingLocation:(NSString *) state;
-(void)getLocation;

@end
