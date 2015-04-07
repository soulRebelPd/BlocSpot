//
//  MapViewController.m
//  BlocSpot
//
//  Created by Corey Norford on 3/30/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "MapViewController.h"
#import "DataSource.h"

#define METERS_PER_MILE 3000.0
#define DEFAULT_SEARCH @"Restaurant"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    CLLocation *location = [DataSource sharedInstance].getLastLocation;

    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = location.coordinate.latitude;
    zoomLocation.longitude= location.coordinate.longitude;
    
    //Q: use this METERS_PER_MILE variable?
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE, METERS_PER_MILE);
    
    [_mapView setRegion:viewRegion animated:YES];
    [self search:DEFAULT_SEARCH];
}

-(void)search:(NSString*)text{
    [[DataSource sharedInstance] requestNewItemsWithText:text withRegion:self.mapView.region completion:^{
        self.mapItems = [DataSource sharedInstance].mapItems;
        
        for (MKMapItem *item in self.mapItems)
        {
            //[_matchingItems addObject:item];
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
            annotation.coordinate = item.placemark.coordinate;
            annotation.title = item.name;
            [self.mapView addAnnotation:annotation];
        }
        
        [self.searchBar resignFirstResponder];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self search:self.searchBar.text];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

@end
