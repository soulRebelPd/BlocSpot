//
//  TabBarController.m
//  BlocSpot
//
//  Created by Corey Norford on 4/1/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "TabBarController.h"
#import "DataSource.h"
#import "ListViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSArray *mapItems = [DataSource sharedInstance].mapItems;

    ListViewController *listViewController = viewController;
    [listViewController setMapItems: mapItems];
    
}

/*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
