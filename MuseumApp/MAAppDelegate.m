//
//  MAAppDelegate.m
//  MuseumApp
//
//  Created by Zoran Plesko on 12/16/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import "MAAppDelegate.h"
#import "MAViewController.h"
#import "MAStarLoader.h"
#import "MAStringTranslator.h"

@implementation MAAppDelegate

@synthesize window = _window;

@synthesize managedObjectContext;// = __managedObjectContext;
@synthesize managedObjectModel;// = __managedObjectModel;
@synthesize persistentStoreCoordinator;// = __persistentStoreCoordinator;
@synthesize st;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.startLocation = nil;
    self.st = [[MAStringTranslator alloc] init];
    NSString *lang=[[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"iPhone language is: %@ ", lang);
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *applang = [settings stringForKey:@"AppLang"];
    if(applang==nil){
        [self registerDefaultsFromSettingsBundle];
        settings = [NSUserDefaults standardUserDefaults];
        applang = [settings stringForKey:@"AppLang"];
    }
    NSLog(@"Applanguage is %@", applang);
    if([applang hasPrefix:@"Automatic"]){
        if([lang hasPrefix:@"de"] || [lang hasPrefix:@"hr"]){
            NSString *path = [[NSBundle mainBundle] pathForResource:lang ofType:@"lproj"];
            NSBundle* languageBundle = [NSBundle bundleWithPath:path];
            [self.st setLanguageBundle:languageBundle];
            [self.st setLanguage:lang];
        }else{
            lang=@"en";
            NSString *path = [[NSBundle mainBundle] pathForResource:lang ofType:@"lproj"];
            NSBundle* languageBundle = [NSBundle bundleWithPath:path];
            [self.st setLanguageBundle:languageBundle];
            [self.st setLanguage:lang];
        }
    }else{
        NSString *path = [[NSBundle mainBundle] pathForResource:applang ofType:@"lproj"];
        NSBundle* languageBundle = [NSBundle bundleWithPath:path];
        [self.st setLanguageBundle:languageBundle];
        [self.st setLanguage:applang];
    }
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:st.languageBundle];
    MAStarLoader *sl = [[MAStarLoader alloc] init];
    MAViewController *lvc = (MAViewController *)self.window.rootViewController;//[storyboard instantiateInitialViewController];
    //[self.window setRootViewController:lvc];
    lvc.sl = sl;
    lvc.st = self.st;
    sl.delegate = lvc;
    lvc.managedObjectContext=self.managedObjectContext;
    lvc.locationManager = self.locationManager;
    self.startLocation=[self.locationManager location];
    lvc.currentLocation = self.startLocation;
    // Override point for customization after application launch.
    return YES;
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContextX = self.managedObjectContext;
    if (managedObjectContextX != nil) {
        if ([managedObjectContextX hasChanges] && ![managedObjectContextX save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MuseumsApp" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MuseumApp.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]] ) {
        // If there’s no Data Store present (which is the case when the app first launches), identify the sqlite file we added in the Bundle Resources, copy it into the Documents directory, and make it the Data Store.
        NSString *sqlitePath = [[NSBundle mainBundle] pathForResource:@"MuseumApp" ofType:@"sqlite" inDirectory:nil];
        NSError *anyError = nil;
        BOOL success = [[NSFileManager defaultManager]
                        copyItemAtPath:sqlitePath toPath:[storeURL path] error:&anyError];
    }
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
        if (self.startLocation == nil)
        self.startLocation = newLocation;
}


@end
