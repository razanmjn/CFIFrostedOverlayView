//
//  CFIFrostedOverlayView.m
//  CFIFrostedOverlayView
//
//  Created by Robert Widmann on 6/16/13.
//  Copyright (c) 2013 CodaFi. All rights reserved.
//

#import "CFIFrostedOverlayView.h"
#import <QuartzCore/QuartzCore.h>
#import <GPUImage.h>

@implementation CFILayerDelegate
-(id) initWithLayer:(CALayer *)view {
    self = [super init];
	_layer = view;
	_layer.delegate = self;
    return self;
}
- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event { return (id)NSNull.null; }
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
	if (ctx == NULL) return;
	if (self.drawRect != NULL) self.drawRect(_layer, ctx);
}
@end

@interface CFIFrostedOverlayView ()
@property (nonatomic, strong) CFILayerDelegate *layerDelegate;
@property (nonatomic, strong) CALayer *blurredLayer;
@end

@implementation CFIFrostedOverlayView

- (id)init {
	return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	self.backgroundColor = UIColor.whiteColor;
	self.clipsToBounds = YES;

	self.blurredLayer = CALayer.layer;
	self.blurredLayer.frame = self.bounds;
	[self.layer addSublayer:self.blurredLayer];
	
	self.layerDelegate = [[CFILayerDelegate alloc]initWithLayer:self.blurredLayer];
	
	self.tintLayer = [CALayer layer];
	self.tintLayer.frame = self.bounds;
	[self.tintLayer setBackgroundColor:[UIColor colorWithWhite:1.000 alpha:0.300].CGColor];
	[self.layer addSublayer:self.tintLayer];
	
	return self;
}

- (void)awakeFromNib {
	self.backgroundColor = UIColor.whiteColor;
	self.clipsToBounds = YES;
	
	self.blurredLayer = CALayer.layer;
	self.blurredLayer.frame = self.bounds;
	[self.layer addSublayer:self.blurredLayer];
	
	self.layerDelegate = [[CFILayerDelegate alloc]initWithLayer:self.blurredLayer];
	
	self.tintLayer = [CALayer layer];
	self.tintLayer.frame = self.bounds;
	[self.tintLayer setBackgroundColor:[UIColor colorWithWhite:1.000 alpha:0.300].CGColor];
	[self.layer addSublayer:self.tintLayer];
}

- (void)setViewToBlur:(UIView *)viewToBlur {
	_viewToBlur = viewToBlur;
	__weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		__strong __typeof(self) self = weakSelf;
        GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
        filter.blurSize = UIScreen.mainScreen.scale * 9;
		UIImage *image = CFIImageFromView(self.viewToBlur);
		self.blurredLayer.contents = (id)[filter imageByFilteringImage:image].CGImage;
    });
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	CGRect convertedRect = [self convertRect:self.bounds fromView:self.superview];
	self.blurredLayer.frame = (CGRect){ .origin.y = convertedRect.origin.y, .size.height = frame.size.height + self.offset, .size.width = frame.size.width };
	self.tintLayer.frame = self.bounds;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
}

static UIImage *CFIImageFromView(UIView *view) {
	CGSize size = view.bounds.size;
    
    CGFloat scale = UIScreen.mainScreen.scale;
    size.width *= scale;
    size.height *= scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(ctx, scale, scale);
	
    [view.layer renderInContext:ctx];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
