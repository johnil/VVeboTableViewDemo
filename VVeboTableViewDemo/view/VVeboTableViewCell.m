//
//  VVeboTableViewCell.m
//  VVeboTableViewDemo
//
//  Created by Johnil on 15/5/25.
//  Copyright (c) 2015年 Johnil. All rights reserved.
//

#import "VVeboTableViewCell.h"
#import "UIView+Additions.h"
#import "UIScreen+Additions.h"
#import "NSString+Additions.h"
#import "VVeboLabel.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@implementation VVeboTableViewCell {
    UIImageView *postBGView;
    UIButton *avatarView;
    UIImageView *cornerImage;
    UIView *topLine;
    VVeboLabel *label;
    VVeboLabel *detailLabel;
    UIScrollView *mulitPhotoScrollView;
    BOOL drawed;
    NSInteger drawColorFlag;
    CGRect commentsRect;
    CGRect repostsRect;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        postBGView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView insertSubview:postBGView atIndex:0];
        
        avatarView = [UIButton buttonWithType:UIButtonTypeCustom];//[[VVeboAvatarView alloc] initWithFrame:avatarRect];
        avatarView.frame = CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_TOP, SIZE_AVATAR, SIZE_AVATAR);
        avatarView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
        avatarView.hidden = NO;
        avatarView.tag = NSIntegerMax;
        avatarView.clipsToBounds = YES;
        [self.contentView addSubview:avatarView];
        
        cornerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SIZE_AVATAR+5, SIZE_AVATAR+5)];
        cornerImage.center = avatarView.center;
        cornerImage.image = [UIImage imageNamed:@"corner_circle@2x.png"];
        cornerImage.tag = NSIntegerMax;
        [self.contentView addSubview:cornerImage];
        
        topLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-.5, [UIScreen screenWidth], .5)];
        topLine.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
        topLine.tag = NSIntegerMax;
        [self.contentView addSubview:topLine];
        
        self.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
        
        [self addLabel];
        
        mulitPhotoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        mulitPhotoScrollView.scrollsToTop = NO;
        mulitPhotoScrollView.showsHorizontalScrollIndicator = NO;
        mulitPhotoScrollView.showsVerticalScrollIndicator = NO;
        mulitPhotoScrollView.tag = NSIntegerMax;
        mulitPhotoScrollView.hidden = YES;
        [self.contentView addSubview:mulitPhotoScrollView];
        int h2 = SIZE_GAP_IMG+SIZE_IMAGE;
        for (NSInteger i=0; i<9; i++) {
            int g = SIZE_GAP_IMG;
            int width = SIZE_IMAGE;
            float x = SIZE_GAP_LEFT+(g+width)*(i%3);
            float y = i/3*h2;
            UIImageView *thumb1 = [[UIImageView alloc] initWithFrame:CGRectMake(x, y+2, SIZE_IMAGE, SIZE_IMAGE)];
            thumb1.tag = i+1;
            [mulitPhotoScrollView addSubview:thumb1];
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.contentView bringSubviewToFront:topLine];
    topLine.y = self.height-.5;
}

- (void)setData:(NSDictionary *)data{
    _data = data;
    [avatarView setBackgroundImage:nil forState:UIControlStateNormal];
    if ([data valueForKey:@"avatarUrl"]) {
        NSURL *url = [NSURL URLWithString:[data valueForKey:@"avatarUrl"]];
        [avatarView sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:nil options:SDWebImageLowPriority];
    }
}

- (void)addLabel{
    if (label) {
        [label removeFromSuperview];
        label = nil;
    }
    if (detailLabel) {
        detailLabel = nil;
    }
    label = [[VVeboLabel alloc] initWithFrame:[_data[@"textRect"] CGRectValue]];
    label.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1];
    label.backgroundColor = self.backgroundColor;
    [self.contentView addSubview:label];
    
    detailLabel = [[VVeboLabel alloc] initWithFrame:[_data[@"subTextRect"] CGRectValue]];
    detailLabel.font = FontWithSize(SIZE_FONT_SUBCONTENT);
    detailLabel.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1];;
    detailLabel.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    [self.contentView addSubview:detailLabel];
}

