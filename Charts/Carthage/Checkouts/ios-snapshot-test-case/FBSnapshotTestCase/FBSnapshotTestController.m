/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <FBSnapshotTestCase/FBSnapshotTestController.h>
#import <FBSnapshotTestCase/FBSnapshotTestCasePlatform.h>
#import <FBSnapshotTestCase/UIImage+Compare.h>
#import <FBSnapshotTestCase/UIImage+Diff.h>
#import <FBSnapshotTestCase/UIImage+Snapshot.h>

#import <UIKit/UIKit.h>

NSString *const FBSnapshotTestControllerErrorDomain = @"FBSnapshotTestControllerErrorDomain";
NSString *const FBReferenceImageFilePathKey = @"FBReferenceImageFilePathKey";

typedef NS_ENUM(NSUInteger, FBTestSnapshotFileNameType) {
  FBTestSnapshotFileNameTypeReference,
  FBTestSnapshotFileNameTypeFailedReference,
  FBTestSnapshotFileNameTypeFailedTest,
  FBTestSnapshotFileNameTypeFailedTestDiff,
};

@implementation FBSnapshotTestController
{
  NSString *_testName;
  NSFileManager *_fileManager;
}

#pragma mark - Initializers

- (instancetype)initWithTestClass:(Class)testClass;
{
  return [self initWithTestName:NSStringFromClass(testClass)];
}

- (instancetype)initWithTestName:(NSString *)testName
{
  if (self = [super init]) {
    _testName = [testName copy];
    _deviceAgnostic = NO;
    
    _fileManager = [[NSFileManager alloc] init];
  }
  return self;
}

#pragma mark - Overrides

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ %@", [super description], _referenceImagesDirectory];
}

#pragma mark - Public API

- (BOOL)compareSnapshotOfLayer:(CALayer *)layer
                      selector:(SEL)selector
                    identifier:(NSString *)identifier
                         error:(NSError **)errorPtr
{
  return [self compareSnapshotOfViewOrLayer:layer
                                   selector:selector
                                 identifier:identifier
                                  tolerance:0
                                      error:errorPtr];
}

- (BOOL)compareSnapshotOfView:(UIView *)view
                     selector:(SEL)selector
                   identifier:(NSString *)identifier
                        error:(NSError **)errorPtr
{
  return [self compareSnapshotOfViewOrLayer:view
                                   selector:selector
                                 identifier:identifier
                                  tolerance:0
                                      error:errorPtr];
}

- (BOOL)compareSnapshotOfViewOrLayer:(id)viewOrLayer
                            selector:(SEL)selector
                          identifier:(NSString *)identifier
                           tolerance:(CGFloat)tolerance
                               error:(NSError **)errorPtr
{
  if (self.recordMode) {
    return [self _recordSnapshotOfViewOrLayer:viewOrLayer selector:selector identifier:identifier error:errorPtr];
  } else {
    return [self _performPixelComparisonWithViewOrLayer:viewOrLayer selector:selector identifier:identifier tolerance:tolerance error:errorPtr];
  }
}

- (UIImage *)referenceImageForSelector:(SEL)selector
                            identifier:(NSString *)identifier
                                 error:(NSError **)errorPtr
{
  NSString *filePath = [self _referenceFilePathForSelector:selector identifier:identifier];
  UIImage *image = [UIImage imageWithContentsOfFile:filePath];
  if (nil == image && NULL != errorPtr) {
    BOOL exists = [_fileManager fileExistsAtPath:filePath];
    if (!exists) {
      *errorPtr = [NSError errorWithDomain:FBSnapshotTestControllerErrorDomain
                                      code:FBSnapshotTestControllerErrorCodeNeedsRecord
                                  userInfo:@{
               FBReferenceImageFilePathKey: filePath,
                 NSLocalizedDescriptionKey: @"Unable to load reference image.",
          NSLocalizedFailureReasonErrorKey: @"Reference image not found. You need to run the test in record mode",
                   }];
    } else {
      *errorPtr = [NSError errorWithDomain:FBSnapshotTestControllerErrorDomain
                                      code:FBSnapshotTestControllerErrorCodeUnknown
                                  userInfo:nil];
    }
  }
  return image;
}

