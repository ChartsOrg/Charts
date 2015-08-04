//
//  GroupedCombinedChartViewController.m
//  ChartsDemo
//
//  Created by Xuan on 8/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

#import "GroupedCombinedChartViewController.h"
#import "ChartsDemo-Swift.h"

#define ITEM_COUNT 12

@interface GroupedCombinedChartViewController ()

@end

@implementation GroupedCombinedChartViewController

// used by lazy nib initializer for subclasses
-(NSString *)nibName {
    return @"CombinedChartViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (LineChartData *)generateLineData
{
    LineChartData *d = [[LineChartData alloc] init];
    
    NSArray *colors = @[ChartColorTemplates.vordiplom[0], ChartColorTemplates.vordiplom[1], ChartColorTemplates.vordiplom[2]];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    
    for (int z = 0; z < 3; z++)
    {
        NSMutableArray *values = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < ITEM_COUNT; i++)
        {
            double val = (double) (arc4random_uniform(25) + i);
            [values addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
        }
        
        LineChartDataSet *d = [[LineChartDataSet alloc] initWithYVals:values label:[NSString stringWithFormat:@"DataSet %d", z + 1]];
        d.lineWidth = 2.5;
        d.circleRadius = 4.0;
        
        UIColor *color = colors[z % colors.count];
        [d setColor:color];
        [d setCircleColor:color];
        [dataSets addObject:d];
    }
    
    ((LineChartDataSet *)dataSets[0]).lineDashLengths = @[@5.f, @5.f];
    ((LineChartDataSet *)dataSets[0]).colors = ChartColorTemplates.vordiplom;
    ((LineChartDataSet *)dataSets[0]).circleColors = ChartColorTemplates.vordiplom;
    [d addDataSet:dataSets[0]];
    [d addDataSet:dataSets[1]];
    [d addDataSet:dataSets[2]];
    
    return d;
}

- (BarChartData *)generateBarData
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals3 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals4 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < ITEM_COUNT; i++)
    {
        double val = (double) (arc4random_uniform(15) + 3.0);
        [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:i]];
        
        val = (double) (arc4random_uniform(15) + 3.0);
        [yVals2 addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:i]];
        
        val = (double) (arc4random_uniform(15) + 3.0);
        [yVals3 addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:i]];
        
        val = (double) (arc4random_uniform(15) + 4.0);
        [yVals4 addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals1 label:@"Company A"];
    [set1 setColor:[UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f]];
    set1.valueFont = [UIFont systemFontOfSize:10.f];
    set1.valueTextColor = [UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f];
    
    BarChartDataSet *set2 = [[BarChartDataSet alloc] initWithYVals:yVals2 label:@"Company B"];
    [set2 setColor:[UIColor colorWithRed:164/255.f green:228/255.f blue:251/255.f alpha:1.f]];
    set2.valueFont = [UIFont systemFontOfSize:10.f];
    set2.valueTextColor = [UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f];
    
    BarChartDataSet *set3 = [[BarChartDataSet alloc] initWithYVals:yVals3 label:@"Company C"];
    [set3 setColor:[UIColor colorWithRed:242/255.f green:247/255.f blue:158/255.f alpha:1.f]];
    set3.valueFont = [UIFont systemFontOfSize:10.f];
    set3.valueTextColor = [UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f];
    
    BarChartDataSet *set4 = [[BarChartDataSet alloc] initWithYVals:yVals4 label:@"Company D"];
    [set4 setColor:[UIColor colorWithRed:242/255.f green:247/255.f blue:158/255.f alpha:1.f]];
    set4.valueFont = [UIFont systemFontOfSize:10.f];
    set4.valueTextColor = [UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f];
    
    BarChartData *d = [[BarChartData alloc] init];
    [d addDataSet:set1];
    [d addDataSet:set2];
    [d addDataSet:set3];
    [d addDataSet:set4];
    
    return d;
}

@end
