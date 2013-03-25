//
//  MALocationManager.m
//  OrderUp
//
//  Created by Ivana Rast on 2/12/13.
//  Copyright (c) 2013 masinerija. All rights reserved.
//

#import "MALocationManager.h"
#import <CoreLocation/CoreLocation.h>

@implementation MALocationManager

@synthesize delegate, locationManager, desiredAccuracy;

-(void) getLocation{
    
    NSLog(@"getLocation()");
    
    //dispatch_async(kBgQueue, ^{
        
        self.locationManager = [[CLLocationManager alloc] init];
        locationMeasurements = [[NSMutableArray alloc] init];
        bestEffortAtLocation = nil;
        locationManager.delegate = self;
        locationManager.desiredAccuracy = self.desiredAccuracy;//kCLLocationAccuracyHundredMeters;
        [locationManager startUpdatingLocation];
        [self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:locationUpdateDelay];
    //});
    
}

-(void)stopUpdatingLocation:(NSString *)state{
    
    NSLog(@"stopUpdatingLocation()");
    
    [locationManager stopUpdatingLocation];
    
    if([state isEqualToString:@"Timed Out"]){
        NSLog(@"getLocation() : Timed Out");
        [self.delegate refreshLocation:nil];
    }else if([state isEqualToString:@"Acquired"]){
        NSLog(@"getLocation() : Acquired");
        NSLog(@"getLocation() : bestEffortAtLocation = %@", bestEffortAtLocation);
        [self.delegate refreshLocation:bestEffortAtLocation];
    }
    
    // ovo radimo da se moze napraviti release. 
    //locationManager.delegate = nil;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"got new location %@", newLocation);
    // store all of the measurements, just so we can see what kind of data we might receive
    [locationMeasurements addObject:newLocation];
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        bestEffortAtLocation = newLocation;
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            //
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            [self stopUpdatingLocation:@"Acquired"];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:@"Timed Out"];
        }
    }
}

@end
