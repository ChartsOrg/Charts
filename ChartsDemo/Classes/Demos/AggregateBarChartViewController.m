//
//  AggregateBarChartViewController.m
//  ChartsDemo
//
//  Created by Maxim Komlev on 4/28/17.
//  Copyright © 2017 dcg. All rights reserved.
//

#import "AggregateBarChartViewController.h"
#import "ChartsDemo-Swift.h"

@interface AggregateBarChartViewController () <ChartViewDelegate>
    
    @property (nonatomic, strong) IBOutlet AggregatedBarChartView *chartView;
    @property (nonatomic, strong) IBOutlet UISlider *sliderX;
    @property (nonatomic, strong) IBOutlet UISlider *sliderY;
    @property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
    @property (nonatomic, strong) IBOutlet UITextField *sliderTextY;
    
    @end

@implementation AggregateBarChartViewController
    
#pragma mark - Overrides
- (void)viewDidLoad
    {
        [super viewDidLoad];
        
        self.title = @"Aggregate Bar Chart";
        
        self.options = @[
                         @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                         @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                         @{@"key": @"animateX", @"label": @"Animate X"},
                         @{@"key": @"animateY", @"label": @"Animate Y"},
                         @{@"key": @"animateXY", @"label": @"Animate XY"},
                         @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                         @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                         @{@"key": @"toggleData", @"label": @"Toggle Data"},
                         @{@"key": @"toggleBarBorders", @"label": @"Show Bar Borders"},
                         ];
        
        _chartView.delegate = self;
        
        _chartView.chartDescription.enabled = NO;
        
        _chartView.maxVisibleCount = 60;
        _chartView.pinchZoomEnabled = NO;
        _chartView.drawBarShadowEnabled = NO;
        _chartView.drawGridBackgroundEnabled = NO;
        
        ChartXAxis *xAxis = _chartView.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.drawGridLinesEnabled = NO;
  
        ChartYAxis *leftAxis = _chartView.leftAxis;
        leftAxis.inverted = FALSE;

        _chartView.leftAxis.drawGridLinesEnabled = NO;
        _chartView.rightAxis.drawGridLinesEnabled = NO;
        _chartView.drawValueAboveBarEnabled = YES;
        
        _chartView.legend.enabled = NO;
        _chartView.drawBarShadowEnabled = TRUE;
        _chartView.drawMarkers = TRUE;
        _chartView.groupMargin = 6;
        _chartView.groupWidth = 14;
        
        _sliderX.value = 10.0;
        _sliderY.value = 100.0;
        [self slidersValueChanged:nil];
    }
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (void)updateChartData {
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    
    [self setDataCount:_sliderX.value + 1 range:_sliderY.value];
}
    
- (void)setDataCount:(int)count range:(double)range
    {
        NSMutableArray *yVals = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < count; i++)
        {
            double mult = (range + 1);
            double val = (double) (arc4random_uniform(mult)) + mult / 3.0;
            [yVals addObject:[[BarChartDataEntry alloc] initWithX:i y:val]];
        }
        
        BarChartDataSet *set1 = nil;
        if (_chartView.data.dataSetCount > 0)
        {
            set1 = (BarChartDataSet *)_chartView.data.dataSets[0];
            set1.values = yVals;
            [_chartView.data notifyDataChanged];
            [_chartView notifyDataSetChanged];
        }
        else
        {
            set1 = [[BarChartDataSet alloc] initWithValues:yVals label:@"DataSet"];
            set1.colors = ChartColorTemplates.vordiplom;
            set1.drawValuesEnabled = TRUE;
            
            NSMutableArray *dataSets = [[NSMutableArray alloc] init];
            [dataSets addObject:set1];
            
            BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
            [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];

            _chartView.data = data;
            _chartView.fitBars = YES;
        }
        
        [_chartView setNeedsDisplay];
    }
    
- (void)optionTapped:(NSString *)key
    {
        [super handleOption:key forChartView:_chartView];
    }
    
#pragma mark - Actions
    
- (IBAction)slidersValueChanged:(id)sender
    {
        _sliderTextX.text = [@((int)_sliderX.value) stringValue];
        _sliderTextY.text = [@((int)_sliderY.value) stringValue];
        
        [self updateChartData];
    }
    
#pragma mark - ChartViewDelegate
    
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
    {
        NSLog(@"chartValueSelected");
    }
    
- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
    {
        NSLog(@"chartValueNothingSelected");
    }
    
    @end
