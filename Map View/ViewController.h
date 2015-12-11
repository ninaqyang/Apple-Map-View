//
//  ViewController.h
//  Map View
//
//  Created by Nina Yang on 9/8/15.
//  Copyright (c) 2015 Nina Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyAnnotation.h"
#import "WebViewController.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, MKAnnotation, UISearchBarDelegate, UISearchDisplayDelegate> {
    CLLocationManager *locationManager;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MyAnnotation *myAnnotation;
@property (nonatomic, retain) WebViewController *webViewController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

-(IBAction)setMap:(id)sender;

-(void)zoomToFitMapAnnotations:(MKMapView *)mapView;
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

@end

