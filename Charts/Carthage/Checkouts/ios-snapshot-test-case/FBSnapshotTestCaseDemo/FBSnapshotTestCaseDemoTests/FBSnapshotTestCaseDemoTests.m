/*
 *  Copyright (c) 2013, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */
 
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>

@interface FBSnapshotTestCaseDemoTests : FBSnapshotTestCase

@end

@implementation FBSnapshotTestCaseDemoTests

- (void)setUp
{
  [super setUp];
  // Flip this to YES to record images in the reference image directory.
  // You need to do this the first time you create a test and whenever you change the snapshotted views.
  // Tests running in record mode will allways fail so that you know that you have to do something here before you commit.
  self.recordMode = NO;
}

- (void)testViewSnapshot
{
  UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
  redView.backgroundColor = [UIColor redColor];
  FBSnapshotVerifyView(redView, nil);
  FBSnapshotVerifyLayer(redView.layer, nil);
}

- (void)testViewSnapshotWithVisualEffects
{
  if ([UIVisualEffect class]) {
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 40)];
    redView.backgroundColor = [UIColor redColor];
    visualEffectView.frame = CGRectMake(0, 0, 40, 40);
    
    UIView *parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    parentView.backgroundColor = [UIColor whiteColor];
    [parentView addSubview:redView];
    [parentView addSubview:visualEffectView];

    self.usesDrawViewHierarchyInRect = YES;
    FBSnapshotVerifyView(parentView, nil);
  } 
}

- (void)testViewSnapshotWithUIAppearance
{
  [[UISwitch appearance] setOnTintColor:[UIColor blueColor]];
  [[UISwitch appearance] setThumbTintColor:[UIColor lightGrayColor]];
  UISwitch *control = [[UISwitch alloc] init];
  control.on = YES;
  
  self.usesDrawViewHierarchyInRect = YES;
  FBSnapshotVerifyView(control, nil);
}

- (void)testViewSnapshotWithDifferentBackgroundColorPerArchitecture
{
    UIColor *color = FBSnapshotTestCaseIs64Bit() ? [UIColor magentaColor] : [UIColor cyanColor];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    view.backgroundColor = color;
    FBSnapshotVerifyView(view, nil);
}

- (void)testViewSnapshotRecordedOnlyFor64BitArchitecture
{
    UIView *greenView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    greenView.backgroundColor = [UIColor greenColor];
    FBSnapshotVerifyView(greenView, nil);
}

@end
