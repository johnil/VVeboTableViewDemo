//
//  VVeboLabel.m
//  VVeboTableViewDemo
//
//  Created by Johnil on 15/5/25.
//  Copyright (c) 2015年 Johnil. All rights reserved.
//

#import "VVeboLabel.h"
#import "UIView+Additions.h"
#import <CoreText/CoreText.h>
#define kRegexHighlightViewTypeURL @"url"
#define kRegexHighlightViewTypeAccount @"account"
#define kRegexHighlightViewTypeTopic @"topic"
#define kRegexHighlightViewTypeEmoji @"emoji"

#define URLRegular @"(http|https)://(t.cn/|weibo.com/)+(([a-zA-Z0-9/])*)"
#define EmojiRegular @"(\\[\\w+\\])"
#define AccountRegular @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}"
#define TopicRegular @"#[^#]+#"

static void(^addEmojiWithDeep)(NSInteger, NSInteger);
static void(^addURLButtonWithDeep)(NSInteger, NSInteger);

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

CTTextAlignment CTTextAlignmentFromUITextAlignment(NSTextAlignment alignment) {
    switch (alignment) {
        case NSTextAlignmentLeft: return kCTLeftTextAlignment;
        case NSTextAlignmentCenter: return kCTCenterTextAlignment;
        case NSTextAlignmentRight: return kCTRightTextAlignment;
        default: return kCTNaturalTextAlignment;
    }
}

static inline NSRegularExpression * AccountRegularExpression() {
    static NSRegularExpression *_accountRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _accountRegularExpression = [[NSRegularExpression alloc] initWithPattern:AccountRegular options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _accountRegularExpression;
}

static inline NSRegularExpression * TopicRegularExpression() {
    static NSRegularExpression *_topicRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _topicRegularExpression = [[NSRegularExpression alloc] initWithPattern:TopicRegular options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _topicRegularExpression;
}


@implementation VVeboLabel {
    UIImageView *labelImageView;
    UIImageView *highlightImageView;
    BOOL highlighting;
    BOOL btnLoaded;
    BOOL emojiLoaded;
    NSRange currentRange;
    NSMutableDictionary *highlightColors;
    NSMutableDictionary *framesDict;
    NSInteger drawFlag;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        drawFlag = arc4random();
        framesDict = [[NSMutableDictionary alloc] init];
        highlightColors = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          [UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1],kRegexHighlightViewTypeAccount,
                          [UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1],kRegexHighlightViewTypeURL,
                          [UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1],kRegexHighlightViewTypeEmoji,
                          [UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1],kRegexHighlightViewTypeTopic,nil];
        labelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, frame.size.width, frame.size.height+10)];
        labelImageView.contentMode = UIViewContentModeScaleAspectFit;
        labelImageView.tag = NSIntegerMin;
        labelImageView.clipsToBounds = YES;
        [self addSubview:labelImageView];
        
        highlightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, frame.size.width, frame.size.height+10)];
        highlightImageView.contentMode = UIViewContentModeScaleAspectFit;
        highlightImageView.tag = NSIntegerMin;
        highlightImageView.clipsToBounds = YES;
        highlightImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:highlightImageView];
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        _textAlignment = NSTextAlignmentLeft;
        _textColor = [UIColor blackColor];
        _font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        _lineSpace = 5;
    }
    return self;
}

//Fix Coretext height
- (void)setFrame:(CGRect)frame{
    if (!CGSizeEqualToSize(labelImageView.image.size, frame.size)) {
        labelImageView.image = nil;
        highlightImageView.image = nil;
    }
    labelImageView.frame = CGRectMake(0, -5, frame.size.width, frame.size.height+10);
    highlightImageView.frame = CGRectMake(0, -5, frame.size.width, frame.size.height+10);
    [super setFrame:frame];
}

