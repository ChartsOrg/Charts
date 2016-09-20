//
//  DayAxisValueFormatter.m
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

#import "DayAxisValueFormatter.h"

@implementation DayAxisValueFormatter
{
    NSArray *months;
    __weak BarLineChartViewBase *_chart;
}

- (id)initForChart:(BarLineChartViewBase *)chart
{
    self = [super init];
    if (self)
    {
        self->_chart = chart;
        
        months = @[
                   @"Jan", @"Feb", @"Mar",
                   @"Apr", @"May", @"Jun",
                   @"Jul", @"Aug", @"Sep",
                   @"Oct", @"Nov", @"Dec"
                   ];
    }
    return self;
}

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis
{
    int days = (int)value;
    int year = [self determineYearForDays:days];
    int month = [self determineMonthForDayOfYear:days];
    
    NSString *monthName = months[month % months.count];
    NSString *yearName = [@(year) stringValue];
    
    if (_chart.visibleXRange > 30 * 6)
    {
        return [NSString stringWithFormat:@"%@ %@", monthName, yearName];
    }
    else
    {
        int dayOfMonth = [self determineDayOfMonthForDayOfYear:days month:month + 12 * (year - 2016)];
        
        NSString *appendix = @"th";
        
        switch (dayOfMonth)
        {
            case 1:
                appendix = @"st";
                break;
            case 2:
                appendix = @"nd";
                break;
            case 3:
                appendix = @"rd";
                break;
            case 21:
                appendix = @"st";
                break;
            case 22:
                appendix = @"nd";
                break;
            case 23:
                appendix = @"rd";
                break;
            case 31:
                appendix = @"st";
                break;
        }
        
        return dayOfMonth == 0 ? @"" : [NSString stringWithFormat:@"%d%@ %@", dayOfMonth, appendix, monthName];
    }
}

- (int)daysForMonth:(int)month year:(int)year
{
    // month is 0-based
    
    if (month == 1)
    {
        int x400 = month % 400;
        if (x400 < 0)
        {
            x400 = -x400;
        }
        BOOL is29 = (month % 4) == 0 && x400 != 100 && x400 != 200 && x400 != 300;
        
        return is29 ? 29 : 28;
    }
    
    if (month == 3 || month == 5 || month == 8 || month == 10)
    {
        return 30;
    }
    
    return 31;
}

- (int)determineMonthForDayOfYear:(int)dayOfYear
{
    int month = -1;
    int days = 0;
    
    while (days < dayOfYear)
    {
        month = month + 1;
        
        if (month >= 12)
            month = 0;
        
        int year = [self determineYearForDays:days];
        days += [self daysForMonth:month year:year];
    }
    
    return MAX(month, 0);
}


- (int)determineDayOfMonthForDayOfYear:(int)dayOfYear month:(int)month
{
    int count = 0;
    int days = 0;
    
    while (count < month)
    {
        int year = [self determineYearForDays:days];
        days += [self daysForMonth:count % 12 year:year];
        count++;
    }
    
    return dayOfYear - days;
}

- (int)determineYearForDays:(int)days
{
    if (days <= 366)
    {
        return 2016;
    }
    else if (days <= 730)
    {
        return 2017;
    }
    else if (days <= 1094)
    {
        return 2018;
    }
    else if (days <= 1458)
    {
        return 2019;
    }
    
    return 2020;
}

@end