- (BOOL)compareReferenceImage:(UIImage *)referenceImage
                      toImage:(UIImage *)image
                    tolerance:(CGFloat)tolerance
                        error:(NSError **)errorPtr
{
  if (CGSizeEqualToSize(referenceImage.size, image.size)) {
    BOOL imagesEqual = [referenceImage fb_compareWithImage:image tolerance:tolerance];
    if (NULL != errorPtr) {
      *errorPtr = [NSError errorWithDomain:FBSnapshotTestControllerErrorDomain
                                      code:FBSnapshotTestControllerErrorCodeImagesDifferent
                                  userInfo:@{
                                             NSLocalizedDescriptionKey: @"Images different",
                                             }];
    }
    return imagesEqual;
  }
  if (NULL != errorPtr) {
    *errorPtr = [NSError errorWithDomain:FBSnapshotTestControllerErrorDomain
                                    code:FBSnapshotTestControllerErrorCodeImagesDifferentSizes
                                userInfo:@{
                                           NSLocalizedDescriptionKey: @"Images different sizes",
                                           NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"referenceImage:%@, image:%@",
                                                                              NSStringFromCGSize(referenceImage.size),
                                                                              NSStringFromCGSize(image.size)],
                                           }];
  }
  return NO;
}

- (BOOL)saveFailedReferenceImage:(UIImage *)referenceImage
                       testImage:(UIImage *)testImage
                        selector:(SEL)selector
                      identifier:(NSString *)identifier
                           error:(NSError **)errorPtr
{
  NSData *referencePNGData = UIImagePNGRepresentation(referenceImage);
  NSData *testPNGData = UIImagePNGRepresentation(testImage);

  NSString *referencePath = [self _failedFilePathForSelector:selector
                                                  identifier:identifier
                                                fileNameType:FBTestSnapshotFileNameTypeFailedReference];

  NSError *creationError = nil;
  BOOL didCreateDir = [_fileManager createDirectoryAtPath:[referencePath stringByDeletingLastPathComponent]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&creationError];
  if (!didCreateDir) {
    if (NULL != errorPtr) {
      *errorPtr = creationError;
    }
    return NO;
  }

  if (![referencePNGData writeToFile:referencePath options:NSDataWritingAtomic error:errorPtr]) {
    return NO;
  }

  NSString *testPath = [self _failedFilePathForSelector:selector
                                             identifier:identifier
                                           fileNameType:FBTestSnapshotFileNameTypeFailedTest];

  if (![testPNGData writeToFile:testPath options:NSDataWritingAtomic error:errorPtr]) {
    return NO;
  }

  NSString *diffPath = [self _failedFilePathForSelector:selector
                                             identifier:identifier
                                           fileNameType:FBTestSnapshotFileNameTypeFailedTestDiff];

  UIImage *diffImage = [referenceImage fb_diffWithImage:testImage];
  NSData *diffImageData = UIImagePNGRepresentation(diffImage);

  if (![diffImageData writeToFile:diffPath options:NSDataWritingAtomic error:errorPtr]) {
    return NO;
  }

  NSLog(@"If you have Kaleidoscope installed you can run this command to see an image diff:\n"
        @"ksdiff \"%@\" \"%@\"", referencePath, testPath);

  return YES;
}

#pragma mark - Private API

- (NSString *)_fileNameForSelector:(SEL)selector
                        identifier:(NSString *)identifier
                      fileNameType:(FBTestSnapshotFileNameType)fileNameType
{
  NSString *fileName = nil;
  switch (fileNameType) {
    case FBTestSnapshotFileNameTypeFailedReference:
      fileName = @"reference_";
      break;
    case FBTestSnapshotFileNameTypeFailedTest:
      fileName = @"failed_";
      break;
    case FBTestSnapshotFileNameTypeFailedTestDiff:
      fileName = @"diff_";
      break;
    default:
      fileName = @"";
      break;
  }
  fileName = [fileName stringByAppendingString:NSStringFromSelector(selector)];
  if (0 < identifier.length) {
    fileName = [fileName stringByAppendingFormat:@"_%@", identifier];
  }
  
  if (self.isDeviceAgnostic) {
    fileName = FBDeviceAgnosticNormalizedFileName(fileName);
  }
  
  if ([[UIScreen mainScreen] scale] > 1) {
    fileName = [fileName stringByAppendingFormat:@"@%.fx", [[UIScreen mainScreen] scale]];
  }
  fileName = [fileName stringByAppendingPathExtension:@"png"];
  return fileName;
}