//高亮处理
- (NSMutableAttributedString *)highlightText:(NSMutableAttributedString *)coloredString{
    //Create a mutable attribute string to set the highlighting
    NSString* string = coloredString.string;
    NSRange range = NSMakeRange(0,[string length]);
    //Define the definition to use
    NSDictionary* definition = @{kRegexHighlightViewTypeAccount: AccountRegular,
                                 kRegexHighlightViewTypeURL:URLRegular,
                                 kRegexHighlightViewTypeTopic:TopicRegular,
                                 kRegexHighlightViewTypeEmoji:EmojiRegular,
                                 };
    //For each definition entry apply the highlighting to matched ranges
    for(NSString* key in definition) {
        NSString* expression = [definition objectForKey:key];
        NSArray* matches = [[NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:string options:0 range:range];
        for(NSTextCheckingResult* match in matches) {
            UIColor* textColor = nil;
            //Get the text color, if it is a custom key and no color was defined, choose black
            if(!highlightColors||!(textColor=([highlightColors objectForKey:key])))
                textColor = self.textColor;
            
            
            if (labelImageView.image != nil && currentRange.location!=-1 && currentRange.location>=match.range.location && currentRange.length+currentRange.location<=match.range.length+match.range.location) {
                [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                      value:(id)[UIColor colorWithRed:224/255.0 green:44/255.0 blue:86/255.0 alpha:1].CGColor range:match.range];
                double delayInSeconds = 1.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self backToNormal];
                });
            } else {
                UIColor *highlightColor = highlightColors[key];
                [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)highlightColor.CGColor range:match.range];
            }
        }
    }
    return coloredString;
}

//使用coretext将文本绘制到图片。
- (void)setText:(NSString *)text{
    if (text==nil || text.length<=0) {
        labelImageView.image = nil;
        highlightImageView.image = nil;
        return;
    }
    if ([text isEqualToString:_text]) {
        if (!highlighting || currentRange.location==-1) {
            return;
        }
    }
    if (highlighting&&labelImageView.image==nil) {
        return;
    }
    if (!highlighting) {
        [framesDict removeAllObjects];
        currentRange = NSMakeRange(-1, -1);
    }
    NSInteger flag = drawFlag;
    BOOL isHighlight = highlighting;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *temp = text;
        _text = text;
        CGSize size = self.frame.size;
        size.height += 10;
        UIGraphicsBeginImageContextWithOptions(size, ![self.backgroundColor isEqual:[UIColor clearColor]], 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context==NULL) {
            return;
        }
        if (![self.backgroundColor isEqual:[UIColor clearColor]]) {
            [self.backgroundColor set];
            CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        }
        CGContextSetTextMatrix(context,CGAffineTransformIdentity);
        CGContextTranslateCTM(context,0,size.height);
        CGContextScaleCTM(context,1.0,-1.0);
        
        //Determine default text color
        UIColor* textColor = self.textColor;
        
        //Set line height, font, color and break mode
        CGFloat minimumLineHeight = self.font.pointSize,maximumLineHeight = minimumLineHeight, linespace = self.lineSpace;
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize,NULL);
        CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
        CTTextAlignment alignment = CTTextAlignmentFromUITextAlignment(self.textAlignment);
        //Apply paragraph settings
        CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[6]){
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
            {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(minimumLineHeight),&minimumLineHeight},
            {kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(maximumLineHeight),&maximumLineHeight},
            {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(linespace), &linespace},
            {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(linespace), &linespace},
            {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode}
        },6);
        
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font,(NSString*)kCTFontAttributeName,
                                    textColor.CGColor,kCTForegroundColorAttributeName,
                                    style,kCTParagraphStyleAttributeName,
                                    nil];
        
        //Create attributed string, with applied syntax highlighting
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
        CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)[self highlightText:attributedStr];
        
        //Draw the frame
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        
        CGRect rect = CGRectMake(0, 5,(size.width),(size.height-5));
        
        if ([temp isEqualToString:text]) {
            [self drawFramesetter:framesetter attributedString:attributedStr textRange:CFRangeMake(0, text.length) inRect:rect context:context];
            CGContextSetTextMatrix(context,CGAffineTransformIdentity);
            CGContextTranslateCTM(context,0,size.height);
            CGContextScaleCTM(context,1.0,-1.0);
            UIImage *screenShotimage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                CFRelease(font);
                CFRelease(framesetter);
                [[attributedStr mutableString] setString:@""];
                
                if (drawFlag==flag) {
                    if (isHighlight) {
                        if (highlighting) {
                            highlightImageView.image = nil;
                            if (highlightImageView.width!=screenShotimage.size.width) {
                                highlightImageView.width = screenShotimage.size.width;
                            }
                            if (highlightImageView.height!=screenShotimage.size.height) {
                                highlightImageView.height = screenShotimage.size.height;
                            }
                            highlightImageView.image = screenShotimage;
                        }
                    } else {
                        if ([temp isEqualToString:text]) {
                            if (labelImageView.width!=screenShotimage.size.width) {
                                labelImageView.width = screenShotimage.size.width;
                            }
                            if (labelImageView.height!=screenShotimage.size.height) {
                                labelImageView.height = screenShotimage.size.height;
                            }
                            highlightImageView.image = nil;
                            labelImageView.image = nil;
                            labelImageView.image = screenShotimage;
                        }
                    }
//                    [self debugDraw];//绘制可触摸区域
                }
            });
        }
    });
}

