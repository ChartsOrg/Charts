//
//  RealmDemoBaseViewController.m
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 13/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
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
    
    NSString *defaultRealmPath = [RLMRealmConfiguration defaultConfiguration].path;
    [[NSFileManager defaultManager] removeItemAtPath:defaultRealmPath error:nil];
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
        RealmDemoData *d = [[RealmDemoData alloc] initWithValue:randomFloatBetween(30.f, 130.f) xIndex:i xValue:[@(i) stringValue]];
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
        float val1 = randomFloatBetween(20.f, 70.f);
        float val2 = randomFloatBetween(20.f, 70.f);
        float val3 = randomFloatBetween(20.f, 70.f);
        
        NSArray<NSNumber *> *stack = @[@(val1), @(val2), @(val3)];
        
        RealmDemoData *d = [[RealmDemoData alloc] initWithStackValues:stack xIndex:i xValue:[@(i) stringValue]];
        [realm addObject:d];
    }
    
    [realm commitWriteTransaction];
}

@end