- (NSString *)_referenceFilePathForSelector:(SEL)selector
                                 identifier:(NSString *)identifier
{
  NSString *fileName = [self _fileNameForSelector:selector
                                       identifier:identifier
                                     fileNameType:FBTestSnapshotFileNameTypeReference];
  NSString *filePath = [_referenceImagesDirectory stringByAppendingPathComponent:_testName];
  filePath = [filePath stringByAppendingPathComponent:fileName];
  return filePath;
}

- (NSString *)_failedFilePathForSelector:(SEL)selector
                              identifier:(NSString *)identifier
                            fileNameType:(FBTestSnapshotFileNameType)fileNameType
{
  NSString *fileName = [self _fileNameForSelector:selector
                                       identifier:identifier
                                     fileNameType:fileNameType];
  NSString *folderPath = NSTemporaryDirectory();
  if (getenv("IMAGE_DIFF_DIR")) {
    folderPath = @(getenv("IMAGE_DIFF_DIR"));
  }
  NSString *filePath = [folderPath stringByAppendingPathComponent:_testName];
  filePath = [filePath stringByAppendingPathComponent:fileName];
  return filePath;
}

- (BOOL)_performPixelComparisonWithViewOrLayer:(id)viewOrLayer
                                      selector:(SEL)selector
                                    identifier:(NSString *)identifier
                                     tolerance:(CGFloat)tolerance
                                         error:(NSError **)errorPtr
{
  UIImage *referenceImage = [self referenceImageForSelector:selector identifier:identifier error:errorPtr];
  if (nil != referenceImage) {
    UIImage *snapshot = [self _imageForViewOrLayer:viewOrLayer];
    BOOL imagesSame = [self compareReferenceImage:referenceImage toImage:snapshot tolerance:tolerance error:errorPtr];
    if (!imagesSame) {
      [self saveFailedReferenceImage:referenceImage
                           testImage:snapshot
                            selector:selector
                          identifier:identifier
                               error:errorPtr];
    }
    return imagesSame;
  }
  return NO;
}

- (BOOL)_recordSnapshotOfViewOrLayer:(id)viewOrLayer
                            selector:(SEL)selector
                          identifier:(NSString *)identifier
                               error:(NSError **)errorPtr
{
  UIImage *snapshot = [self _imageForViewOrLayer:viewOrLayer];
  return [self _saveReferenceImage:snapshot selector:selector identifier:identifier error:errorPtr];
}

- (BOOL)_saveReferenceImage:(UIImage *)image
                   selector:(SEL)selector
                 identifier:(NSString *)identifier
                      error:(NSError **)errorPtr
{
  BOOL didWrite = NO;
  if (nil != image) {
    NSString *filePath = [self _referenceFilePathForSelector:selector identifier:identifier];
    NSData *pngData = UIImagePNGRepresentation(image);
    if (nil != pngData) {
      NSError *creationError = nil;
      BOOL didCreateDir = [_fileManager createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&creationError];
      if (!didCreateDir) {
        if (NULL != errorPtr) {
          *errorPtr = creationError;
        }
        return NO;
      }
      didWrite = [pngData writeToFile:filePath options:NSDataWritingAtomic error:errorPtr];
      if (didWrite) {
        NSLog(@"Reference image save at: %@", filePath);
      }
    } else {
      if (nil != errorPtr) {
        *errorPtr = [NSError errorWithDomain:FBSnapshotTestControllerErrorDomain
                                        code:FBSnapshotTestControllerErrorCodePNGCreationFailed
                                    userInfo:@{
                                               FBReferenceImageFilePathKey: filePath,
                                               }];
      }
    }
  }
  return didWrite;
}

- (UIImage *)_imageForViewOrLayer:(id)viewOrLayer
{
  if ([viewOrLayer isKindOfClass:[UIView class]]) {
    if (_usesDrawViewHierarchyInRect) {
      return [UIImage fb_imageForView:viewOrLayer];
    } else {
      return [UIImage fb_imageForViewLayer:viewOrLayer];
    }
  } else if ([viewOrLayer isKindOfClass:[CALayer class]]) {
    return [UIImage fb_imageForLayer:viewOrLayer];
  } else {
    [NSException raise:@"Only UIView and CALayer classes can be snapshotted" format:@"%@", viewOrLayer];
  }
  return nil;
}

@end
