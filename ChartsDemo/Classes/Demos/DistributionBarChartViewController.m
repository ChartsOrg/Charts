//
//  DistributionBarChartViewController.m
//  ChartsDemo
//
//  Created by Marco D'Amelio on 07/03/17.
//  Copyright © 2017 dcg. All rights reserved.
//

#import "DistributionBarChartViewController.h"
#import "ChartsDemo-Swift.h"

@interface DistributionBarChartViewController () <ChartViewDelegate, IChartAxisValueFormatter>

@property (nonatomic, strong) IBOutlet HorizontalBarChartView *chartView;

@end

@implementation DistributionBarChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Distribution Bar Chart";
    

//    NSNumberFormatter *customFormatter = [[NSNumberFormatter alloc] init];
//    customFormatter.negativePrefix = @"";
//    customFormatter.positiveSuffix = @"m";
//    customFormatter.negativeSuffix = @"m";
//    customFormatter.minimumSignificantDigits = 1;
//    customFormatter.minimumFractionDigits = 1;
    
    _chartView.delegate = self;

    
    _chartView.chartDescription.enabled = NO;
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = NO;
    _chartView.highlightFullBarEnabled = NO;
   
    
    
    // scaling can now only be done on x- and y-axis separately
    _chartView.pinchZoomEnabled = NO;
    _chartView.scaleXEnabled = NO;
    _chartView.scaleYEnabled = NO;
    
    _chartView.drawBarShadowEnabled = NO;
    
    _chartView.leftAxis.enabled = NO;
    //_chartView.rightAxis.axisMinimum = 1.0;
    _chartView.rightAxis.drawGridLinesEnabled = NO;
    _chartView.rightAxis.drawZeroLineEnabled = NO;
    //_chartView.rightAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:customFormatter];
    //_chartView.rightAxis.labelFont = [UIFont systemFontOfSize:1.f];
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBothSided;
    xAxis.drawGridLinesEnabled = YES;
    xAxis.drawAxisLineEnabled = NO;
    xAxis.axisMinimum = 0.0;

    xAxis.drawLabelsEnabled = NO;
    xAxis.granularity = 10.0;
    xAxis.valueFormatter = self;
    _chartView.userInteractionEnabled = false;
    
  //  _chartView.rightAxis.labelFont = [UIFont systemFontOfSize:9.f];
    _chartView.rightAxis.drawLabelsEnabled = NO;
    _chartView.rightAxis.drawAxisLineEnabled = NO;

    
    ChartLegend *l = _chartView.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentRight;
    l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    l.orientation = ChartLegendOrientationHorizontal;
    l.drawInside = NO;
    l.formSize = 8.f;
    l.formToTextSpace = 4.f;
    l.xEntrySpace = 3.f;
    
    [self updateChartData];
}

- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    
    [self setChartData];
}

- (void)setChartData
{
    NSMutableArray *yValues = [NSMutableArray array];
    [yValues addObject:[[BarChartDataEntry alloc] initWithX:1 yValues:@[ @75, @25]]];

    
    BarChartDataSet *set = nil;
    if (_chartView.data.dataSetCount > 0)
    {
        set = (BarChartDataSet *)_chartView.data.dataSets[0];
        set.values = yValues;
        set.isStackedWithRoundedCorners = YES;
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
//        NSNumberFormatter *customFormatter = [[NSNumberFormatter alloc] init];
//        customFormatter.negativePrefix = @"";
//        customFormatter.positiveSuffix = @"m";
//        customFormatter.negativeSuffix = @"m";
//        customFormatter.minimumSignificantDigits = 1;
//        customFormatter.minimumFractionDigits = 1;
        
        set = [[BarChartDataSet alloc] initWithValues:yValues label:@""];
        
        set.drawIconsEnabled = NO;
        set.drawValuesEnabled = NO;

        
//        set.valueFormatter = [[ChartDefaultValueFormatter alloc] initWithFormatter:customFormatter];
//        set.valueFont = [UIFont systemFontOfSize:1.f];
        set.axisDependency = AxisDependencyRight;

        set.colors = @[
                       [UIColor colorWithRed:67/255.f green:67/255.f blue:72/255.f alpha:1.f],
                       [UIColor colorWithRed:124/255.f green:181/255.f blue:236/255.f alpha:1.f]
                       ];
        set.stackLabels = @[
                            @"Men", @"Women"
                            ];
        
        BarChartData *data = [[BarChartData alloc] initWithDataSet:set];
        
        data.barWidth = 0.2;

        set.isStackedWithRoundedCorners = YES;
        set.barCornerRadius = 8.5f;
        _chartView.data = data;
        [_chartView setNeedsDisplay];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)optionTapped:(NSString *)key
{
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected, stack-index %ld", (long)highlight.stackIndex);
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

#pragma mark - IAxisValueFormatter

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis
{
    //return [NSString stringWithFormat:@"%03.0f-%03.0f", value, value + 10.0];
    return @"";
}

@end
