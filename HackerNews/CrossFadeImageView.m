/**
	YImageView.m
	
	Created by Roderick Mann on 10/17/11.
	Copyright 2011 Yahoo, Inc. All rights reserved.
*/

#import "CrossFadeImageView.h"

//	Project Imports
//#import "YWUtils.h"

@implementation CrossFadeImageView

- (void)awakeFromNib
{	
	self.backgroundColor = [UIColor clearColor];
	
	_currentImageView = [[UIImageView alloc] init];
	_currentImageView.backgroundColor = [UIColor clearColor];
	_currentImageView.contentMode = UIViewContentModeScaleAspectFill;
	_currentImageView.clipsToBounds = true;
	_currentImageView.alpha = 1.0f;
	[self addSubview: _currentImageView];
	
	_newImageView = [[UIImageView alloc] init];
	_newImageView.backgroundColor = [UIColor clearColor];
	_newImageView.contentMode = UIViewContentModeScaleAspectFill;
	_newImageView.clipsToBounds = true;
	_newImageView.alpha = 0.0f;
	[self addSubview: _newImageView];
}

- (void)layoutSubviews
{
    [_currentImageView setFrame:self.bounds];
    [_newImageView     setFrame:self.bounds];
    [super layoutSubviews];
}

// returns YES if any image is displayed
- (BOOL)isImageDisplayed
{
    return _currentImageView.image != nil;
}


// animate by default
-(void) setImage:(UIImage*)image
{
    [self setImage:image animate:YES];
}

- (void) setImage:(UIImage*)image animate:(bool)animate
{
	NSAssert([NSThread isMainThread], @"Calling -setImage: off main thread!");
	//NSLog(@"xfadeview setimage, currentimage is %@", _currentImageView.image);
    // immediately reset if nil passed
    if (image == nil) {
        _newImageView.image = nil;
        _currentImageView.image = nil;
        _currentImageView.alpha = 1.0f;
        _newImageView.alpha = 0.0f;
        _nextImage = nil;
        _animating = NO;
        return;
    }
    
    // image to be set is either current
	if ((_currentImageView.image == image && !_animating) || (_newImageView.image == image && _animating)) {
		return;
	}
    
    // only animate if there was no image to start with and new image is not empty
    if (!animate || _currentImageView.image == nil || image == nil) {
        NSLog(@"immediately setting image to %@", image);
        _currentImageView.image = image;
        _newImageView.image = image;
        _animating = false;
        _nextImage = nil;
        _currentImageView.alpha = 1.0f;
        _newImageView.alpha = 0.0f;
        return;
    }
	
    // if animating, keep next image for when animation is over (will animate again)
	if (_animating) {
        //NSLog(@"was animating, keeping image for next");
		_nextImage = image;
		return;
	}
	
	// Cross-fade in the new image
	_newImageView.image = image;
	_animating = true;
    
    //NSLog(@"animating image to %@", image);
    
	[UIView animateWithDuration: 2.0f
                          delay: 0.0f
                        options: UIViewAnimationOptionAllowUserInteraction
                     animations:
     ^{
         _newImageView.alpha = 1.0f;
     }
                     completion:
     ^(BOOL finished)
     {
         if (finished) {
             _currentImageView.image = _newImageView.image;
             _currentImageView.alpha = 1.0f;
             _newImageView.alpha = 0.0f;
             
             _animating = false;
             
             if (_nextImage != nil) {
                 [self setImage:_nextImage animate:YES];
                 _nextImage = nil;
             }
         }
     }];
}

@end
