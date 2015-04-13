//
//  PoiDataSource.h
//  BlocSpot
//
//  Created by Corey Norford on 4/6/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MapItem.h"

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface PoiDataSource : NSObject 

-(instancetype) init;
-(void)requestNewItemsWithText:(NSString *)text withRegion:(MKCoordinateRegion)region completion:(void (^)(void))completionBlock;
-(void)persistItem:(MKMapItem *)mkMapItem;
-(void)fetchSavedItems;
-(bool)existsInSavedMapItems:(NSString *)locationName;
-(MapItem *)getSavedMapItemWithLocationName:(NSString *)locationName;
-(void)updateExistingMapItem:(MapItem *)mapItem;
-(void)deleteItemWithMapItem:(MapItem *)mapItem;
-(void)persistItemWithItem:(MapItem *)mapItem;
-(MapItem *)getMapItemWithLocationName:(NSString *)locationName;

+ (instancetype) sharedInstance;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *mapItems;
@property (strong, nonatomic) NSMutableArray *savedMapItems;

@end