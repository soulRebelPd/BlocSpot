//
//  PoiDataSource.m
//  BlocSpot
//
//  Created by Corey Norford on 4/6/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "PoiDataSource.h"
#import "MapItem.h"
#import <CoreLocation/CoreLocation.h>
#import "RegionMonitor.h"

@implementation PoiDataSource

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init{
    self = [super init];
    
    if (self) {
        
        self.savedMapItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Map

- (void)requestNewItemsWithText:(NSString *)text withRegion:(MKCoordinateRegion)region completion:(void (^)(void))completionBlock{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = text;
    request.region = region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        self.mapItems = response.mapItems;
        
        if(response.mapItems != nil && response.mapItems.count > 0){
            completionBlock();
        }
    }];
}

-(void)fetchSavedItems{
    NSString *filePath = [self filePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if ([dictionary objectForKey:@"savedMapItems"] != nil) {
            self.savedMapItems = [[NSMutableArray alloc] initWithArray:[dictionary objectForKey:@"savedMapItems"]];
        }
        else{
            self.savedMapItems = [[NSMutableArray alloc] init];
        }
    }
    else{
        self.savedMapItems = [[NSMutableArray alloc] init];
    }
}

-(void)persistItem:(MKMapItem *)mkMapItem{
    MapItem *mapItem = [[MapItem alloc] init];
    mapItem.locationName = mkMapItem.name;
    mapItem.latitude = mkMapItem.placemark.coordinate.latitude;
    mapItem.longitude = mkMapItem.placemark.coordinate.longitude;
    mapItem.isSavedItem = YES;
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:mkMapItem.placemark.coordinate radius:10];
    [[RegionMonitor sharedInstance] registerRegionWithCircularOverlay:circle andIdentifier:mapItem.locationName];
    
    bool isAlreadySaved = [self existsInSavedMapItems:mapItem.locationName];
    if(!isAlreadySaved){
        [self.savedMapItems addObject:mapItem];
        [self persistNotes];
    }
}

-(void)persistItemWithItem:(MapItem *)mapItem{
    bool isAlreadySaved = [self existsInSavedMapItems:mapItem.locationName];
    if(!isAlreadySaved){
        mapItem.isSavedItem = YES;
        [self.savedMapItems addObject:mapItem];
        [self persistNotes];
    }
}

//NOTE: only used by callout controller, can save every time
-(void)updateExistingMapItem:(MapItem *)mapItem{
    [self persistNotes];
}

-(void)persistNotes{
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    [dataDict setObject:self.savedMapItems forKey:@"savedMapItems"];
    
    NSString *filePath = [self filePath];
    [NSKeyedArchiver archiveRootObject:dataDict toFile:filePath];
}

-(MapItem *)getSavedMapItemWithLocationName:(NSString *)locationName{
    for(MapItem *item in self.savedMapItems){
        if([item.locationName isEqualToString:locationName]){
            return item;
        }
    }
    
    return nil;
}

-(MapItem *)getMapItemWithLocationName:(NSString *)locationName{
    MapItem *mapItem = [[MapItem alloc] init];
    
    for(MKMapItem *item in self.mapItems){
        if([item.name isEqualToString:locationName]){
            mapItem.locationName = item.name;
            mapItem.latitude = item.placemark.coordinate.latitude;
            mapItem.longitude = item.placemark.coordinate.longitude;
            
            return mapItem;
        }
    }
    
    return nil;
}

-(bool)existsInSavedMapItems:(NSString *)locationName{
    for(MapItem *item in self.savedMapItems){
        if([item.locationName isEqualToString:locationName]){
            return true;
        }
    }
    
    return false;
}

-(void)deleteItemWithMapItem:(MapItem *)mapItem{
    [self.savedMapItems removeObject:mapItem];
    [self persistNotes];
}


#pragma mark - Map - Internal Only

-(NSString *)filePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"appData"];
    
    return filePath;
}

@end
