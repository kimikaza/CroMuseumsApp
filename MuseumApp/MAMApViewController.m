//
//  MAMapViewController.m
//  MuseumApp
//
//  Created by Zoran Plesko on 12/26/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import "MAMapViewController.h"
#import <MapKit/MapKit.h>
#import "MALocation.h"
#import "MAAnnotationView.h"
#import "MAStringTranslator.h"

@interface MAMapViewController ()

@end

@implementation MAMapViewController

@synthesize delegate, tData, mapView, st;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    for (id<MKAnnotation> annotation in mapView.annotations) {
        [mapView removeAnnotation:annotation];
    }
    minlat = [NSDecimalNumber decimalNumberWithString:@"300.0"];
    minlong = [NSDecimalNumber decimalNumberWithString:@"300.0"];
    maxlat= [NSDecimalNumber decimalNumberWithString:@"0.0"];
    maxlong = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    for(NSManagedObject *museum in tData){
        NSDecimalNumber *latitude = [museum valueForKey:@"latitude"];
        NSDecimalNumber *longitude = [museum valueForKey:@"longitude"];
        if([minlat compare:latitude] == NSOrderedDescending) minlat=latitude;
        if([maxlat compare:latitude] == NSOrderedAscending) maxlat=latitude;
        if([minlong compare:longitude] == NSOrderedDescending) minlong=longitude;
        if([maxlong compare:longitude] == NSOrderedAscending) maxlong=longitude;
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [latitude doubleValue];
        coordinate.longitude = [longitude doubleValue];
        NSString *name = [museum valueForKey:[self.st locStr:@"name_en"]];
        NSLog(@"Stavljam muzej na kartu %@", name);
        NSString *address = [museum valueForKey:@"city"];
        NSManagedObjectID *objectId = [museum objectID];
        MALocation *annotation = [[MALocation alloc] initWithName:name address:address coordinate:coordinate objectId:objectId] ;
        [mapView addAnnotation:annotation];
        
    }
    [self adjustMap];
	// Do any additional setup after loading the view.
}

-(void)adjustMap {
    
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
    
    southWest.latitude = minlat.doubleValue;
    southWest.longitude = minlong.doubleValue;
    northEast.latitude = maxlat.doubleValue;
    northEast.longitude = maxlong.doubleValue;
    
    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:southWest.latitude longitude:southWest.longitude];
    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:northEast.latitude longitude:northEast.longitude];
    
    // This is a diag distance (if you wanted tighter you could do NE-NW or NE-SE)
    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
    
    MKCoordinateRegion region;
    region.center.latitude = (southWest.latitude + northEast.latitude) / 2.0;
    region.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
    region.span.latitudeDelta = meters*2 / 111319.5;
    region.span.longitudeDelta = 0.0;
    
    MKCoordinateRegion savedRegion = [mapView regionThatFits:region];
    [mapView setRegion:savedRegion animated:YES];
}


-(IBAction)cancelPressed:(id)sender{
    [self.delegate dismissModalView:sender];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    NSLog(@"Jel idu te anotacije ba?");
    static NSString *identifier = @"MALocation";
    if ([annotation isKindOfClass:[MALocation class]]) {
        NSLog(@"Evo idu neke sad će");
        MAAnnotationView *annotationView = (MAAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            NSLog(@"Stavljam ih đe su sad?");
            //
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"Pin.png"];//here we use a nice image instead of the default pins
            annotationView.objectID = ((MALocation *)annotation).objectID;
            // Button
            UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            button.frame = CGRectMake(0, 0, 23, 23);
            annotationView.rightCalloutAccessoryView = button;
            [button addTarget:self action:@selector(museumOnMapPressed:) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

-(void)museumOnMapPressed:(id)sender{
    [self.delegate dismissModalViewAndPositionTable:sender];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
