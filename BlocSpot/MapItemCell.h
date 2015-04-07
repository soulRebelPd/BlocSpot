//
//  PoiTableViewCell.h
//  BlocSpot
//
//  Created by Corey Norford on 4/1/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *poiName;
@property (nonatomic, weak) IBOutlet UILabel *poiDescription;
@property (nonatomic, weak) IBOutlet UILabel *poiDistance;
@property (nonatomic, weak) IBOutlet UIImageView *poiIcon;

@end
