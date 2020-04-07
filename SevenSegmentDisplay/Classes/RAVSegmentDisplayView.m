//
//  RAVSegmentDisplay.m
//  glass
//
//  Created by Aleksey Rochev on 18.03.16.
//  Copyright © 2016 Aleksey Rochev. All rights reserved.
//

#import "RAVSegmentDisplayView.h"

const NSTimeInterval RAVSegmentDisplayAnimationDuraion = 0.2;

@interface RAVSegmentDisplayView ()

@property (nonatomic) NSMutableArray *indicatorsMutable;

@property (nonatomic) CGFloat value;

@property (nonatomic) NSInteger codeIndicator;
@property (nonatomic) NSInteger codeIndicatorOld;

@property (nonatomic, getter = isShowText) BOOL showText;

@end

@implementation RAVSegmentDisplayView

@synthesize integerValue = _integerValue;
@synthesize floatValue = _floatValue;

- (void) layoutSubviews {
    if (self.indicatorsMutable.count == 0){
        [self setupIndicatorsWithCount:_countIndicators rect:self.bounds];
    }
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self setupValueDefault];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self setupValueDefault];
    }
    return self;
}

- (void) setupValueDefault {
    
    // Colors Initialization
    _colorDefault= [UIColor clearColor];
    _colorActive = [UIColor whiteColor];
    
    _typeFont = RAVSegmentIndicatorViewFontCondensed;
    
    _animation = YES;
    _animationDuration = RAVSegmentDisplayAnimationDuraion;

    _countIndicators = 3;
    _value = -1;
    
    _disableNullValue = YES;
    _off = NO;
}

#pragma mark - Getters

- (NSArray *) indicators {
    
    return [NSArray arrayWithArray:self.indicatorsMutable];
}

- (NSInteger) integerValue {
    return (NSInteger) self.value;
}

- (CGFloat) floatValue {
    return self.value;
}

#pragma mark - Setters

- (void) setIntegerValue:(NSInteger)integerValue{
    
    if (integerValue == (NSInteger)self.value) {
        _value = integerValue;
        return;
    }
    
    _value = integerValue;
    
    __block BOOL isOffIndicator = self.isDisableNullValue;
    __block int bIntValue= (int)integerValue;
    
    [self.indicatorsMutable enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(RAVSegmentIndicatorView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        int value;
        if (idx == 0) {
            value = bIntValue % 10;
        } else {
            value = bIntValue / (pow(10.0,(double)idx));
            value = value % 10;
        }
        
        if (value == 0 && idx != 0 && isOffIndicator && !obj.isOff) {
            obj.off = YES;
        } else if (value != 0) {
            isOffIndicator = NO;
            if (obj.isOff == YES) {
                obj.off = NO;
            }
        }
        
        if (obj.value != value) {
            obj.value = value;
        }
    }];
}

- (void) setFloatValue:(CGFloat)floatValue {
    
    self.integerValue = round(10*floatValue);
    self.value = floatValue;
    if (self.indicatorsMutable.count >= 2) {
        ((RAVSegmentIndicatorView *)self.indicatorsMutable[1]).one = YES;
    }
}

- (void) setStringValue:(NSString *)stringValue {
    
    __block NSInteger idxStr = stringValue.length -1;
    
    [self.indicatorsMutable enumerateObjectsUsingBlock:^(RAVSegmentIndicatorView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx < stringValue.length) {
            NSLog (@"%@", [NSString stringWithFormat:@"%c",[stringValue characterAtIndex:idxStr]]);
            
            NSString *strForCode = [NSString stringWithFormat:@"%c",[stringValue characterAtIndex:idxStr]];
            idxStr--;
            obj.codeIndicator = [RAVSegmentIndicatorView codeWithString: strForCode];

            if (obj.isOne) {
                obj.one = NO;
            }
        } else {
            obj.off = YES;
        }
    }];
}

- (void) setAnimation:(BOOL)animation {
    
    _animation = animation;
    
    [self.indicatorsMutable enumerateObjectsUsingBlock:^(RAVSegmentIndicatorView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.animation = animation;
    }];
}

- (void) setColorActive:(UIColor *)colorActive {
    
    _colorActive = [colorActive copy];
    
    [self.indicatorsMutable enumerateObjectsUsingBlock:^(RAVSegmentIndicatorView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.colorActive = colorActive;
    }];
}

- (void) setColorDefault:(UIColor *)colorDefault {
    
    _colorDefault = [colorDefault copy];
    
    [self.indicatorsMutable enumerateObjectsUsingBlock:^(RAVSegmentIndicatorView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.colorDefault = colorDefault;
    }];
}

#pragma mark - Public Methods

- (void) clearAllIndicators{
    
    [self.indicatorsMutable enumerateObjectsUsingBlock:^(RAVSegmentIndicatorView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj clearAllSegments];
    }];
}

- (void) setAllIndicators{
    
    [self.indicatorsMutable enumerateObjectsUsingBlock:^(RAVSegmentIndicatorView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setAllSegments];
    }];    
}

#pragma mark - Private Methods

#pragma mark - Draw Segment

- (void) setupIndicatorsWithCount:(NSInteger ) count rect: (CGRect) rect{
    
    if (self.indicatorsMutable == nil) {
        self.indicatorsMutable = [NSMutableArray new];
    } else {
        [self.indicatorsMutable removeAllObjects];
    }

    CGSize size = CGSizeMake(CGRectGetWidth(rect)/count , CGRectGetHeight(rect));
    CGRect frame = CGRectMake(0, 0, size.width , size.height);
    
    RAVSegmentIndicatorView *indicator = [[RAVSegmentIndicatorView alloc] initWithFrame:frame];
    indicator.colorActive = self.colorActive;
    indicator.colorDefault = self.colorDefault;
    indicator.typeFont = self.typeFont;
    indicator.animation = self.animation;
    indicator.animationDuration = self.animationDuration;
    
    for (int i = 0; i < count; i++) {
        [self.indicatorsMutable addObject:[indicator copy]];
    }
    
    indicator = nil;
    
    __block NSUInteger delta = self.indicatorsMutable.count - 1;
    
    [self.indicatorsMutable enumerateObjectsUsingBlock:^(RAVSegmentIndicatorView *obj, NSUInteger idx, BOOL * _Nonnull stop) {       CGPoint center = CGPointMake(delta * (CGRectGetWidth(rect)/count) + size.width/2, size.height/2);
        obj.center = center;
        delta--;
        
        [self addSubview:obj];
    }];
}

#pragma mark - RAVSegmentDisplayViewDelegate

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([self.delegate respondsToSelector:@selector(display:touchesBegan:withEvent:)]) {
        [self.delegate display:self touchesBegan:touches withEvent:event];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([self.delegate respondsToSelector:@selector(display:touchesEnded:withEvent:)]) {
        [self.delegate display:self touchesEnded:touches withEvent:event];
    }
}
@end
