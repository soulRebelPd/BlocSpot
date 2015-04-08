//
//  PoiTableViewController.m
//  BlocSpot
//
//  Created by Corey Norford on 4/6/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "PoiTableViewController.h"
#import "MapItemCell.h"
#import "PoiDataSource.h"
#import "MapItem.h"
#import "PoiMapViewController.h"

@interface PoiTableViewController ()

@end

@implementation PoiTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated{
    NSArray *mapItems = [PoiDataSource sharedInstance].mapItems;
    [self setMapItems: mapItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MapItemCell *cell = (MapItemCell *)[tableView dequeueReusableCellWithIdentifier:@"MapItemCell"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MapItemCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    MKMapItem *mapItem = self.mapItems[indexPath.row];
    cell.poiName.text = mapItem.name;
    CLLocationDegrees latitudeCoordinate = mapItem.placemark.coordinate.latitude;
    cell.poiDistance.text = [NSString stringWithFormat:@"%f", latitudeCoordinate];
    cell.poiDescription.text = mapItem.phoneNumber;
    
    bool isSavedItem = [[PoiDataSource sharedInstance] existsInSavedMapItems:cell.poiName.text];
    if(isSavedItem){
        cell.poiName.textColor = [UIColor purpleColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        cell.poiName.textColor = [UIColor redColor];
    }
    
    return cell;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Save" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        MKMapItem *itemToSave = [self.mapItems objectAtIndex:indexPath.row];
                                        [[PoiDataSource sharedInstance] persistItem:itemToSave];
                                        [tableView reloadData];
                                    }];
    
    button.backgroundColor = [UIColor purpleColor];
    tableView.editing = NO;
    
    return @[button];
    
    //NOTE: can add multiple buttons
    //return @[button, button2];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    MKMapItem *mapItem = self.mapItems[indexPath.row];
    bool isSavedItem = [[PoiDataSource sharedInstance] existsInSavedMapItems:mapItem.name];
    
    if(isSavedItem){
        return NO;
    }
    else{
        return YES;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mapItems.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MapItemCell *cell = self.tableView.visibleCells[indexPath.row];
    
    if(cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator){
        MapItem *mapItem = self.mapItems[indexPath.row];
        PoiMapViewController *controller = self.tabBarController.childViewControllers[0];
        controller.mapItemToShow = mapItem;
        self.tabBarController.selectedIndex = 0;
        
        //segue to PoiMapViewController passing in mapItem
    }
}

@end
