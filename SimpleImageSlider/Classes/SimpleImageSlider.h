//
//  SimpleImageSlider.h
//  Pods
//
//  Created by Christian Hatch on 5/31/16.
//
//

@import UIKit;

@interface SimpleImageSlider : UIScrollView

/**
 Designated Initializer for images!
 
 @param frame  The frame of the SimpleImageSlider.
 @param images The images to be set on the SimpleImageSlider
 
 @return A new intialized SimpleImageSlider
 */
+ (nonnull instancetype)imageSliderWithFrame:(CGRect)frame
                                      images:(nullable NSArray<UIImage *> *)images;

/**
 Designated Initializer for image URLs!
 
 @param frame  The frame of the SimpleImageSlider.
 @param images The urls of the images to be set on the SimpleImageSlider
 
 @return A new intialized SimpleImageSlider
 */
+ (nonnull instancetype)imageSliderWithFrame:(CGRect)frame
                                   imageURLs:(nullable NSArray<NSURL *> *)imageURLs;

/**
 An array of imageURLs used to populate the image scroller. Nil if the SimpleImageSlider was created with images.
 */
@property (nonatomic, copy, nullable) NSArray<NSURL *> *imageURLs;

/**
 An array of images used to populate the image scroller. Nil if the SimpleImageSlider was created with imageURLs.
 */
@property (nonatomic, copy, nullable) NSArray<UIImage *> *images;


/**
 *  Attaches the SimpleImageSlider to a scrollview for a parallax effect.
 *
 *  @param scrollView The scrollview in which the ImageSlider is a subview, and from which scroll events will be taken. 
 */
- (void)addParallaxEffectWithScrollView:(nonnull UIScrollView *)scrollView height:(CGFloat)height;

@end
