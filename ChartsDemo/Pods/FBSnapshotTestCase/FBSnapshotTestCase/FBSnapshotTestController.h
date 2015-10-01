/*
 *  Copyright (c) 2013, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FBSnapshotTestControllerErrorCode) {
  FBSnapshotTestControllerErrorCodeUnknown,
  FBSnapshotTestControllerErrorCodeNeedsRecord,
  FBSnapshotTestControllerErrorCodePNGCreationFailed,
  FBSnapshotTestControllerErrorCodeImagesDifferentSizes,
  FBSnapshotTestControllerErrorCodeImagesDifferent,
};
/**
 Errors returned by the methods of FBSnapshotTestController use this domain.
 */
extern NSString *const FBSnapshotTestControllerErrorDomain;

/**
 Errors returned by the methods of FBSnapshotTestController sometimes contain this key in the `userInfo` dictionary.
 */
extern NSString *const FBReferenceImageFilePathKey;

/**
 Provides the heavy-lifting for FBSnapshotTestCase. It loads and saves images, along with performing the actual pixel-
 by-pixel comparison of images.
 Instances are initialized with the test class, and directories to read and write to.
 */
@interface FBSnapshotTestController : NSObject

/**
 Record snapshots.
 **/
@property (readwrite, nonatomic, assign) BOOL recordMode;

/**
 @param testClass The subclass of FBSnapshotTestCase that is using this controller.
 @returns An instance of FBSnapshotTestController.
 */
- (instancetype)initWithTestClass:(Class)testClass;

/**
 Designated initializer.
 @param testName The name of the tests.
 @returns An instance of FBSnapshotTestController.
 */
- (instancetype)initWithTestName:(NSString *)testName;


/**
 Performs the comparison of the layer.
 @param layer The Layer to snapshot.
 @param selector The test method being run.
 @param identifier An optional identifier, used is there are muliptle snapshot tests in a given -test method.
 @param error An error to log in an XCTAssert() macro if the method fails (missing reference image, images differ, etc).
 @returns YES if the comparison (or saving of the reference image) succeeded.
 */
- (BOOL)compareSnapshotOfLayer:(CALayer *)layer
                      selector:(SEL)selector
                    identifier:(NSString *)identifier
                         error:(NSError **)errorPtr;

/**
 Performs the comparison of the view.
 @param view The view to snapshot.
 @param selector The test method being run.
 @param identifier An optional identifier, used is there are muliptle snapshot tests in a given -test method.
 @param error An error to log in an XCTAssert() macro if the method fails (missing reference image, images differ, etc).
 @returns YES if the comparison (or saving of the reference image) succeeded.
 */
- (BOOL)compareSnapshotOfView:(UIView *)view
                     selector:(SEL)selector
                   identifier:(NSString *)identifier
                        error:(NSError **)errorPtr;

/**
 Performs the comparison of a view or layer.
 @param view The view or layer to snapshot.
 @param selector The test method being run.
 @param identifier An optional identifier, used is there are muliptle snapshot tests in a given -test method.
 @param error An error to log in an XCTAssert() macro if the method fails (missing reference image, images differ, etc).
 @returns YES if the comparison (or saving of the reference image) succeeded.
 */
- (BOOL)compareSnapshotOfViewOrLayer:(id)viewOrLayer
                            selector:(SEL)selector
                          identifier:(NSString *)identifier
                               error:(NSError **)errorPtr;


/**
 The directory in which referfence images are stored.
 */
@property (readwrite, nonatomic, copy) NSString *referenceImagesDirectory;

/**
 Loads a reference image.
 @param selector The test method being run.
 @param identifier The optional identifier, used when multiple images are tested in a single -test method.
 @param errorPtr An error, if this methods returns nil, the error will be something useful.
 @returns An image.
 */
- (UIImage *)referenceImageForSelector:(SEL)selector
                            identifier:(NSString *)identifier
                                 error:(NSError **)errorPtr;

/**
 Saves a reference image.
 @param selector The test method being run.
 @param identifier The optional identifier, used when multiple images are tested in a single -test method.
 @param errorPtr An error, if this methods returns NO, the error will be something useful.
 @returns An image.
 */
- (BOOL)saveReferenceImage:(UIImage *)image
                  selector:(SEL)selector
                identifier:(NSString *)identifier
                     error:(NSError **)errorPtr;

/**
 Performs a pixel-by-pixel comparison of the two images.
 @param referenceImage The reference (correct) image.
 @param image The image to test against the reference.
 @param errorPtr An error that indicates why the comparison failed if it does.
 @returns YES if the comparison succeeded and the images are the same.
 */
- (BOOL)compareReferenceImage:(UIImage *)referenceImage
                      toImage:(UIImage *)image
                        error:(NSError **)errorPtr;

/**
 Saves the reference image and the test image to `failedOutputDirectory`.
 @param referenceImage The reference (correct) image.
 @param testImage The image to test against the reference.
 @param selector The test method being run.
 @param identifier The optional identifier, used when multiple images are tested in a single -test method.
 @param errorPtr An error that indicates why the comparison failed if it does.
 @returns YES if the save succeeded.
 */
- (BOOL)saveFailedReferenceImage:(UIImage *)referenceImage
                       testImage:(UIImage *)testImage
                        selector:(SEL)selector
                      identifier:(NSString *)identifier
                           error:(NSError **)errorPtr;
@end
