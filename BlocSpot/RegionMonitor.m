//
//  RegionMonitor.m
//  BlocSpot
//
//  Created by Corey Norford on 4/10/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "RegionMonitor.h"
#import "MapItem.h"

#pragma mark - Setup

@implementation RegionMonitor

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
        
        if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]])
        {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            
            if(status == kCLAuthorizationStatusAuthorizedAlways){
                [self.locationManager startUpdatingLocation];
            }
            else{
                NSLog(@"Couldn't start region monitoring, invalid authorization status");
            }
        }
        else{
            NSLog(@"Couldn't start region monitoring, unavailable for class");
        }
    }
    
    return self;
}

#pragma mark - Location Monitoring

-(void)startMonitoringMapItemsWithMapItems:(NSArray *)mapItems{
    for(MapItem *mapItem in mapItems){
        CLLocationDegrees latitudeDegrees = mapItem.latitude;
        CLLocationDegrees longitudeDegrees = mapItem.longitude;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees);
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:1];
        
        [self registerRegionWithCircularOverlay:circle andIdentifier:mapItem.locationName];
    }
}

-(void)registerRegionWithCircularOverlay:(MKCircle*)overlay andIdentifier:(NSString*)identifier{
    CLLocationDistance radius = overlay.radius;
    
    if (radius > self.locationManager.maximumRegionMonitoringDistance) {
        radius = self.locationManager.maximumRegionMonitoringDistance;
    }

    CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
                                   initWithCenter:overlay.coordinate
                                   radius:radius
                                   identifier:identifier];
    
    geoRegion.notifyOnEntry = YES;
    geoRegion.notifyOnExit = YES;
    
    [self.locationManager startMonitoringForRegion:geoRegion];
    [self.locationManager requestStateForRegion:geoRegion];
}

-(void)unregisterRegionWithName:(NSString *)name{
    CLCircularRegion *regionToRemove;
    
    for(CLRegion *region in self.locationManager.monitoredRegions){
        if([region.identifier isEqualToString:name]){
            regionToRemove = (CLCircularRegion *)region;
            break;
        }
    }
    
    [self.locationManager stopMonitoringForRegion:regionToRemove];
}

+(void)sendEnterNotificationWithRegionName: (NSString *)regionName{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSDate *now = [NSDate date];
    NSDate *dateToFire = [now dateByAddingTimeInterval:5];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = dateToFire;
    notification.timeZone = [NSTimeZone systemTimeZone];
    notification.alertTitle = [NSString stringWithFormat:@"%@?", regionName];
    notification.alertBody = [NSString stringWithFormat:@"One of your saved spots, %@ is close by :)", regionName];
    notification.soundName = nil;
    //notification.applicationIconBadgeNumber = 0;
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSLog(@"%@",[DateFormatter stringFromDate:dateToFire]);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+(void)sendExitNotificationWithRegionName: (NSString *)regionName{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSDate *now = [NSDate date];
    NSDate *dateToFire = [now dateByAddingTimeInterval:5];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = dateToFire;
    notification.timeZone = [NSTimeZone systemTimeZone];
    notification.alertTitle = [NSString stringWithFormat:@"%@?", regionName];
    notification.alertBody = [NSString stringWithFormat:@"Say goodbye to %@  :(", regionName];
    notification.soundName = nil;
    //notification.applicationIconBadgeNumber = 0;
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSLog(@"%@",[DateFormatter stringFromDate:dateToFire]);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    [RegionMonitor sendExitNotificationWithRegionName:region.identifier];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    [RegionMonitor sendEnterNotificationWithRegionName:region.identifier];
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    NSString *stateName = [[NSString alloc] init];
    if(state == CLRegionStateInside){
        stateName = @"CLRegionStateInside";
    }
    else if(state == CLRegionStateOutside){
        stateName = @"CLRegionStateOutside";
    }
    else{
        stateName = @"Unknown";
    }
    
    NSLog(@"%@ region state is %@", region.identifier, stateName);
}

@end
