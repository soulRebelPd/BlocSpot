//
//  AnnotationView.h
//  BlocSpot
//
//  Created by Corey Norford on 4/7/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapItem.h"

@interface CallViewController : UIViewController

@property (nonatomic, strong) MapItem *mapItem;

@property (weak, nonatomic) IBOutlet UITextView *note;

- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)shareClicked:(id)sender;

@end
