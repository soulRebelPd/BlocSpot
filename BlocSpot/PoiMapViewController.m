//
//  PoiMapViewController.m
//  BlocSpot
//
//  Created by Corey Norford on 4/6/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "PoiMapViewController.h"
#import "PoiDataSource.h"
#import "MapItem.h"
#import "CallViewController.h"
#import "RegionMonitor.h"

#define METERS_PER_MILE 3000.0
#define DEFAULT_SEARCH @"Restaurant"

@interface PoiMapViewController ()
@end

@implementation PoiMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }

    self.searchBar.delegate = self;
    self.mapView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    if(![self.searchBar.text isEqualToString: @""]){
        [self search:self.searchBar.text];
    }
    
    [self bindSavedItems];
    
    //TODO: turn this off and see what happens
    //[self zoomToLastLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Map

-(void)startupOperations{
    [self.locationManager startUpdatingLocation];
    
    if(self.mapView.annotations.count < 1){
        [self zoomToLastLocation];
        //[self runDefaultSearch];
        [self bindSavedItems];
        [self monitorSavedItems];
    }
}

-(void)bindSavedItems{
    [[PoiDataSource sharedInstance] fetchSavedItems];
    NSMutableArray *savedItems = [PoiDataSource sharedInstance].savedMapItems;
    
    for(MapItem *item in savedItems){
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
        
        CLLocationDegrees latitudeDegrees = item.latitude;
        CLLocationDegrees longitudeDegrees = item.longitude;
        annotation.coordinate = CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees);
        
        annotation.title = item.locationName;
        annotation.subtitle = @"Saved";
        
        [self.mapView addAnnotation:annotation];
    }
}

-(void)monitorSavedItems{
    [[PoiDataSource sharedInstance] fetchSavedItems];
    NSMutableArray *savedItems = [PoiDataSource sharedInstance].savedMapItems;
    [[RegionMonitor sharedInstance] startMonitoringMapItemsWithMapItems:savedItems];
}

-(void)zoomToLastLocation{
    CLLocation *location = [self getLastLocation];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = location.coordinate.latitude;
    zoomLocation.longitude= location.coordinate.longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE, METERS_PER_MILE);
    
    [self.mapView setRegion:viewRegion animated:YES];
}

-(void)search:(NSString*)text{
    //TODO: add code so only does this if in default location
    //[self zoomToLastLocation];
    
    [[PoiDataSource sharedInstance] requestNewItemsWithText:text withRegion:self.mapView.region completion:^{
        self.mapItems = [PoiDataSource sharedInstance].mapItems;
        
        for (MKMapItem *item in self.mapItems)
        {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
            annotation.coordinate = item.placemark.coordinate;
            annotation.title = item.name;
            
            [self.mapView addAnnotation:annotation];
        }
    }];
}

-(MKPinAnnotationView *)configureSavedPinWithPin:(MKPinAnnotationView *)pin{
    pin.pinColor = MKPinAnnotationColorPurple;
    pin.animatesDrop = NO;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self action:@selector(openDetailCallout:) forControlEvents:UIControlEventTouchUpInside];
    pin.rightCalloutAccessoryView = rightButton;
    
    return pin;
}

-(MKPinAnnotationView *)configureUnSavedPinWithPin:(MKPinAnnotationView *)pin{
    pin.pinColor = MKPinAnnotationColorRed;
    pin.animatesDrop = YES;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self action:@selector(openDetailCallout:) forControlEvents:UIControlEventTouchUpInside];
    pin.rightCalloutAccessoryView = rightButton;
    
    return pin;
}

- (CLLocation *) getLastLocation{
    return self.locationManager.location;
}

-(void)runDefaultSearch{
    self.searchBar.text = DEFAULT_SEARCH;
    [self search:DEFAULT_SEARCH];
}

-(void)openDetailCallout: (UIButton *)sender {
    CallViewController *callViewController = [[CallViewController alloc] init];
    
    MKPointAnnotation *annotation = [self.mapView.selectedAnnotations objectAtIndex:([self.mapView.selectedAnnotations count]-1)];
    MapItem *mapItem = [[PoiDataSource sharedInstance] getMapItemWithLocationName:annotation.title];
    callViewController.mapItem = mapItem;
    
    [self presentViewController:callViewController animated:YES completion:^{
    }];
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation{
    if (annotation == map.userLocation){
        return nil;
    }
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [map dequeueReusableAnnotationViewWithIdentifier: @"Pin"];
    if (pin == nil){
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: @"Pin"];
    }
    else{
        pin.annotation = annotation;
    }
    
    NSString *subTitle = [annotation subtitle];
    if([subTitle isEqualToString:@"Saved"]){
        pin = [self configureSavedPinWithPin:pin];
    }
    else{
        NSString *title = [annotation title];
        bool inSavedItems = [[PoiDataSource sharedInstance] existsInSavedMapItems:title];
        
        if(!inSavedItems){
            pin = [self configureUnSavedPinWithPin:pin];
        }
        else{
            pin = [self configureSavedPinWithPin:pin];
        }
    }

    pin.userInteractionEnabled = YES;
    [pin setEnabled:YES];
    [pin setCanShowCallout:YES];
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
}

#pragma mark - UISearchBarDelegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self search:self.searchBar.text];
    [self bindSavedItems];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.searchBar.showsCancelButton = YES;
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    //[self startupOperations];
    [self zoomToLastLocation];
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
}

@end