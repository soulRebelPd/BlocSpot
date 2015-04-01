//
//  DataSource.h
//  BlocSpot
//
//  Created by Corey Norford on 3/31/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject <CLLocationManagerDelegate>

+ (instancetype) sharedInstance;

- (instancetype) init;
//Q: proper structure of method text?
- (void)requestNewItemsWithText:(NSString *)text withRegion:(MKCoordinateRegion)region completion:(void (^)(void))completionBlock;
- (CLLocation *) getLastLocation;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *mapItems;

@end
