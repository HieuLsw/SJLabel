//
//  SJLabel.m
//  SJAttributesFactory
//
//  Created by BlueDancer on 2017/12/14.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import "SJLabel.h"
#import <CoreText/CoreText.h>
#import "SJCTData.h"
#import "SJCTFrameParser.h"
#import "SJCTFrameParserConfig.h"
#import "SJCTImageData.h"
#import <SJAttributesFactory/SJAttributesFactoryHeader.h>

@interface SJLabel ()

@property (nonatomic, strong, readonly) SJCTFrameParserConfig *config;

@property (nonatomic, strong) SJCTData *drawData;

@end

@implementation SJLabel

@synthesize text = _text;
@synthesize config = _config;

- (instancetype)init {
    return [self initWithText:nil font:nil textColor:nil lineSpacing:8 userInteractionEnabled:NO];
}

- (instancetype)initWithText:(NSString * __nullable)text
                        font:(UIFont * __nullable)font
                   textColor:(UIColor * __nullable)textColor
                 lineSpacing:(CGFloat)lineSpacing
      userInteractionEnabled:(BOOL)userInteractionEnabled {
    
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    _config = [self __defaultConfig];
    self.backgroundColor = [UIColor clearColor];
    self.text = text;
    self.font = font;
    self.textColor = textColor;
    self.lineSpacing = lineSpacing;
    [self _setupGestures];
    self.userInteractionEnabled = userInteractionEnabled;
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( 0 == _preferredMaxLayoutWidth &&
         0 != self.bounds.size.width ) {
        _config.maxWidth = floor(self.bounds.size.width);
    }
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    if ( 0 == _text.length && 0 == _attributedText.length ) return CGSizeZero;
    [self _considerUpdating];
    if ( nil == _drawData ) return CGSizeZero;
    return CGSizeMake(_drawData.width, _drawData.height_t);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if ( _drawData ) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, _drawData.height_t);
        CGContextScaleCTM(context, 1.0, -1.0);
        [_drawData drawingWithContext:context];
    }
}

- (void)sizeToFit {
    [self _considerUpdating];
    self.bounds = (CGRect){CGPointZero, CGSizeMake(_drawData.width, _drawData.height_t)};
}

- (void)_setupGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    if ( 0 == _attributedText.length ) return;
    
    CGPoint point = [tap locationInView:self];
    signed long index = [_drawData touchIndexWithPoint:point];
    if ( index != kCFNotFound ) {
        [_attributedText enumerateAttribute:SJActionAttributeName inRange:NSMakeRange(0, _attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if ( index > range.location && index < range.location + range.length ) {
                *stop = YES;
                void(^block)(NSRange range, NSAttributedString *str) = value;
                if ( block ) block(range, [_attributedText attributedSubstringFromRange:range]);
            }
        }];
    }
}


#pragma mark - Private

- (void)_considerUpdating {
    if ( 0 == _text.length && 0 == _attributedText.length ) {
        _drawData = nil;
    }
    else {
        if ( _text ) _drawData = [SJCTFrameParser parserContent:_text config:_config];
        if ( _attributedText ) _drawData = [SJCTFrameParser parserAttributedStr:_attributedText config:_config];
        [_drawData needsDrawing];
    }
    [self.layer setNeedsDisplay];
}

#pragma mark - Property

- (void)setText:(NSString *)text {
    _text = text.copy;
    _attributedText = nil;
    [self _considerUpdating];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText.copy;
    _text = nil;
    [self _considerUpdating];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if ( textAlignment == _config.textAlignment ) return;
    self.config.textAlignment = textAlignment;
    [self _considerUpdating];
}

- (NSTextAlignment)textAlignment {
    return self.config.textAlignment;
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if ( numberOfLines == _config.numberOfLines ) return;
    self.config.numberOfLines = numberOfLines;
    [self _considerUpdating];
}

- (NSUInteger)numberOfLines {
    return self.config.numberOfLines;
}

- (void)setFont:(UIFont *)font {
    if ( !font || font == _config.font || [font isEqual:_config.font] ) return;
    self.config.font = font;
    [self _considerUpdating];
}

- (UIFont *)font {
    return self.config.font;
}

- (void)setTextColor:(UIColor *)textColor {
    if ( !textColor || textColor == _config.textColor ) return;
    self.config.textColor = textColor;
    [self _considerUpdating];
}

- (UIColor *)textColor {
    return self.config.textColor;
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    self.config.maxWidth = preferredMaxLayoutWidth;
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    if ( lineSpacing == _config.lineSpacing ) return;
    self.config.lineSpacing = lineSpacing;
    [self _considerUpdating];
}

- (CGFloat)lineSpacing {
    return self.config.lineSpacing;
}

- (CGFloat)height {
    return ceil(_drawData.height_t);
}

- (SJCTFrameParserConfig *)__defaultConfig {
    SJCTFrameParserConfig *defaultConfig = [SJCTFrameParserConfig new];
    defaultConfig.maxWidth = [UIScreen mainScreen].bounds.size.width;
    defaultConfig.font = [UIFont systemFontOfSize:14];
    defaultConfig.textColor = [UIColor blackColor];
    defaultConfig.lineSpacing = 0;
    defaultConfig.textAlignment = NSTextAlignmentLeft;
    defaultConfig.numberOfLines = 1;
    defaultConfig.lineBreakMode = NSLineBreakByTruncatingTail;
    return defaultConfig;
}

@end
