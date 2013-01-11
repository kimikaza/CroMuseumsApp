//
//  MAMapViewController.h
//  MuseumApp
//
//  Created by Zoran Plesko on 12/26/12.
//  Copyright (c) 2012 Zoran Plesko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MAMapViewController.h"
#import "MAStringTranslator.h"

@protocol MAMapViewControllerDelegate <NSObject>
@required
-(void)dismissModalView:(id)sender;
-(void)dismissModalViewAndPositionTable:(id)sender;
@end

@interface MAMapViewController : UIViewController<MKMapViewDelegate>{
    NSDecimalNumber *minlat;
    NSDecimalNumber *minlong;
    NSDecimalNumber *maxlat;
    NSDecimalNumber *maxlong;
}

@property (nonatomic, strong) id <MAMapViewControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *tData;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MAStringTranslator *st;


-(IBAction)cancelPressed:(id)sender;
-(void)museumOnMapPressed:(id)sender;
-(void)adjustMap;

@end
