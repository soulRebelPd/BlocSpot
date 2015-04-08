//
//  AnnotationView.m
//  BlocSpot
//
//  Created by Corey Norford on 4/7/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "CallViewController.h"
#import "PoiDataSource.h"

@implementation CallViewController

-(void)viewDidLoad{
    self.note.text = self.mapItem.note;
}

- (IBAction)saveClicked:(id)sender {
    self.mapItem.note = self.note.text;
    
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