//将主要内容绘制到图片上
- (void)draw{
    if (drawed) {
        return;
    }
    NSInteger flag = drawColorFlag;
    drawed = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect rect = [_data[@"frame"] CGRectValue];
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
        CGContextFillRect(context, rect);
        if ([_data valueForKey:@"subData"]) {
            [[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1] set];
            CGRect subFrame = [_data[@"subData"][@"frame"] CGRectValue];
            CGContextFillRect(context, subFrame);
            [[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1] set];
            CGContextFillRect(context, CGRectMake(0, subFrame.origin.y, rect.size.width, .5));
        }
        
        {
            float leftX = SIZE_GAP_LEFT+SIZE_AVATAR+SIZE_GAP_BIG;
            float x = leftX;
            float y = (SIZE_AVATAR-(SIZE_FONT_NAME+SIZE_FONT_SUBTITLE+6))/2-2+SIZE_GAP_TOP+SIZE_GAP_SMALL-5;
            [_data[@"name"] drawInContext:context withPosition:CGPointMake(x, y) andFont:FontWithSize(SIZE_FONT_NAME)
                             andTextColor:[UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1]
                                andHeight:rect.size.height];
            y += SIZE_FONT_NAME+5;
            float fromX = leftX;
            float size = [UIScreen screenWidth]-leftX;
            NSString *from = [NSString stringWithFormat:@"%@  %@", _data[@"time"], _data[@"from"]];
            [from drawInContext:context withPosition:CGPointMake(fromX, y) andFont:FontWithSize(SIZE_FONT_SUBTITLE)
                   andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1]
                      andHeight:rect.size.height andWidth:size];
        }
        
        {
            CGRect countRect = CGRectMake(0, rect.size.height-30, [UIScreen screenWidth], 30);
            [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
            CGContextFillRect(context, countRect);
            float alpha = 1;
            
            float x = [UIScreen screenWidth]-SIZE_GAP_LEFT-10;
            NSString *comments = _data[@"comments"];
            if (comments) {
                CGSize size = [comments sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:FontWithSize(SIZE_FONT_SUBTITLE) lineSpace:5];
                
                x -= size.width;
                [comments drawInContext:context withPosition:CGPointMake(x, 8+countRect.origin.y)
                                andFont:FontWithSize(12)
                           andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1]
                              andHeight:rect.size.height];
                [[UIImage imageNamed:@"t_comments.png"] drawInRect:CGRectMake(x-5, 10.5+countRect.origin.y, 10, 9) blendMode:kCGBlendModeNormal alpha:alpha];
                commentsRect = CGRectMake(x-5, self.height-50, [UIScreen screenWidth]-x+5, 50);
                x -= 20;
            }
            
            NSString *reposts = _data[@"reposts"];
            if (reposts) {
                CGSize size = [reposts sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:FontWithSize(SIZE_FONT_SUBTITLE) lineSpace:5];
                
                x -= MAX(size.width, 5)+SIZE_GAP_BIG;
                [reposts drawInContext:context withPosition:CGPointMake(x, 8+countRect.origin.y)
                                andFont:FontWithSize(12)
                           andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1]
                              andHeight:rect.size.height];

                [[UIImage imageNamed:@"t_repost.png"] drawInRect:CGRectMake(x-5, 11+countRect.origin.y, 10, 9) blendMode:kCGBlendModeNormal alpha:alpha];
                repostsRect = CGRectMake(x-5, self.height-50, commentsRect.origin.x-x, 50);
                x -= 20;
            }
            
            [@"•••" drawInContext:context
                     withPosition:CGPointMake(SIZE_GAP_LEFT, 8+countRect.origin.y)
                          andFont:FontWithSize(11)
                     andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:.5]
                        andHeight:rect.size.height];
            
            if ([_data valueForKey:@"subData"]) {
                [[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1] set];
                CGContextFillRect(context, CGRectMake(0, rect.size.height-30.5, rect.size.width, .5));
            }
        }
        
        UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (flag==drawColorFlag) {
                postBGView.frame = rect;
                postBGView.image = nil;
                postBGView.image = temp;
            }
        });
    });
    [self drawText];
    [self loadThumb];
}

