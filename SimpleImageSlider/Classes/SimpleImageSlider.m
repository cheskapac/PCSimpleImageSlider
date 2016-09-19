//
//  SimpleImageSlider.m
//  Pods
//
//  Created by Christian Hatch on 5/31/16.
//
//

#import "SimpleImageSlider.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIScrollView+VGParallaxHeader.h"


@interface UIImageView (SimpleImageSlider)

- (void)setImageAnimated:(UIImage *)image;
- (void)setImageAnimatedWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder;

@end




static CGFloat const kImageOffset = 0;
static CGFloat const kPageControlHeight = 36;




@interface SimpleImageSlider () <UIScrollViewDelegate>
@property (nonatomic, strong) UIPageControl *pageControl;
@end




@implementation SimpleImageSlider

#pragma mark - Initialization

+ (instancetype)imageSliderWithFrame:(CGRect)frame
                           imageURLs:(NSArray *)imageURLs
{
    SimpleImageSlider *slider = [[SimpleImageSlider alloc] initWithFrame:frame];
    slider.imageURLs = imageURLs;
    return slider;
}

+ (instancetype)imageSliderWithFrame:(CGRect)frame
                              images:(NSArray<UIImage *> *)images
{
    SimpleImageSlider *slider = [[SimpleImageSlider alloc] initWithFrame:frame];
    slider.images = images;
    return slider;
}

+ (nonnull instancetype)imageSliderWithFrame:(CGRect)frame
                                 customViews:(nullable NSArray<UIView *> *)customViews;
{
    SimpleImageSlider *slider = [[SimpleImageSlider alloc] initWithFrame:frame];
    slider.customViews = customViews;
    return slider;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat sizeWidth = ([self proxyData].count * self.bounds.size.width) + (kImageOffset * [self proxyData].count) - kImageOffset;
    self.contentSize = CGSizeMake(sizeWidth, self.bounds.size.height);
}

#pragma mark - Main Method

- (void)updateUI
{
    //bail if we don't have any data
    if ([self proxyData] == nil) {
        return;
    }

    //first clear out all extant imageviews
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    //get sizes
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
        //iterate through the imageobjects and create an imageview
    for (int i = 0; i < [self proxyData].count; i++) {
        
        //create frame size & position
        CGRect imageSize = CGRectMake(i * width + kImageOffset,
                                      0,
                                      width - kImageOffset - kImageOffset,
                                      height);
        
        if ([self proxyData] == self.customViews) {
            
            UIView *view = self.customViews[i];
            view.frame = imageSize;
            view.clipsToBounds = YES;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:view];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0f]];
        }
        else {
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:imageSize];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds = YES;
            imgView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0.83 alpha:1];
            imgView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:imgView];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0f]];

            if ([self proxyData] == self.images) {
                //get image
                UIImage *image = self.images[i];
                [imgView setImageAnimated:image];
            }
            else if ([self proxyData] == self.imageURLs) {
                //get imageurl
                NSURL *imageURL = self.imageURLs[i];
                [imgView setImageAnimatedWithURL:imageURL placeholder:nil];
            }
            
        }
        
    }
    
    CGFloat sizeWidth = ([self proxyData].count * width) + (kImageOffset * [self proxyData].count) - kImageOffset;
    self.contentSize = CGSizeMake(sizeWidth, height);
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self) {
        CGFloat pageWidth = self.frame.size.width;
        NSUInteger page = floor((self.contentOffset.x - (pageWidth + kImageOffset) / 2.0f) / (pageWidth + kImageOffset)) + 1;
        self.pageControl.currentPage = page;
        
        CGFloat height = 30;
        CGFloat width = self.frame.size.width;
        CGRect pageControlRect = CGRectMake(scrollView.contentOffset.x,
                                            5,
                                            width,
                                            height);
        
        self.pageControl.frame = pageControlRect;
    }
}

- (void)changePage:(UIPageControl *)pageControl
{
    CGRect imagesFrame = self.frame;
    imagesFrame.origin.x = imagesFrame.size.width * pageControl.currentPage;
    imagesFrame.origin.y = 0;
    [self scrollRectToVisible:imagesFrame animated:YES];
    
}

#pragma mark - Setters

- (void)setImageURLs:(NSArray *)imageURLs
{
    if (_imageURLs != imageURLs) {
        _imageURLs = imageURLs;
        
        [self updateUI];
        [self setupPageControl];
    }
}

- (void)setImages:(NSArray *)images
{
    if (_images != images) {
        _images = images;
        
        [self updateUI];
        [self setupPageControl];
    }
}

- (void)setCustomViews:(NSArray<UIView *> *)customViews
{
    if (_customViews != customViews) {
        _customViews = customViews;
        
        [self updateUI];
        [self setupPageControl];
    }
}

#pragma mark - Getters

- (NSArray *)proxyData
{
    if (self.images != nil) {
        return self.images;
    }
    if (self.imageURLs != nil) {
        return self.imageURLs;
    }
    if (self.customViews != nil) {
        return self.customViews;
    }
    return nil;
}

#pragma mark - Private Methods

- (void)setupPageControl
{
    [self.pageControl removeFromSuperview];
    self.pageControl = nil;
    
    CGRect pageControlRect = CGRectMake(0, 5, self.bounds.size.width, kPageControlHeight);
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:pageControlRect];
    self.pageControl.numberOfPages = [self proxyData].count;
    self.pageControl.currentPage = 0;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:kPageControlHeight]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.0f]];
}


#pragma mark - Parallax

- (void)addParallaxToScrollView:(nonnull UIScrollView *)scrollView aspectRatio:(CGFloat)aspectRatio minHeight:(CGFloat)minHeight maxHeight:(CGFloat)maxHeight;
{
    CGFloat desiredHeight = scrollView.bounds.size.width * aspectRatio;
    CGFloat finalHeight = MIN(desiredHeight, maxHeight);
    finalHeight = MAX(finalHeight, minHeight);
    
    [self addParallaxToScrollView:scrollView height:finalHeight];
}

- (void)addParallaxToScrollView:(nonnull UIScrollView *)scrollView height:(CGFloat)height;
{
    [scrollView setParallaxHeaderView:self
                                 mode:VGParallaxHeaderModeTopFill
                               height:height];
}

- (void)scrollViewScrolled:(UIScrollView *)scrollView;
{
    [scrollView shouldPositionParallaxHeader];
}


@end




















@implementation UIImageView (SimpleImageSlider)

- (void)setImageAnimated:(UIImage *)image
{
    [UIView transitionWithView:self
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ self.image = image; }
                    completion:nil];
}

- (void)setImageAnimatedWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder;
{
    __block UIImageView *weakSelf = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];

    [self setImageWithURLRequest:request
                placeholderImage:placeholder
                         success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) { [weakSelf setImageAnimated:image]; }
                         failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) { [weakSelf setImageAnimated:placeholder]; }];
}

@end


















