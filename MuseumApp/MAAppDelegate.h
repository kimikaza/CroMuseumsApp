//
//  MAAppDelegate.h
//  MuseumApp
//
//  Created by Zoran Plesko on 12/16/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MAStringTranslator.h"
#import "ReviewRequest.h"

@interface MAAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>{
    NSManagedObjectContext *managedObjectContext;
    ReviewRequest *rr;
}


@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;
@property (nonatomic, retain) MAStringTranslator *st;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)registerDefaultsFromSettingsBundle;


@end
