/**
	YImageView.h
	Weather
	
	Copyright 2012 Yahoo, Inc. All rights reserved.
*/

#import <UIKit/UIKit.h>

/**
 * Image view cross-fades when a new (different) image is set.
 * - initial image set will not animate.
 * - if an new image is set during animation, the animation will complete and the next 
 *   image cross faded in afterwards
 */

@interface
CrossFadeImageView : UIView
{
    UIImageView *_currentImageView; 
    UIImageView *_newImageView;
    BOOL        _animating;
    UIImage     *_nextImage;
}

// set the image, specifying whether or not to animate
- (void)setImage:(UIImage*)image animate:(bool)animate;

// set the image
- (void)setImage:(UIImage*)image;

//// setting this image will animate a cross fade from previous image (if exists)
//@property (nonatomic, strong) UIImage *image;

// returns YES if any image is displayed
- (BOOL)isImageDisplayed;

@end
