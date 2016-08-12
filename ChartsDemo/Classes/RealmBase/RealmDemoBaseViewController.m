//
//  RealmDemoBaseViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "RealmDemoBaseViewController.h"
#import <Realm/Realm.h>
#import "RealmDemoData.h"

@interface RealmDemoBaseViewController ()

@end

@implementation RealmDemoBaseViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSURL *defaultRealmPath = [RLMRealmConfiguration defaultConfiguration].fileURL;
    [[NSFileManager defaultManager] removeItemAtURL:defaultRealmPath error:nil];
}

static float randomFloatBetween(float from, float to)
{
    return from + ((float)rand()/(float)RAND_MAX) * (to - from);
}

- (void)writeRandomDataToDbWithObjectCount:(NSInteger)objectCount
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    [realm deleteObjects:RealmDemoData.allObjects];
    
    for (int i = 0; i < objectCount; i++)
    {
        RealmDemoData *d = [[RealmDemoData alloc] initWithXValue:i yValue:randomFloatBetween(40.f, 100.f)];
        [realm addObject:d];
    }
    
    [realm commitWriteTransaction];
}

- (void)writeRandomStackedDataToDbWithObjectCount:(NSInteger)objectCount
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    [realm deleteObjects:RealmDemoData.allObjects];
    
    for (int i = 0; i < objectCount; i++)
    {
        float val1 = randomFloatBetween(34.f, 46.f);
        float val2 = randomFloatBetween(34.f, 46.f);
        
        NSArray<NSNumber *> *stack = @[@(val1), @(val2), @(100.f - val1 - val2)];
        
        RealmDemoData *d = [[RealmDemoData alloc] initWithXValue:i stackValues:stack];
        [realm addObject:d];
    }
    
    [realm commitWriteTransaction];
}

- (void)writeRandomCandleDataToDbWithObjectCount:(NSInteger)objectCount
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    [realm deleteObjects:RealmDemoData.allObjects];
    
    for (int i = 0; i < objectCount; i++)
    {
        float mult = 50;
        float val = randomFloatBetween(mult, mult + 40);
        
        float high = randomFloatBetween(8, 17);
        float low = randomFloatBetween(8, 17);
        
        float open = randomFloatBetween(1, 7);
        float close = randomFloatBetween(1, 7);
        
        BOOL even = i % 2 == 0;
        
        RealmDemoData *d = [[RealmDemoData alloc] initWithXValue:i
                                                            high:val + high
                                                             low:val - low
                                                            open:even ? val + open : val - open
                                                           close:even ? val - close : val + close];
        
        [realm addObject:d];
    }
    
    [realm commitWriteTransaction];
}

- (void)writeRandomBubbleDataToDbWithObjectCount:(NSInteger)objectCount
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    [realm deleteObjects:RealmDemoData.allObjects];
    
    for (int i = 0; i < objectCount; i++)
    {
        RealmDemoData *d = [[RealmDemoData alloc] initWithXValue:i
                                                          yValue:randomFloatBetween(30.f, 130.f)
                                                      bubbleSize:randomFloatBetween(15.f, 35.f)];
        [realm addObject:d];
    }
    
    [realm commitWriteTransaction];
}

- (void)writeRandomPieDataToDb
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    [realm deleteObjects:RealmDemoData.allObjects];
    
    float value1 = randomFloatBetween(15.f, 23.f);
    float value2 = randomFloatBetween(15.f, 23.f);
    float value3 = randomFloatBetween(15.f, 23.f);
    float value4 = randomFloatBetween(15.f, 23.f);
    float value5 = 100.f - value1 - value2 - value3 - value4;
    
    NSArray<NSNumber *> *values = @[
                                    @(value1), @(value2), @(value3), @(value4),
                                    @(value5)
                                    ];
    NSArray<NSString *> *xValues = @[
                                     @"iOS",
                                     @"Android",
                                     @"WP 10",
                                     @"BlackBerry",
                                     @"Other"
                                     ];
    
    for (int i = 0; i < values.count; i++)
    {
        RealmDemoData *d = [[RealmDemoData alloc] initWithYValue:randomFloatBetween(values[i].floatValue, 23.f)
                                                           label:xValues[i]];
        [realm addObject:d];
    }
    
    [realm commitWriteTransaction];
}

- (void)setupBarLineChartView:(BarLineChartViewBase *)chartView
{
    [super setupBarLineChartView:chartView];
    
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    percentFormatter.positiveSuffix = @"%";
    percentFormatter.negativeSuffix = @"%";
    
    ChartYAxis *leftAxis = chartView.leftAxis;
    leftAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:8.f];
    leftAxis.labelTextColor = UIColor.darkGrayColor;
    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:percentFormatter];
}

- (void)styleData:(ChartData *)data
{
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    percentFormatter.positiveSuffix = @"%";
    percentFormatter.negativeSuffix = @"%";
    
    data.valueFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:8.f];
    data.valueTextColor = UIColor.darkGrayColor;
    data.valueFormatter = [[ChartDefaultValueFormatter alloc] initWithFormatter:percentFormatter];
}

@end