//确保行高一致，计算所需触摸区域
- (void)drawFramesetter:(CTFramesetterRef)framesetter
       attributedString:(NSAttributedString *)attributedString
              textRange:(CFRange)textRange
                 inRect:(CGRect)rect
                context:(CGContextRef)c
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    BOOL truncateLastLine = NO;//tailMode
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        lineOrigin = CGPointMake(CGFloat_ceil(lineOrigin.x), CGFloat_ceil(lineOrigin.y));
        
        CGContextSetTextPosition(c, lineOrigin.x, lineOrigin.y);
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CGFloat descent = 0.0f;
        CGFloat ascent = 0.0f;
        CGFloat lineLeading;
        CTLineGetTypographicBounds((CTLineRef)line, &ascent, &descent, &lineLeading);
        
        // Adjust pen offset for flush depending on text alignment
        CGFloat flushFactor = NSTextAlignmentLeft;
        CGFloat penOffset;
        CGFloat y;
        if (lineIndex == numberOfLines - 1 && truncateLastLine) {
            // Check if the range of text in the last line reaches the end of the full attributed string
            CFRange lastLineRange = CTLineGetStringRange(line);
            
            if (!(lastLineRange.length == 0 && lastLineRange.location == 0) && lastLineRange.location + lastLineRange.length < textRange.location + textRange.length) {
                // Get correct truncationType and attribute position
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                CFIndex truncationAttributePosition = lastLineRange.location;
                
                NSString *truncationTokenString = @"\u2026";
                
                NSDictionary *truncationTokenStringAttributes = [attributedString attributesAtIndex:(NSUInteger)truncationAttributePosition effectiveRange:NULL];
                
                NSAttributedString *attributedTokenString = [[NSAttributedString alloc] initWithString:truncationTokenString attributes:truncationTokenStringAttributes];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTokenString);
                
                // Append truncationToken to the string
                // because if string isn't too long, CT wont add the truncationToken on it's own
                // There is no change of a double truncationToken because CT only add the token if it removes characters (and the one we add will go first)
                NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange((NSUInteger)lastLineRange.location, (NSUInteger)lastLineRange.length)] mutableCopy];
                if (lastLineRange.length > 0) {
                    // Remove any newline at the end (we don't want newline space between the text and the truncation token). There can only be one, because the second would be on the next line.
                    unichar lastCharacter = [[truncationString string] characterAtIndex:(NSUInteger)(lastLineRange.length - 1)];
                    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
                        [truncationString deleteCharactersInRange:NSMakeRange((NSUInteger)(lastLineRange.length - 1), 1)];
                    }
                }
                [truncationString appendAttributedString:attributedTokenString];
                CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
                
                // Truncate the line in case it is too long.
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                if (!truncatedLine) {
                    // If the line is not as wide as the truncationToken, truncatedLine is NULL
                    truncatedLine = CFRetain(truncationToken);
                }
                
                penOffset = (CGFloat)CTLineGetPenOffsetForFlush(truncatedLine, flushFactor, rect.size.width);
                y = lineOrigin.y - descent - self.font.descender;
                CGContextSetTextPosition(c, penOffset, y);
                
                CTLineDraw(truncatedLine, c);
                
                CFRelease(truncatedLine);
                CFRelease(truncationLine);
                CFRelease(truncationToken);
            } else {
                penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
                y = lineOrigin.y - descent - self.font.descender;
                CGContextSetTextPosition(c, penOffset, y);
                CTLineDraw(line, c);
            }
        } else {
            penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
            y = lineOrigin.y - descent - self.font.descender;
            CGContextSetTextPosition(c, penOffset, y);
            CTLineDraw(line, c);
        }
        if ((!highlighting&&self.superview!=nil)) {
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            for (int j = 0; j < CFArrayGetCount(runs); j++) {
                CGFloat runAscent;
                CGFloat runDescent;
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
                if (!CGColorEqualToColor((__bridge CGColorRef)([attributes valueForKey:@"CTForegroundColor"]), self.textColor.CGColor)
                    && framesDict!=nil) {
                    CFRange range = CTRunGetStringRange(run);
                    CGRect runRect;
                    runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                    float offset = CTLineGetOffsetForStringIndex(line, range.location, NULL);
                    float height = runAscent;
                    runRect=CGRectMake(lineOrigin.x + offset, (self.height+5)-y-height+runDescent/2, runRect.size.width, height);
                    NSRange nRange = NSMakeRange(range.location, range.length);
                    [framesDict setValue:[NSValue valueWithCGRect:runRect] forKey:NSStringFromRange(nRange)];
                }
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
}

- (void)clear{
    drawFlag = arc4random();
    _text = @"";
    labelImageView.image = nil;
    highlightImageView.image = nil;
    [self removeSubviewExceptTag:NSIntegerMin];
}

- (void)removeSubviewExceptTag:(NSInteger)tag{
    for (UIView *temp in self.subviews) {
        if (temp.tag!=tag) {
            if ([temp isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)temp setImage:nil];
            }
            [temp removeFromSuperview];
        }
    }
}

