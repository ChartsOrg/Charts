//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import "___VARIABLE_cutClass:identifier___.h"
#import "FBSnapshotTestCase.h"

@interface ___VARIABLE_cutClass:identifier___SnapshotTests : FBSnapshotTestCase
@property (nonatomic, strong) ___VARIABLE_cutClass:identifier___ *___VARIABLE_propName:identifier___;
@end

@implementation ___VARIABLE_cutClass:identifier___SnapshotTests

- (void)setUp
{
    [super setUp];

    self.recordMode = YES;

    self.___VARIABLE_propName:identifier___ = [[___VARIABLE_cutClass:identifier___ alloc] init];
}

- (void)tearDown
{
    self.___VARIABLE_propName:identifier___ = nil;
    [super tearDown];
}

- (void)test<#testnamehere#>
{
    <# set up your view and add the data #>

    FBSnapshotVerifyView(self.___VARIABLE_propName:identifier___, nil);
}

@end