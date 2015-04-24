//
//  AnnotationView.m
//  BlocSpot
//
//  Created by Corey Norford on 4/7/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "CallViewController.h"
#import "PoiDataSource.h"
#import "RegionMonitor.h"

@implementation CallViewController

-(void)viewDidLoad{
    self.note.text = self.mapItem.note;
}

- (IBAction)saveClicked:(id)sender {
    self.mapItem.note = self.note.text;
    
    [[PoiDataSource sharedInstance] persistItemWithItem:self.mapItem];
    [[PoiDataSource sharedInstance] updateExistingMapItem:self.mapItem];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareClicked:(id)sender {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (self.note.text.length > 0) {
        [itemsToShare addObject:self.note.text];
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (IBAction)deleteClicked:(id)sender {
    [[PoiDataSource sharedInstance] deleteItemWithMapItem:self.mapItem];
    [[RegionMonitor sharedInstance] unregisterRegionWithName:self.mapItem.locationName];
}

@end
