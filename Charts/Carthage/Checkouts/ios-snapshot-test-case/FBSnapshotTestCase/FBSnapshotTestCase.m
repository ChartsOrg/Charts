/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <FBSnapshotTestCase/FBSnapshotTestController.h>

@implementation FBSnapshotTestCase
{
  FBSnapshotTestController *_snapshotController;
}

#pragma mark - Overrides

- (void)setUp
{
  [super setUp];
  _snapshotController = [[FBSnapshotTestController alloc] initWithTestName:NSStringFromClass([self class])];
}

- (void)tearDown
{
  _snapshotController = nil;
  [super tearDown];
}

- (BOOL)recordMode
{
  return _snapshotController.recordMode;
}

- (void)setRecordMode:(BOOL)recordMode
{
  NSAssert1(_snapshotController, @"%s cannot be called before [super setUp]", __FUNCTION__);
  _snapshotController.recordMode = recordMode;
}

- (BOOL)isDeviceAgnostic
{
  return _snapshotController.deviceAgnostic;
}

- (void)setDeviceAgnostic:(BOOL)deviceAgnostic
{
  NSAssert1(_snapshotController, @"%s cannot be called before [super setUp]", __FUNCTION__);
  _snapshotController.deviceAgnostic = deviceAgnostic;
}

- (BOOL)usesDrawViewHierarchyInRect
{
  return _snapshotController.usesDrawViewHierarchyInRect;
}

- (void)setUsesDrawViewHierarchyInRect:(BOOL)usesDrawViewHierarchyInRect
{
  NSAssert1(_snapshotController, @"%s cannot be called before [super setUp]", __FUNCTION__);
  _snapshotController.usesDrawViewHierarchyInRect = usesDrawViewHierarchyInRect;
}

#pragma mark - Public API

- (BOOL)compareSnapshotOfLayer:(CALayer *)layer
      referenceImagesDirectory:(NSString *)referenceImagesDirectory
                    identifier:(NSString *)identifier
                     tolerance:(CGFloat)tolerance
                         error:(NSError **)errorPtr
{
  return [self _compareSnapshotOfViewOrLayer:layer
                    referenceImagesDirectory:referenceImagesDirectory
                                  identifier:identifier
                                   tolerance:tolerance
                                       error:errorPtr];
}

- (BOOL)compareSnapshotOfView:(UIView *)view
     referenceImagesDirectory:(NSString *)referenceImagesDirectory
                   identifier:(NSString *)identifier
                    tolerance:(CGFloat)tolerance
                        error:(NSError **)errorPtr
{
  return [self _compareSnapshotOfViewOrLayer:view
                    referenceImagesDirectory:referenceImagesDirectory
                                  identifier:identifier
                                   tolerance:tolerance
                                       error:errorPtr];
}

- (BOOL)referenceImageRecordedInDirectory:(NSString *)referenceImagesDirectory
                               identifier:(NSString *)identifier
                                    error:(NSError **)errorPtr
{
    NSAssert1(_snapshotController, @"%s cannot be called before [super setUp]", __FUNCTION__);
    _snapshotController.referenceImagesDirectory = referenceImagesDirectory;
    UIImage *referenceImage = [_snapshotController referenceImageForSelector:self.invocation.selector
                                                                  identifier:identifier
                                                                       error:errorPtr];

    return (referenceImage != nil);
}

- (NSString *)getReferenceImageDirectoryWithDefault:(NSString *)dir
{
  NSString *envReferenceImageDirectory = [NSProcessInfo processInfo].environment[@"FB_REFERENCE_IMAGE_DIR"];
  if (envReferenceImageDirectory) {
    return envReferenceImageDirectory;
  }
  if (dir && dir.length > 0) {
    return dir;
  }
  return [[NSBundle bundleForClass:self.class].resourcePath stringByAppendingPathComponent:@"ReferenceImages"];
}


#pragma mark - Private API

- (BOOL)_compareSnapshotOfViewOrLayer:(id)viewOrLayer
             referenceImagesDirectory:(NSString *)referenceImagesDirectory
                           identifier:(NSString *)identifier
                            tolerance:(CGFloat)tolerance
                                error:(NSError **)errorPtr
{
  _snapshotController.referenceImagesDirectory = referenceImagesDirectory;
  return [_snapshotController compareSnapshotOfViewOrLayer:viewOrLayer
                                                  selector:self.invocation.selector
                                                identifier:identifier
                                                 tolerance:tolerance
                                                     error:errorPtr];
}

@end