//将文本内容绘制到图片上
- (void)drawText{
    if (label==nil||detailLabel==nil) {
        [self addLabel];
    }
    label.frame = [_data[@"textRect"] CGRectValue];
    [label setText:_data[@"text"]];
    if ([_data valueForKey:@"subData"]) {
        detailLabel.frame = [[_data valueForKey:@"subData"][@"textRect"] CGRectValue];
        [detailLabel setText:[_data valueForKey:@"subData"][@"text"]];
        detailLabel.hidden = NO;
    }
}

- (void)loadThumb{
    float y = 0;
    NSArray *urls;
    if ([_data valueForKey:@"subData"]) {
        CGRect subPostRect = [_data[@"subData"][@"textRect"] CGRectValue];
        y = subPostRect.origin.y+subPostRect.size.height+SIZE_GAP_BIG;
        urls = [_data valueForKey:@"subData"][@"pic_urls"];
    } else {
        CGRect postRect = [_data[@"textRect"] CGRectValue];
        y = postRect.origin.y+postRect.size.height+SIZE_GAP_BIG;
        urls = _data[@"pic_urls"];
    }
    if (urls.count>0) {
        mulitPhotoScrollView.hidden = NO;
        mulitPhotoScrollView.y = y;
        mulitPhotoScrollView.frame = CGRectMake(0, y, [UIScreen screenWidth], SIZE_GAP_IMG+((SIZE_GAP_IMG+SIZE_IMAGE)*(urls.count)));
        for (NSInteger i=0; i<9; i++) {
            UIImageView *thumbView = (UIImageView *)[mulitPhotoScrollView viewWithTag:i+1];
            thumbView.contentMode = UIViewContentModeScaleAspectFill;
            thumbView.backgroundColor = [UIColor lightGrayColor];
            thumbView.clipsToBounds = YES;
            if (i<urls.count) {
                thumbView.frame = CGRectMake(SIZE_GAP_LEFT+(SIZE_GAP_IMG+SIZE_IMAGE)*i, .5, SIZE_IMAGE, SIZE_IMAGE);
                thumbView.hidden = NO;
                NSDictionary *url = urls[i];
                [thumbView sd_setImageWithURL:[NSURL URLWithString:url[@"thumbnail_pic"]]];
            } else {
                thumbView.hidden = YES;
            }
        }
        float cw = SIZE_GAP_LEFT*2+(SIZE_GAP_IMG+SIZE_IMAGE)*urls.count;
        if (cw<self.width) {
            cw = self.width;
        }
        if (mulitPhotoScrollView.contentSize.width!=cw) {
            mulitPhotoScrollView.contentSize = CGSizeMake(cw, 0);
        }
    }
}

- (void)clear{
    if (!drawed) {
        return;
    }
    postBGView.frame = CGRectZero;
    postBGView.image = nil;
    [label clear];
    if (!detailLabel.hidden) {
        detailLabel.hidden = YES;
        [detailLabel clear];
    }
    for (UIImageView *thumb1 in mulitPhotoScrollView.subviews) {
        if (!thumb1.hidden) {
            [thumb1 sd_cancelCurrentImageLoad];
        }
    }
    if (mulitPhotoScrollView.contentOffset.x!=0) {
        [mulitPhotoScrollView setContentOffset:CGPointZero animated:NO];
    }
    mulitPhotoScrollView.hidden = YES;
    drawColorFlag = arc4random();
    drawed = NO;
}

- (void)releaseMemory{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //	if ([self.delegate keepCell:self]) {
    //		return;
    //	}
    [self clear];
    [super removeFromSuperview];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"postview dealloc %@", self);
}

@end
