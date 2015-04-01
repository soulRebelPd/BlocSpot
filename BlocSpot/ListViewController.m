//
//  ListViewController.m
//  BlocSpot
//
//  Created by Corey Norford on 4/1/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "ListViewController.h"
#import "MapItemCell.h"

@interface ListViewController ()

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //Q: why is this nil?
    return self.mapItems.count;
    //return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"MapItemCell";
    
    MapItemCell *cell = (MapItemCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MapItemCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    MKMapItem *myMapItem = self.mapItems[indexPath.row];
    CLLocationDegrees latitudeCoordinate = myMapItem.placemark.coordinate.latitude;
    
    cell.poiName.text = myMapItem.name;
    cell.poiDistance.text = [NSString stringWithFormat:@"%f", latitudeCoordinate];
    cell.poiDescription.text = myMapItem.phoneNumber;
    
    //TODO: populate on future stories
    //cell.poiIcon.image =
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
