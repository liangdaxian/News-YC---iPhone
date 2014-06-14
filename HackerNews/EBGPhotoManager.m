//
//  EBGPhotoManager.m
//  Edentity
//
//  Created by Ji Liang on 2/17/14.
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

#import "EBGPhotoManager.h"
#import "UIUtil.h"


#define BLUR_IMAGE_SCALE 0.5
#define BLUR_RADIUS 9.0
#define BLUR_JPEG_QUALITY 0.8


@implementation EBGPhotoManager
static EBGPhotoManager *sharedManager = nil;

+ (EBGPhotoManager *) sharedManager {
    @synchronized (self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    
    return sharedManager;
}

- (id) init {
	self = [super init];
    self.stockPhotoSet = [NSMutableArray array];
    if (self != nil) {
        [self load];
	}
	return self;
}

- (void) load {
    // show default images
    NSArray *files = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"EDefulatBGPhotos"];
    for (NSString* path in files) {
        [self.stockPhotoSet addObject:[UIImage imageWithContentsOfFile:path]];
    }
}


- (void)setBackgroudImageWithImage:(UIImage*)image andRomoveAllOtherImages:(BOOL)removeAll{
    
    if (removeAll == YES) {
        [self.stockPhotoSet removeAllObjects];
    }
    [self.stockPhotoSet addObject:image];
    
}

- (void)setBackgroudImageWithImageArray:(NSArray*)imageArray andRomoveAllOtherImages:(BOOL)removeAll{
    
    if (removeAll == YES) {
        [self.stockPhotoSet removeAllObjects];
    }
    [self.stockPhotoSet addObjectsFromArray:imageArray];
}


- (int) getRandomIntBetweenLow:(int) low andHigh:(int) high {
	return ((arc4random() % (high - low + 1)) + low);
}

- (void) randomStockPhoto: (void (^)(NSDictionary *)) completion {
    
    dispatch_queue_t main = dispatch_get_main_queue();
    
    UIImage* origImage = nil;
    UIImage* blurImage = nil;
    
    int stockPhotoCount = ([self.stockPhotoSet count] - 1);
    
    int randomIndex = 0;
    int MaxAttamp = 10;
    
    BOOL findOne = NO;
    while (!findOne && MaxAttamp >0) {
        randomIndex = [self getRandomIntBetweenLow:0 andHigh:stockPhotoCount];
        if (randomIndex >=0 && randomIndex < self.stockPhotoSet.count) {
            origImage  = [self.stockPhotoSet objectAtIndex:randomIndex];
            findOne = YES;
            blurImage  = [self makeBlurImageWithImage:origImage];
        }
        MaxAttamp--;
    }
    if (!findOne) {
        origImage = [UIImage imageNamed:@"background.jpg"];
        blurImage  = [self makeBlurImageWithImage:origImage];
    }
    dispatch_async(main, ^{
        completion([[NSDictionary alloc] initWithObjectsAndKeys:origImage, @"original",
                    blurImage, @"blurred",
                    nil]);
    });
}

-(UIImage* )makeBlurImageWithImage:(UIImage*)origImage{
    
    NSLog(@"image w=%f h=%f", origImage.size.width, origImage.size.height);
    //double blurBegin = CACurrentMediaTime();
    // scale down image so that blur is faster
    CGSize newSize = CGSizeMake(round(origImage.size.width * BLUR_IMAGE_SCALE),
                                round(origImage.size.height * BLUR_IMAGE_SCALE));
    
    UIImage *newImage = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(nil, newSize.width, newSize.height, 8, newSize.width * 4, colorSpace, kCGImageAlphaNoneSkipLast);
    if (imageContext) {
        CGContextDrawImage(imageContext, CGRectMake(0, 0, newSize.width, newSize.height), origImage.CGImage);
        CGImageRef finalImageRef = CGBitmapContextCreateImage(imageContext);
        if (finalImageRef) {
            newImage = [UIImage imageWithCGImage:finalImageRef];
            CGImageRelease(finalImageRef);
        }
        CGContextRelease(imageContext);
    }
    CGColorSpaceRelease(colorSpace);
    
    if (newImage == nil) {
        // should not happen, but just in case, don't fail
        NSLog(@"warning, problem resizing image to blur");
        newImage = origImage;
    }
    
    // perform the blur on the smaller image (still on the response processing thread)
    UIImage *blurImage = BlurImage(newImage, (NSUInteger)round(BLUR_RADIUS / BLUR_IMAGE_SCALE));
    return blurImage;
}


