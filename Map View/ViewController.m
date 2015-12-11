//
//  ViewController.m
//  Map View
//
//  Created by Nina Yang on 9/8/15.
//  Copyright (c) 2015 Nina Yang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () 

@end

@implementation ViewController {
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}

#pragma mark - Nib

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    locationManager = [[CLLocationManager alloc]init];
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    
    return self;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.searchBar.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    CLLocationCoordinate2D turnToTechLocation = CLLocationCoordinate2DMake(40.7413597, -73.98967470000002);
    MyAnnotation *turnToTechAnnotation = [[MyAnnotation alloc]initWithTitle:@"Turn to Tech" location:turnToTechLocation andURL:@"http://turntotech.io/"];
    [self.mapView addAnnotation:turnToTechAnnotation];
    
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Control Segment

-(IBAction)setMap:(id)sender {
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            break;
    }
}

#pragma mark - Map Annotations

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"Location, %f, %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
}

-(void)zoomToFitMapAnnotations:(MKMapView *)mapView {
    if ([mapView.annotations count] == 0) {
        return;
    }
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for (MKPointAnnotation *annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.5;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.5;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
    
}

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    if ([mapView.annotations count] == 1) {
        [self zoomToFitMapAnnotations:self.mapView];
    }
    
    NSLog(@"mapViewDidFinishRenderingMap");
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *av = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
    av.enabled = YES;
    av.canShowCallout = YES;
    av.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    UIImage *img = [UIImage imageNamed:@"map_pin"];
    UIImageView *imgView = [[UIImageView alloc]initWithImage:img];
    av.leftCalloutAccessoryView = imgView;
    
    if ([av.annotation.title isEqualToString:@"Turn to Tech"]) {
        av.animatesDrop = NO;
    }
    else {
        av.animatesDrop = YES;
    }
    
    return av;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"calloutAccessoryControlTapped: annotation = %@", view.annotation);
    
    self.webViewController = [[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil];
    MyAnnotation *object = view.annotation;
    self.webViewController.url = [NSURL URLWithString:object.urlString];
    NSLog(@"%@", object.urlString);
    [self.navigationController pushViewController:self.webViewController animated:YES];
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    NSLog(@"Annotation added!");
}

#pragma mark - Search Bar

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [localSearch cancel];
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.mapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    localSearch = [[MKLocalSearch alloc]initWithRequest:request];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        results = response;
        
        for (MKMapItem *item in results.mapItems) {
            NSLog(@"%@", item.name);
            [self.mapView addAnnotation:[[MyAnnotation alloc]initWithTitle:item.name location:item.placemark.coordinate andURL:[item.url absoluteString]]];
            [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
        }
        if (error != nil) {
            [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Map Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"Error", nil) otherButtonTitles:nil]show];
            return;
        }
        if (response == nil) {
            [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"No Results", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil]show];
            return;
        }
    }];
    
    [self.mapView reloadInputViews];
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}

@end
