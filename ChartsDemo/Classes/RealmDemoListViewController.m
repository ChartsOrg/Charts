//
//  RealmDemoListViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "RealmDemoListViewController.h"
#import "RealmLineChartViewController.h"
#import "RealmBarChartViewController.h"
#import "RealmHorizontalBarChartViewController.h"
#import "RealmScatterChartViewController.h"
#import "RealmCandleChartViewController.h"
#import "RealmBubbleChartViewController.h"
#import "RealmPieChartViewController.h"
#import "RealmRadarChartViewController.h"
#import "RealmWikiExampleChartViewController.h"

@interface RealmDemoListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *itemDefs;
@end

@implementation RealmDemoListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Charts Demonstration";

    self.itemDefs = @[
                      @{
                          @"title": @"Realm.io database Line Chart",
                          @"subtitle": @"This demonstrates how to use this library with Realm.io mobile database.",
                          @"class": RealmLineChartViewController.class
                          },
                      @{
                          @"title": @"Realm.io database Bar Chart",
                          @"subtitle": @"This demonstrates how to use this library with Realm.io mobile database.",
                          @"class": RealmBarChartViewController.class
                          },
                      @{
                          @"title": @"Realm.io database Horizontal Bar Chart",
                          @"subtitle": @"This demonstrates how to use this library with Realm.io mobile database.",
                          @"class": RealmHorizontalBarChartViewController.class
                          },
                      @{
                          @"title": @"Realm.io database Scatter Chart",
                          @"subtitle": @"This demonstrates how to use this library with Realm.io mobile database.",
                          @"class": RealmScatterChartViewController.class
                          },
                      @{
                          @"title": @"Realm.io database CandleStick Chart",
                          @"subtitle": @"This demonstrates how to use this library with Realm.io mobile database.",
                          @"class": RealmCandleChartViewController.class
                          },
                      @{
                          @"title": @"Realm.io database Bubble Chart",
                          @"subtitle": @"This demonstrates how to use this library with Realm.io mobile database.",
                          @"class": RealmBubbleChartViewController.class
                          },
                      @{
                          @"title": @"Realm.io database Pie Chart",
                          @"subtitle": @"This demonstrates how to use this library with Realm.io mobile database.",
                          @"class": RealmPieChartViewController.class
                          },
                      @{
                          @"title": @"Realm.io database Radar Chart",
                          @"subtitle": @"This demonstrates how to use this library with Realm.io mobile database.",
                          @"class": RealmRadarChartViewController.class
                          },
                      @{
                          @"title": @"Realm.io Wiki",
                          @"subtitle": @"This is the code related to the entry about realm.io in the Wiki.",
                          @"class": RealmWikiExampleChartViewController.class
                          },
                      ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemDefs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *def = self.itemDefs[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = def[@"title"];
    cell.detailTextLabel.text = def[@"subtitle"];
    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *def = self.itemDefs[indexPath.row];
    
    Class vcClass = def[@"class"];
    UIViewController *vc = [[vcClass alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
