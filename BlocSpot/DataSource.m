//
//  DataSource.m
//  BlocSpot
//
//  Created by Corey Norford on 3/31/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "DataSource.h"

@implementation DataSource

#pragma mark - Setup

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
    }
    
    return self;
}

#pragma mark - Map

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
}

- (CLLocation *) getLastLocation{
    return self.locationManager.location;
}

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

@end
