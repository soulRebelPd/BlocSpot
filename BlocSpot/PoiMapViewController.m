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

#define METERS_PER_MILE 3000.0
#define DEFAULT_SEARCH @"Restaurant"

@interface PoiMapViewController ()
@end

@implementation PoiMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.mapView.delegate = self;
    
    if(self.mapView.annotations.count < 1){
        [self zoomToLastLocation];
        [self runDefaultSearch];
        [self bindSavedItems];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if(self.mapItemToShow!= nil){
    }
    else{
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    //pin.image=[UIImage imageNamed:@"whatever.png"];
    pin.userInteractionEnabled = YES;
    [pin setEnabled:YES];
    [pin setCanShowCallout:YES];
    
    return pin;
}

-(void)openDetailCallout: (UIButton *)sender {
    CallViewController *callViewController = [[CallViewController alloc] init];
    
    MKPointAnnotation *annotation = [self.mapView.selectedAnnotations objectAtIndex:([self.mapView.selectedAnnotations count]-1)];
    MapItem *mapItem = [[PoiDataSource sharedInstance] getMapItemWithLocationName:annotation.title];
    callViewController.mapItem = mapItem;

    [self presentViewController:callViewController animated:YES completion:^{
    }];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
}

#pragma mark - Map

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

-(void)zoomToLastLocation{
    CLLocation *location = [PoiDataSource sharedInstance].getLastLocation;
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = location.coordinate.latitude;
    zoomLocation.longitude= location.coordinate.longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE, METERS_PER_MILE);
    
    [self.mapView setRegion:viewRegion animated:YES];
}

-(void)search:(NSString*)text{
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
    
    return pin;
}

#pragma mark - Search

-(void)runDefaultSearch{
    self.searchBar.text = DEFAULT_SEARCH;
    [self search:DEFAULT_SEARCH];
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


@end