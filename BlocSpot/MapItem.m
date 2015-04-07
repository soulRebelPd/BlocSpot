//
//  MapItem.m
//  BlocSpot
//
//  Created by Corey Norford on 4/2/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "MapItem.h"

@implementation MapItem

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.locationName forKey:@"locationName"];
    [coder encodeBool:self.isSavedItem forKey:@"isSavedItem"];
    [coder encodeDouble:self.latitude forKey:@"latitude"];
    [coder encodeDouble:self.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    
    self.locationName = [coder decodeObjectForKey:@"locationName"];
    self.isSavedItem = [coder decodeBoolForKey:@"isSavedItem"];
    self.latitude = [coder decodeDoubleForKey:@"latitude"];
    self.longitude = [coder decodeDoubleForKey:@"longitude"];
    
    return self;
}

@end
