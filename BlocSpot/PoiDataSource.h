//
//  PoiDataSource.h
//  BlocSpot
//
//  Created by Corey Norford on 4/6/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface PoiDataSource : NSObject <CLLocationManagerDelegate>

-(instancetype) init;
-(void)requestNewItemsWithText:(NSString *)text withRegion:(MKCoordinateRegion)region completion:(void (^)(void))completionBlock;
-(CLLocation *) getLastLocation;
-(void)persistItem:(MKMapItem *)mkMapItem;
-(void)fetchSavedItems;
-(bool)existsInSavedMapItems:(NSString *)locationName;

+ (instancetype) sharedInstance;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *mapItems;
@property (strong, nonatomic) NSMutableArray *savedMapItems;

@end