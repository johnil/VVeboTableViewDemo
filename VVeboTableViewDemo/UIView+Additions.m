//
//  UIView+Additions.m
//  Additions
//
//  Created by Johnil on 13-6-7.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@implementation UIView (Additions)

- (float)boundsWidth{
    return self.bounds.size.width;
}

- (float)boundsHeight{
    return self.bounds.size.width;
}

- (void)setBoundsWidth:(float)w{
    CGRect frame = self.bounds;
    frame.size.width = w;
    self.bounds = frame;
}

- (void)setBoundsHeight:(float)h{
    CGRect frame = self.bounds;
    frame.size.height = h;
    self.bounds = frame;
}

- (float)x{
    return self.frame.origin.x;
}

- (float)y{
    return self.frame.origin.y;
}

- (float)width{
    return self.frame.size.width;
}

- (float)height{
    return self.frame.size.height;
}

- (void)setX:(float)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(float)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setWidth:(float)w{
    CGRect frame = self.frame;
    frame.size.width = w;
    self.frame = frame;
}

- (void)setHeight:(float)h{
    CGRect frame = self.frame;
    frame.size.height = h;
    self.frame = frame;
}

//- (void)fadeIn{
//    [self fadeInOnComplet:nil];
//}
//
//- (void)fadeOut{
//    [self fadeOutOnComplet:nil];
//}
//
//- (void)fadeInOnComplet:(void(^)(BOOL finished))complet{
//    self.alpha = 0;
//    [UIView animateWithDuration:.18 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//		self.alpha = 1;
//	} completion:complet];
//}
//
//- (void)fadeOutOnComplet:(void(^)(BOOL finished))complet{
//    [UIView animateWithDuration:.18 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//        self.alpha = 0;
//    } completion:complet];
//	if ([UIView areAnimationsEnabled]) {
//		[UIView setAnimationsEnabled:YES];
//	}
//}
//
//- (void)removeAllSubviews{
//    for (UIView *temp in self.subviews) {
//        [temp removeFromSuperview];
//    }
//}
//
//- (void)removeSubviewWithTag:(NSInteger)tag{
//    for (UIView *temp in self.subviews) {
//        if (temp.tag==tag) {
//            [temp removeFromSuperview];
//        }
//    }
//}
//
//- (void)removeSubviewExceptTag:(NSInteger)tag{
//    for (UIView *temp in self.subviews) {
//        if (temp.tag!=tag) {
//			if ([temp isKindOfClass:[UIImageView class]]) {
//				[(UIImageView *)temp setImage:nil];
//			}
//            [temp removeFromSuperview];
//        }
//    }
//}
//
//- (void)removeSubviewExceptClass:(Class)class{
//    for (UIView *temp in self.subviews) {
//        if (![temp isKindOfClass:class]) {
//            [temp removeFromSuperview];
//        }
//    }
//}
//
//- (UIView *)addLine:(UIColor *)color frame:(CGRect)frame{
//    UIView *line = [[UIView alloc] initWithFrame:frame];
//    line.backgroundColor = color;
//    [self addSubview:line];
//    return line;
//}
//
//- (UIImage *)toImage{
//    return [self toImagewhithAlpha:NO];
//}
//
//- (UIImage *)toRetinaImageRealTime{
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *screenShotimage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return screenShotimage;
//}
//
//- (UIImage *)toRetinaImage{
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
//	[self drawViewHierarchyInRect:self.bounds
//               afterScreenUpdates:NO];
//    UIImage *screenShotimage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return screenShotimage;
//}
//
//- (UIImage *)toAlphaRetinaImageRealTime{
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *screenShotimage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return screenShotimage;
//}
//
//- (UIImage *)toAlphaRetinaImage{
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
//	[self drawViewHierarchyInRect:self.bounds
//               afterScreenUpdates:NO];
//    UIImage *screenShotimage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return screenShotimage;
//}
//
//- (UIImage *)toImagewhithAlpha:(BOOL)alpha{
//	NSInteger scale = ([UIDevice isiPhone4]||[UIDevice isiPad])?5:2.5;
//    CGSize size = CGSizeMake((NSInteger)(self.width/scale), (NSInteger)self.height/scale);
//	UIGraphicsBeginImageContextWithOptions(size, !alpha, 1);
//	[self drawViewHierarchyInRect:CGRectMake(0, 0, size.width, size.height)
//               afterScreenUpdates:NO];
//	UIImage *screenShotimage = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//    return [screenShotimage normalize];
//}
//
//- (UIImage *)toImageWithRect:(CGRect)frame{
//    return [self toImageWithRect:frame withAlpha:NO];
//}
//
//- (void)addBorder{
//	UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, .5)];
//	line.backgroundColor = [VVeboConfigCenter defaultCenter].color_RepostBorder;
//	[self addSubview:line];
//
//	UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-.5, self.width, .5)];
//	line2.backgroundColor = [VVeboConfigCenter defaultCenter].color_RepostBorder;
//	[self addSubview:line2];
//
//	UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, .5, self.height)];
//	line3.backgroundColor = [VVeboConfigCenter defaultCenter].color_RepostBorder;
//	[self addSubview:line3];
//
//	UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(self.width-.5, 0, .5, self.height)];
//	line4.backgroundColor = [VVeboConfigCenter defaultCenter].color_RepostBorder;
//	[self addSubview:line4];
//}
//
//- (UIImage *)toImageWithRect:(CGRect)frame withAlpha:(BOOL)alpha{
//    UIGraphicsBeginImageContextWithOptions(frame.size, !alpha, 1);//这里通过设置scale为1来截取{[UIScreen screenWidth], 49}大小的图,而不是在retina下截取2x大小的图
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-frame.origin.x, -frame.origin.y));
//    [self.layer renderInContext:context];
//    UIImage *screenShot1 = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return screenShot1;
//}
//
//- (UIImage *)visbleToImage{
//	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//	if ([self isKindOfClass:[UIScrollView class]]) {
//		CGPoint offset=[(UIScrollView *)self contentOffset];
//		CGContextTranslateCTM(context, -offset.x, -offset.y);
//	}
////	[self.layer renderInContext:context];
//	[self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
//	UIImage *visibleScrollViewImage = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//	return visibleScrollViewImage;
//}
//
//- (void)addWhiteViewWithAlpha:(float)alpha{
//    UIView *white = [[UIView alloc] initWithFrame:CGRectChangeOrigin(self.frame, CGPointZero)];
//    white.backgroundColor = [UIColor whiteColor];
//    white.alpha = alpha;
//    [self addSubview:white];
//}
//
//- (void)addWhiteView{
//	[self addWhiteViewWithAlpha:.8];
//}
//
//- (void)addBlackView{
//    UIView *black = [[UIView alloc] initWithFrame:CGRectChangeOrigin(self.frame, CGPointZero)];
//    black.backgroundColor = [UIColor blackColor];
//    black.alpha = .85;
//    [self addSubview:black];
//}
//
//- (void)addShadowWithAlpha:(float)alpha{
//	UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 5, self.bounds.size.width, self.bounds.size.height)];
//	[self.layer setShadowColor:[UIColor grayColor].CGColor];
//	[self.layer setShadowOpacity:alpha];
//	[self.layer setShadowRadius:10.0f];
//	[self.layer setShadowPath:[path CGPath]];
//}
//
//- (void)addShadow{
//	[self addShadowWithAlpha:1];
//}
//
//- (void)addShadowWithColor:(UIColor *)color{
//	UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 5, self.bounds.size.width, self.bounds.size.height)];
//	[self.layer setShadowColor:color.CGColor];
//	[self.layer setShadowOpacity:1];
//	[self.layer setShadowRadius:10.0f];
//	[self.layer setShadowPath:[path CGPath]];
//}
//
//- (void)removeShadow{
//	self.layer.shadowOpacity = 0;
//	self.layer.shadowRadius = 0;
//}
//
//- (UIView *)findAndResignFirstResponder{
//    if (self.isFirstResponder) {
//        return self;
//    }
//    for (UIView *subView in self.subviews) {
//        UIView *temp = [subView findAndResignFirstResponder];
//        if (temp!=nil) {
//            return temp;
//        }
//    }
//    return nil;
//}
//
//- (void)addCorner{
//    UIImageView *cornder = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"corner.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)]];
//    cornder.contentMode = UIViewContentModeScaleAspectFit;
//    cornder.frame = CGRectMake(0, 0, self.width, self.height);
//    [self addSubview:cornder];
//}
//
//- (void)shake:(float)range{
//	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    animation.duration = 0.5;
//    animation.values = @[ @(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0) ];
//    [self.layer addAnimation:animation forKey:@"shake"];
//}
//
//- (void)shakeRepeat:(float)range{
//	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    animation.duration = 0.6;
//    animation.values = @[ @(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0) ];
//	animation.repeatCount = NSIntegerMax;
//    [self.layer addAnimation:animation forKey:@"shake"];
//}
//
//- (void)shakeX:(float)range{
//	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    animation.duration = 0.6;
//    animation.values = @[ @(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0) ];
//    [self.layer addAnimation:animation forKey:@"shake"];
//}
//
//- (void)rasterize{
//	self.layer.shouldRasterize = YES;
//	self.layer.rasterizationScale = [UIScreen scale];
//}
//
//+ (void)vveboAnimations:(void (^)(void))animations{
//	[UIView vveboAnimateWithDuration:.18 delay:0 animations:animations completion:nil];
//}
//
//+ (void)vveboAnimations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion{
//	[UIView vveboAnimateWithDuration:.18 delay:0 animations:animations completion:completion];
//}
//
//+ (void)vveboAnimateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations{
//	[UIView vveboAnimateWithDuration:duration delay:0 animations:animations completion:nil];
//}
//
//+ (void)vveboAnimateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion{
//	[UIView vveboAnimateWithDuration:duration delay:0 animations:animations completion:completion];
//}
//
//+ (void)vveboAnimateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion{
//	[UIView vveboAnimateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:animations completion:completion];
//}
//
//+ (void)vveboAnimateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion{
//	if (![UIView areAnimationsEnabled]) {
//		[UIView setAnimationsEnabled:YES];
//	}
//	[UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//	if (self.touchBeganBlock) {
//		self.touchBeganBlock([touches anyObject], self);
//	}
//	[super touchesBegan:touches withEvent:event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//	if (self.touchEndBlock) {
//		self.touchEndBlock([touches anyObject], self);
//	}
//	[super touchesEnded:touches withEvent:event];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//	if (self.touchMoveBlock) {
//		self.touchMoveBlock([touches anyObject], self);
//	}
//	[super touchesMoved:touches withEvent:event];
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//	if (self.touchEndBlock) {
//		self.touchEndBlock([touches anyObject], self);
//	}
//	[super touchesCancelled:touches withEvent:event];
//}
//
//- (void)addLine:(CGRect)rect{
//	UIColor *color = self.lineColor;
//	if (self.lineColor==nil) {
//		color = [UIColor grayColor];
//	}
//	UIView *line = [[UIView alloc] initWithFrame:rect];
//	line.backgroundColor = color;
//	[self addSubview:line];
//}
//
//- (BOOL)hasActionSheetOrAlert{
//    if ([self isKindOfClass:[UIAlertView class]]||[self isKindOfClass:[UIActionSheet class]]) {
//        return YES;
//    }
//    for (UIView *subView in self.subviews) {
//        BOOL temp = [subView hasActionSheetOrAlert];
//        if (temp) {
//            return temp;
//        }
//    }
//    return NO;
//}
//
//- (UIView *)subviewWithTag:(NSInteger)tag{
//    for (UIView *temp in self.subviews) {
//        if (temp.tag==tag) {
//            return temp;
//        }
//    }
//    return nil;
//}

@end