UIImage *BlurImage(UIImage *image, NSUInteger rad)
{
    int radius=rad;
    
    if (radius <1) {
        NSLog(@"stack blur radius must be > 0");
        return nil;
    }
    if (image.size.width == 0 || image.size.height == 0) {
        NSLog(@"zero pixel image passed to stack blur");
        return nil;
    }
    
    CGImageRef inImage = image.CGImage;
    if (CGImageGetBitsPerPixel(inImage) != 32) {
        NSLog(@"stack blur image must be 32 bit image");
        return nil;
    }
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    UInt8 * pixels=malloc(CFDataGetLength(data));
    CFDataGetBytes(data, CFRangeMake(0,CFDataGetLength(data)), pixels);
    
	CGContextRef ctx = CGBitmapContextCreate(pixels,
											 CGImageGetWidth(inImage),
											 CGImageGetHeight(inImage),
											 CGImageGetBitsPerComponent(inImage),
											 CGImageGetBytesPerRow(inImage),
											 CGImageGetColorSpace(inImage),
											 CGImageGetBitmapInfo(inImage)
											 );
    
	int w=CGImageGetWidth(inImage);
	int h=CGImageGetHeight(inImage);
	int wm=w-1;
	int hm=h-1;
	int wh=w*h;
	int div=radius+radius+1;
    
	int *r=malloc(wh*sizeof(int));
	int *g=malloc(wh*sizeof(int));
	int *b=malloc(wh*sizeof(int));
	memset(r,0,wh*sizeof(int));
	memset(g,0,wh*sizeof(int));
	memset(b,0,wh*sizeof(int));
	int rsum,gsum,bsum,x,y,i,p,yp,yi,yw;
	int *vmin = malloc(sizeof(int)*MAX(w,h));
	memset(vmin,0,sizeof(int)*MAX(w,h));
	int divsum=(div+1)>>1;
	divsum*=divsum;
	int *dv=malloc(sizeof(int)*(256*divsum));
	for (i=0;i<256*divsum;i++){
		dv[i]=(i/divsum);
	}
    
	yw=yi=0;
    
	int *stack=malloc(sizeof(int)*(div*3));
	int stackpointer;
	int stackstart;
	int *sir;
	int rbs;
	int r1=radius+1;
	int routsum,goutsum,boutsum;
	int rinsum,ginsum,binsum;
	memset(stack,0,sizeof(int)*div*3);
    
	for (y=0;y<h;y++){
		rinsum=ginsum=binsum=routsum=goutsum=boutsum=rsum=gsum=bsum=0;
        
		for(int i=-radius;i<=radius;i++){
			sir=&stack[(i+radius)*3];
			int offset=(yi+MIN(wm,MAX(i,0)))*4;
			sir[0]=pixels[offset];
			sir[1]=pixels[offset+1];
			sir[2]=pixels[offset+2];
            
			rbs=r1-abs(i);
			rsum+=sir[0]*rbs;
			gsum+=sir[1]*rbs;
			bsum+=sir[2]*rbs;
			if (i>0){
				rinsum+=sir[0];
				ginsum+=sir[1];
				binsum+=sir[2];
			} else {
				routsum+=sir[0];
				goutsum+=sir[1];
				boutsum+=sir[2];
			}
		}
		stackpointer=radius;
        
		for (x=0;x<w;x++){
			r[yi]=dv[rsum];
			g[yi]=dv[gsum];
			b[yi]=dv[bsum];
            
			rsum-=routsum;
			gsum-=goutsum;
			bsum-=boutsum;
            
			stackstart=stackpointer-radius+div;
			sir=&stack[(stackstart%div)*3];
            
			routsum-=sir[0];
			goutsum-=sir[1];
			boutsum-=sir[2];
            
			if(y==0){
				vmin[x]=MIN(x+radius+1,wm);
			}
            
			int offset=(yw+vmin[x])*4;
			sir[0]=pixels[offset];
			sir[1]=pixels[offset+1];
			sir[2]=pixels[offset+2];
			rinsum+=sir[0];
			ginsum+=sir[1];
			binsum+=sir[2];
            
			rsum+=rinsum;
			gsum+=ginsum;
			bsum+=binsum;
            
			stackpointer=(stackpointer+1)%div;
			sir=&stack[((stackpointer)%div)*3];
            
			routsum+=sir[0];
			goutsum+=sir[1];
			boutsum+=sir[2];
            
			rinsum-=sir[0];
			ginsum-=sir[1];
			binsum-=sir[2];
            
			yi++;
		}
		yw+=w;
	}
	for (x=0;x<w;x++){
		rinsum=ginsum=binsum=routsum=goutsum=boutsum=rsum=gsum=bsum=0;
		yp=-radius*w;
		for(i=-radius;i<=radius;i++){
			yi=MAX(0,yp)+x;
            
			sir=&stack[(i+radius)*3];
            
			sir[0]=r[yi];
			sir[1]=g[yi];
			sir[2]=b[yi];
            
			rbs=r1-abs(i);
            
			rsum+=r[yi]*rbs;
			gsum+=g[yi]*rbs;
			bsum+=b[yi]*rbs;
            
			if (i>0){
				rinsum+=sir[0];
				ginsum+=sir[1];
				binsum+=sir[2];
			} else {
				routsum+=sir[0];
				goutsum+=sir[1];
				boutsum+=sir[2];
			}
            
			if(i<hm){
				yp+=w;
			}
		}
		yi=x;
		stackpointer=radius;
		for (y=0;y<h;y++){
			int offset=yi*4;
			pixels[offset]=dv[rsum];
			pixels[offset+1]=dv[gsum];
			pixels[offset+2]=dv[bsum];
			rsum-=routsum;
			gsum-=goutsum;
			bsum-=boutsum;
            
			stackstart=stackpointer-radius+div;
			sir=&stack[(stackstart%div)*3];
            
			routsum-=sir[0];
			goutsum-=sir[1];
			boutsum-=sir[2];
            
			if(x==0){
				vmin[y]=MIN(y+r1,hm)*w;
			}
			p=x+vmin[y];
            
			sir[0]=r[p];
			sir[1]=g[p];
			sir[2]=b[p];
            
			rinsum+=sir[0];
			ginsum+=sir[1];
			binsum+=sir[2];
            
			rsum+=rinsum;
			gsum+=ginsum;
			bsum+=binsum;
            
			stackpointer=(stackpointer+1)%div;
			sir=&stack[(stackpointer)*3];
            
			routsum+=sir[0];
			goutsum+=sir[1];
			boutsum+=sir[2];
            
			rinsum-=sir[0];
			ginsum-=sir[1];
			binsum-=sir[2];
            
			yi+=w;
		}
	}
	free(r);
	free(g);
	free(b);
	free(vmin);
	free(dv);
	free(stack);
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
    
	UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CFRelease(data);
    free(pixels);
	return finalImage;
}


-(void)clearImagesCache
{
   // method imageWithContentsOfFile and imageNamed don't have any image cache ,so just empty the array
    [self.stockPhotoSet removeAllObjects];
}
@end
