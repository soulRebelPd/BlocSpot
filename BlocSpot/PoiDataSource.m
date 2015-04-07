//
//  PoiDataSource.m
//  BlocSpot
//
//  Created by Corey Norford on 4/6/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "PoiDataSource.h"
#import "MapItem.h"

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
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        [self.locationManager startUpdatingLocation];
        
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
    
    bool isAlreadySaved = [self existsInSavedMapItems:mapItem.locationName];
    if(!isAlreadySaved){
        [self.savedMapItems addObject:mapItem];
        
        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] initWithCapacity:1];
        [dataDict setObject:self.savedMapItems forKey:@"savedMapItems"];
        
        NSString *filePath = [self filePath];
        [NSKeyedArchiver archiveRootObject:dataDict toFile:filePath];
    }
}

- (CLLocation *) getLastLocation{
    return self.locationManager.location;
}

-(bool)existsInSavedMapItems:(NSString *)locationName{
    for(MapItem *item in self.savedMapItems){
        if([item.locationName isEqualToString:locationName]){
            return true;
        }
    }
    
    return false;
}

#pragma mark - Map - Internal Only

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
}

-(NSString *)filePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"appData"];
    
    return filePath;
}

@end
