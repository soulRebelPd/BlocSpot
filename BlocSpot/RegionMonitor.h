//
//  RegionMonitor.h
//  BlocSpot
//
//  Created by Corey Norford on 4/10/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RegionMonitor : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

-(instancetype)init;
-(void)registerRegionWithCircularOverlay:(MKCircle*)overlay andIdentifier:(NSString*)identifier;
-(void)startMonitoringMapItemsWithMapItems:(NSArray *)mapItems;
-(void)unregisterRegionWithName:(NSString *)name;

+(instancetype) sharedInstance;
+(void)sendExitNotificationWithRegionName: (NSString *)regionName;
+(void)sendEnterNotificationWithRegionName: (NSString *)regionName;

@end
