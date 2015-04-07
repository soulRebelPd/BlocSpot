//
//  TabBarController.m
//  BlocSpot
//
//  Created by Corey Norford on 4/1/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "TabBarController.h"
#import "PoiDataSource.h"
#import "PoiTableViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
}

@end