- (void)debugDraw{
    for (NSValue *value in framesDict.allValues) {
        UIView *temp = [[UIView alloc] initWithFrame:[value CGRectValue]];
        temp.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:.5];
        [self addSubview:temp];
    }
}

- (void)highlightWord{
    highlighting = YES;
    [self setText:_text];
}

- (void)backToNormal{
    if (!highlighting) {
        return;
    }
    highlighting = NO;
    currentRange = NSMakeRange(-1, -1);
    highlightImageView.image = nil;
}

- (BOOL)touchPoint:(CGPoint)point{
    for (NSString *key in framesDict.allKeys) {
        CGRect frame = [[framesDict valueForKey:key] CGRectValue];
        if (CGRectContainsPoint(frame, point)) {
            NSRange range = NSRangeFromString(key);
            NSArray* matches = [AccountRegularExpression() matchesInString:self.text options:0 range:NSMakeRange(0, self.text.length)];
            for(NSTextCheckingResult* match in matches) {
                if (range.location!=-1 && range.location>=match.range.location && range.length+range.location<=match.range.length+match.range.location) {
                    return YES;
                }
            }
            matches = [TopicRegularExpression() matchesInString:self.text options:0 range:NSMakeRange(0, self.text.length)];
            for(NSTextCheckingResult* match in matches) {
                if (range.location!=-1 && range.location>=match.range.location && range.length+range.location<=match.range.length+match.range.location) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint location = [[touches anyObject] locationInView:self];
    for (NSString *key in framesDict.allKeys) {
        CGRect frame = [[framesDict valueForKey:key] CGRectValue];
        if (CGRectContainsPoint(frame, location)) {
            NSRange range = NSRangeFromString(key);
            range = NSMakeRange(range.location, range.length-1);
            currentRange = range;
            [self highlightWord];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (highlighting) {
        double delayInSeconds = .2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self backToNormal];
        });
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (highlighting) {
        [self backToNormal];
    }
}

- (void)removeFromSuperview{
    [highlightColors removeAllObjects];
    highlightColors = nil;
    [framesDict removeAllObjects];
    framesDict = nil;
    highlightImageView.image = nil;
    labelImageView.image = nil;
    [super removeFromSuperview];
}

- (void)dealloc{
    NSLog(@"dealloc %@", self);
}

@end
