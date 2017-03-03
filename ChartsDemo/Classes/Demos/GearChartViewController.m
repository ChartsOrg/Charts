//
//  GearChartViewController
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "GearChartViewController.h"
#import "ChartsDemo-Swift.h"

@interface GearChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet GearChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UISlider *sliderY;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;

@end

@implementation GearChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Gear Chart";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"spin", @"label": @"Spin"},
                     @{@"key": @"drawCenter", @"label": @"Draw CenterText"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     ];
    
    [self setupGearChartView:_chartView];
    
    _chartView.delegate = self;
    
//    ChartLegend *l = _chartView.legend;
//    l.horizontalAlignment = ChartLegendHorizontalAlignmentRight;
//    l.verticalAlignment = ChartLegendVerticalAlignmentTop;
//    l.orientation = ChartLegendOrientationVertical;
//    l.drawInside = NO;
//    l.xEntrySpace = 7.0;
//    l.yEntrySpace = 0.0;
//    l.yOffset = 0.0;
    
    // entry label styling
    _chartView.entryLabelColor = [UIColor blackColor];
    _chartView.entryLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    
    _sliderX.maximumValue = 100.0;
    _sliderX.value = 67.17;

    [self slidersValueChanged:nil];
    
    [_chartView animateWithYAxisDuration:1.0 easingOption:ChartEasingOptionEaseOutQuad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    
    [self setDataValue:_sliderX.value];
}

- (void)setDataValue:(int)val
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    [values addObject:[[GearChartDataEntry alloc] initWithValue:val label:[NSString stringWithFormat:@"%d %@", val, @" %"] icon: [UIImage imageNamed:@"icon"]]];
    
    GearChartDataSet *dataSet = [[GearChartDataSet alloc] initWithValues:values];
    
    dataSet.drawIconsEnabled = NO;
    dataSet.iconsOffset = CGPointMake(0, 40);
    dataSet.bgGearColor = [UIColor colorWithRed:200.0f/255.0f green:127.0f/255.0f blue:255.0f/255.0f alpha:0.3f];;
    dataSet.gearColor = [UIColor colorWithRed:200.0f/255.0f green:127.0f/255.0f blue:255.0f/255.0f alpha:1.0f];;
    dataSet.gearLineWidth = 25.0;
    
    GearChartData *data = [[GearChartData alloc] initWithDataSet:dataSet];
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [data setValueTextColor:[UIColor darkGrayColor]];
    
    _chartView.data = data;
    [_chartView highlightValues:nil];
}

- (void)optionTapped:(NSString *)key
{
    if ([key isEqualToString:@"animateY"])
    {
        [_chartView animateWithYAxisDuration:1.4];
        return;
    }
    
    if ([key isEqualToString:@"spin"])
    {
        [_chartView spinWithDuration:2.0 fromAngle:_chartView.rotationAngle toAngle:_chartView.rotationAngle + 360.f easingOption:ChartEasingOptionEaseInCubic];
        return;
    }
    
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
