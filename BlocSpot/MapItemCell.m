//
//  MapItemCell.m
//  BlocSpot
//
//  Created by Corey Norford on 4/1/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "MapItemCell.h"

@implementation MapItemCell

@synthesize poiName = _poiName;
@synthesize poiDescription = _poiDescription;
@synthesize poiDistance = _poiDistance;
@synthesize poiIcon = _poiIcon;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
