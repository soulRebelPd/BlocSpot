//
//  MapItem.h
//  BlocSpot
//
//  Created by Corey Norford on 4/2/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapItem : NSObject <NSCoding>

@property (strong, nonatomic) NSString *locationName;
@property double latitude;
@property float longitude;
@property bool isSavedItem;

@end
