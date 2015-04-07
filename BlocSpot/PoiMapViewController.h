//
//  PoiMapViewController.h
//  BlocSpot
//
//  Created by Corey Norford on 4/6/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PoiMapViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak,nonatomic) NSArray *mapItems;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end