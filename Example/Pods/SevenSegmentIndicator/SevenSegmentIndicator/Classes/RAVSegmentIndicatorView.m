//
//  RAVSegmentIndicatorView.m
//  RAVSevenSegmentView
//
//  Created by Aleksey Rochev on 18.03.16.
//  Copyright © 2016 Aleksey Rochev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAVSegmentIndicatorView.h"

static NSString * const kLayerSegment = @"RAVLayerSegmentKey";
static NSString * const kLayerSegmentDP = @"RAVLayerSegmentDPKey";
static NSString * const kAnimationSegmentFillColorKey = @"segmentFillColorAnimationKey";

static const CGFloat kCondensedKoef = 100.0/232.0;
static const CGFloat kPlumpKoef = 100.0/165.0;

int funcCodeWithInt (int x) {
    switch (x) {
        case 0:
            return 0x7E;
            break;
        case 1:
            return 0x30;
            break;
        case 2:
            return 0x6D;
            break;
        case 3:
            return 0x79;
            break;
        case 4:
            return 0x33;
            break;
        case 5:
            return 0x5B;
            break;
        case 6:
            return 0x5F;
            break;
        case 7:
            return 0x70;
            break;
        case 8:
            return 0x7F;
            break;
        case 9:
            return 0x7B;
            break;
            
        default:
            return 0x7E;
            break;
    }
}

int funcCodeWithChar (char x) {
    switch (x) {
        case 'A':
            return 0x77;
            break;
        case 'B':
            return 0x1F;
            break;
        case 'C':
            return 0x4E;
            break;
        case 'D':
            return 0x3D;
            break;
        case 'E':
            return 0x4F;
            break;
        case 'F':
            return 0x47;
            break;
        case 'G':
            return 0x7B;
            break;
        case 'H':
            return 0x37;
            break;
        case 'I':
            return 0x6;
            break;
        case 'J':
            return 0x3C;
            break;
        case 'K':
            return 0x37;
            break;
        case 'L':
            return 0xE;
            break;
        case 'M':
            return 0x54;
            break;
        case 'N':
            return 0x15;
            break;
        case 'O':
            return 0x7E;
            break;
        case 'P':
            return 0x67;
            break;
        case 'Q':
            return 0x73;
            break;
        case 'R':
            return 0x5;
            break;
        case 'S':
            return 0x5B;
            break;
        case 'T':
            return 0x0F;
            break;
        case 'U':
            return 0x3E;
            break;
        case 'V':
            return 0x1C;
            break;
        case 'W':
            return 0x54;
            break;
        case 'X':
            return 0x37;
            break;
        case 'Y':
            return 0x3B;
            break;
        case 'Z':
            return 0x6D;
            break;
        default:
            return 0x7E;
            break;
    }
}

const NSTimeInterval RAVSegmentIndicatorViewAnimationDuraion = 0.2;


@interface RAVSegmentIndicatorView ()

@property (nonatomic, strong) NSMutableDictionary   *layersMutable;

@property (nonatomic) NSInteger                     codeIndicatorOld;

@end

@implementation RAVSegmentIndicatorView

#pragma mark - Init

-(void) layoutSubviews {
    
    if (self.layersMutable.count == 0){
        [self setupSegments:self.bounds];
    }
    [self setCurrentStateSegments];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupVariableDefault];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];        
        [self setupVariableDefault];
    }
    return self;
}

- (void) setupVariableDefault {
    
    _layersMutable = [NSMutableDictionary dictionary];
    
    _colorDefault = [UIColor clearColor];
    _colorActive = [UIColor whiteColor];
    
    _animation = YES;
    _animationDuration = RAVSegmentIndicatorViewAnimationDuraion;
    
    _value = 0;
    
    _codeIndicator = [RAVSegmentIndicatorView codeWithInteger:_value];
    _codeIndicatorOld = _codeIndicator;
    
    _typeFont = RAVSegmentIndicatorViewFontCondensed;
    
    _one = NO;
    _off = NO;
}

#pragma mark - Getters

- (NSDictionary *) layers {
    
    return [NSDictionary dictionaryWithDictionary:_layersMutable];
}

#pragma mark - Setters

- (void) setValue:(NSInteger)value {
    
    if (value >= 0 && value <= 9) {
        _value = value;
    } else if (value < 0) {
        _value = 0;
    } else if (value > 9) {
        _value = 9;
    }
    
    self.codeIndicator = [RAVSegmentIndicatorView codeWithInteger:self.value];
}

- (void) setCodeIndicator:(NSInteger)codeIndicator {
    
    self.codeIndicatorOld = self.codeIndicator;
    _codeIndicator = codeIndicator;
    
    if (self.codeIndicator != self.codeIndicatorOld && !self.isOff) {
        
        [self animationUpdateFromCode:self.codeIndicatorOld toCode:self.codeIndicator];
    }
}

- (void) setColorActive:(UIColor *)colorActive {
    
    _colorActive = [colorActive copy];
    [self setCurrentStateSegments];
}

- (void) setColorDefault:(UIColor *)colorDefault {
    
    _colorDefault = [colorDefault copy];
    [self setCurrentStateSegments];
}

- (void) setOne:(BOOL)one {
    
    if (!self.isOff) {
        [self setStateDPTo:one];
    }
    
    _one = one;
}

- (void) setOff:(BOOL)off {
    
    if (_off != off) {
        
        _off = off;
        
        [self disableAllSegment:off];
    }
}

#pragma mark - Private Methods

- (UIColor *) getColorLayer:(CAShapeLayer *)layer {
    
    CGColorRef colorRef = (__bridge CGColorRef)([[layer presentationLayer] valueForKey:@"fillColor"]);
    
    UIColor *color = [UIColor colorWithCGColor:colorRef];
    
    if (color == nil) {
        color = self.colorDefault;
    }
    
    return color;
}


- (void) setStateDPTo: (BOOL) toState {
    
    UIColor *fromColor = [self getColorLayer:self.layersMutable[kLayerSegmentDP]];
    UIColor *toColor = toState ? self.colorActive : self.colorDefault;
    
    [self animationSegment:self.layersMutable[kLayerSegmentDP]
                segmentKey:kLayerSegmentDP
                 fromColor:fromColor
                   toColor:toColor
                  animated:self.animation];
}

- (void) disableAllSegment: (BOOL) disable {
    
    NSInteger fromCodeIndicator = [RAVSegmentIndicatorView codeForClearSegments];
    NSInteger toCodeIndicator = self.codeIndicator;

    UIColor *colorActive = self.colorActive;
    UIColor *colorDefault = self.colorDefault;
    
    UIColor *dpFromColor = [UIColor clearColor];
    UIColor *dpToColor = self.one ? self.colorActive : self.colorDefault;
    
    if (disable) {
        fromCodeIndicator = self.codeIndicator;
        toCodeIndicator = [RAVSegmentIndicatorView codeForClearSegments];
        
        colorActive = [UIColor clearColor];
        colorDefault = [UIColor clearColor];
        
        dpFromColor = [self getColorLayer:self.layersMutable[kLayerSegmentDP]];
        dpToColor = [UIColor clearColor];
    }
    
    [self animationUpdateFromCode:fromCodeIndicator
                           toCode:toCodeIndicator
                       colorActive:colorActive
                      colorDefault:colorDefault];
    
    [self animationSegment:self.layersMutable[kLayerSegmentDP]
                segmentKey:kLayerSegmentDP
                 fromColor:dpFromColor
                   toColor:dpToColor
                  animated:self.animation];
}

#pragma mark - Public Methods

- (void) clearAllSegments {
    
    self.codeIndicator = [RAVSegmentIndicatorView codeForClearSegments];
}

- (void) setAllSegments {
    
    self.codeIndicator = [RAVSegmentIndicatorView codeForSetAllSegments];
}

- (void) setCurrentStateSegments {
    
    [self animationUpdateAllSegmentsFromCode:self.codeIndicator toCode:self.codeIndicator];
    self.one = _one;
    self.off = NO;
}

#pragma mark - Methods Animation

- (void) animationUpdateFromCode:(NSInteger) fromCode toCode:(NSInteger) toCode {
    [self animationUpdateFromCode:fromCode toCode:toCode colorActive:self.colorActive colorDefault:self.colorDefault];
}

- (void) animationUpdateFromCode:(NSInteger) fromCode toCode:(NSInteger) toCode colorActive: (UIColor*) colorActive colorDefault: (UIColor *) colorDefault{
    
    if (self.layersMutable.count == 0) {
        [self setNeedsLayout];
    }
    
    NSInteger sumCode = fromCode & toCode;
    //   64 32 16 8 4 2 1
    for (int i = 64; i >= 1; i = i/2) {
        if ((sumCode & i) != i) {
            UIColor *fromColor;
            UIColor *toColor;
            NSString *layerKey = [NSString stringWithFormat:@"%@%i", kLayerSegment, i];
            
            fromColor = [self getColorLayer:self.layersMutable[layerKey]];
            
            if ((fromCode & i) >= (toCode & i)) {
                toColor =  colorDefault;
            } else {
                toColor =  colorActive;
            }
            
            [self animationSegment:self.layersMutable[layerKey]
                        segmentKey:layerKey
                         fromColor:fromColor
                           toColor:toColor
                          animated:self.animation];
        }
    }
}

- (void) animationUpdateAllSegmentsFromCode:(NSInteger) fromCode toCode:(NSInteger) toCode {
    [self animationUpdateAllSegmentsFromCode:fromCode toCode:toCode colorActive:self.colorActive colorDefault:self.colorDefault];
}

- (void) animationUpdateAllSegmentsFromCode:(NSInteger) fromCode toCode:(NSInteger) toCode colorActive: (UIColor*) colorActive colorDefault: (UIColor *) colorDefault {

    for (int i = 64; i >= 1; i = i/2) {
            UIColor *fromColor;
            UIColor *toColor;
        NSString *layerKey = [NSString stringWithFormat:@"%@%i", kLayerSegment, i];

        fromColor = [self getColorLayer:self.layersMutable[layerKey]];
        
            if (((fromCode & i) == 0) && ((toCode & i) == 0)) {
                toColor =  colorDefault;
            } else if ((fromCode & i) == (toCode & i)){
                toColor =  colorActive;
            }
            
            [self animationSegment:self.layersMutable[layerKey]
                        segmentKey:layerKey
                         fromColor:fromColor
                           toColor:toColor
                          animated:self.animation];
    }
}

- (void) animationSegment:(CAShapeLayer *) segmentLayer
               segmentKey:(NSString *) segmentKey
                fromColor:(UIColor *) fromColor
                  toColor:(UIColor *) toColor
                 animated: (BOOL) animated{
    
    if (!animated) {
        segmentLayer.fillColor = toColor.CGColor;
        return;
    }
    
    CAKeyframeAnimation *fillColorAnimation = [RAVSegmentIndicatorView fillColorAnimationFromColor:fromColor
                                                                                           toColor:toColor
                                                                                          duration:self.animationDuration];
    
    NSString *keyAnimation = [NSString stringWithFormat:@"%@%@", kAnimationSegmentFillColorKey, segmentKey];
    
    [segmentLayer addAnimation:fillColorAnimation forKey:keyAnimation];
}

#pragma mark - Draw Segment

- (void) setupSegments:(CGRect) rect {
    
    [self.layersMutable[kLayerSegment] removeFromSuperlayer];
    
    CAShapeLayer *background = [RAVSegmentIndicatorView layerBackgroundWithRect:rect
                                                               withType: self.typeFont];
    [self.layer addSublayer:background];
    
    self.layersMutable[kLayerSegment] = background;
    
    NSArray *arrSegments = [RAVSegmentIndicatorView arrLayerSegmentsWithType:self.typeFont];
    
    int j = 0;
    for (int i = 64; i >= 1; i = i/2, j++) {
        [self addSegment:arrSegments[j] segmentKey:[NSString stringWithFormat:@"%@%i", kLayerSegment, i] toLayer:self.layersMutable[kLayerSegment]];
    }
    
    [self addSegment:arrSegments.lastObject
          segmentKey:kLayerSegmentDP
             toLayer:self.layersMutable[kLayerSegment]];
}

- (void) addSegment:(CAShapeLayer *) shapeLayer segmentKey: (NSString *) segmentKey toLayer: (CALayer *)toLayer {
    
    CAShapeLayer * segmentLayer = [self addLayer:shapeLayer
                                       fillColor:self.colorActive.CGColor
                                         toLayer:toLayer];
    
    [self.layersMutable[segmentKey] removeFromSuperlayer];
    self.layersMutable[segmentKey] = segmentLayer;
}

#pragma mark - Draw

- (CAShapeLayer *) addLayer:(CAShapeLayer *) layer
                  fillColor:(CGColorRef) fillColor
                    toLayer:(CALayer *) toLayer {
    
    layer.fillColor = fillColor;
    [toLayer addSublayer: layer];
    
    return layer;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    
    RAVSegmentIndicatorView *myCopy = [[RAVSegmentIndicatorView alloc] initWithFrame: self.frame];
    myCopy.colorActive = self.colorActive;
    myCopy.colorDefault = self.colorDefault;
    myCopy.typeFont = self.typeFont;
    myCopy.animation = self.animation;
    myCopy.animationDuration = self.animationDuration;

    return myCopy;
}

@end


@implementation RAVSegmentIndicatorView (Animation)

+ (CABasicAnimation*) transformAnimationFromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle duration:(CGFloat)duration{
    
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    transformAnim.fromValue = [NSNumber numberWithFloat:fromAngle];
    transformAnim.toValue = [NSNumber numberWithFloat:toAngle];
    transformAnim.duration           = duration;
    transformAnim.timingFunction     = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    transformAnim.fillMode = kCAFillModeForwards;
    transformAnim.removedOnCompletion = NO;
    
    return transformAnim;
}

+ (CAKeyframeAnimation*) fillColorAnimationFromColor: (UIColor *) fromColor toColor: (UIColor *) toColor duration:(NSTimeInterval) duration{
    
    if (fromColor != nil && toColor != nil) {
        CAKeyframeAnimation * fillColorAnim = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
        fillColorAnim.values   = @[(id)fromColor.CGColor,
                                   (id)toColor.CGColor];
        fillColorAnim.keyTimes = @[@0, @1];
        fillColorAnim.duration           = duration;
        fillColorAnim.timingFunction     = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        fillColorAnim.fillMode = kCAFillModeForwards;
        fillColorAnim.removedOnCompletion = NO;
        
        return fillColorAnim;
    }
    
    return nil;
}

@end

@implementation RAVSegmentIndicatorView (Alphabet)

+ (NSInteger) codeWithInteger:(NSInteger)value {
    return funcCodeWithInt((int)value);
}

+ (NSInteger) codeWithChar:(char)value{
    return funcCodeWithChar( toupper(value));
}

+ (NSInteger) codeWithString:(NSString *)value {
    return funcCodeWithChar(toupper([value characterAtIndex:0]));
}

+ (NSInteger) codeForClearSegments{
    return 0;
}

+ (NSInteger) codeForSetAllSegments {
    return funcCodeWithInt((int)8);
}
@end

@implementation RAVSegmentIndicatorView (Paint)
+ (NSArray *) arrBezierSegmentsWithType: (RAVSegmentIndicatorViewFontType) type {
    
    NSArray *array;
    if (type == RAVSegmentIndicatorViewFontCondensed) {
        array = @[[[self class] bezierSegmentCondensedA],
                  [[self class] bezierSegmentCondensedB],
                  [[self class] bezierSegmentCondensedC],
                  [[self class] bezierSegmentCondensedD],
                  [[self class] bezierSegmentCondensedE],
                  [[self class] bezierSegmentCondensedF],
                  [[self class] bezierSegmentCondensedG],
                  [[self class] bezierSegmentDP]
                  ];
        
    } else  if (type == RAVSegmentIndicatorViewFontPlump){
        array = @[[[self class] bezierSegmentPlumpA],
                  [[self class] bezierSegmentPlumpB],
                  [[self class] bezierSegmentPlumpC],
                  [[self class] bezierSegmentPlumpD],
                  [[self class] bezierSegmentPlumpE],
                  [[self class] bezierSegmentPlumpF],
                  [[self class] bezierSegmentPlumpG],
                  [[self class] bezierSegmentDP]
                  ];
    }
    
    return array;
}

+ (NSArray *) arrLayerSegmentsWithType: (RAVSegmentIndicatorViewFontType) type {
    
    NSArray *array;
    if (type == RAVSegmentIndicatorViewFontCondensed) {
        array = @[[[self class] layerSegmentCondensedA],
                  [[self class] layerSegmentCondensedB],
                  [[self class] layerSegmentCondensedC],
                  [[self class] layerSegmentCondensedD],
                  [[self class] layerSegmentCondensedE],
                  [[self class] layerSegmentCondensedF],
                  [[self class] layerSegmentCondensedG],
                  [[self class] layerSegmentCondensedDP]
                  ];
        
    } else  if (type == RAVSegmentIndicatorViewFontPlump){
        array = @[[[self class] layerSegmentPlumpA],
                  [[self class] layerSegmentPlumpB],
                  [[self class] layerSegmentPlumpC],
                  [[self class] layerSegmentPlumpD],
                  [[self class] layerSegmentPlumpE],
                  [[self class] layerSegmentPlumpF],
                  [[self class] layerSegmentPlumpG],
                  [[self class] layerSegmentPlumpDP]
                  ];
    }
    
    return array;
}

+ (CAShapeLayer*) layerBackgroundWithRect:(CGRect) rect withType: (RAVSegmentIndicatorViewFontType) type {
    
    CGFloat widthKoef = kPlumpKoef;
    
    if (type == RAVSegmentIndicatorViewFontCondensed) {
        widthKoef = kCondensedKoef;
    }
    
    CGFloat width = CGRectGetHeight(rect) * widthKoef;
    CGRect frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), width , CGRectGetHeight(rect));
    
    CAShapeLayer *layer;
    if (type == RAVSegmentIndicatorViewFontCondensed) {
        
        layer = [[self class] layerBackgroundCondensedWithRect:frame];
    } else  if (type == RAVSegmentIndicatorViewFontPlump){
        
        layer = [[self class] layerBackgroundPlumpWithRect:frame];
    }
    
    return layer;
}


#pragma mark - CAShapeLayer Segments

+ (CAShapeLayer*) layerBackgroundCondensedWithRect:(CGRect) rect {
    
    CGRect segmentRect = CGRectMake(CGRectGetMinX(rect) + floor(CGRectGetWidth(rect) * 0.00000 + 0.5), CGRectGetMinY(rect) + floor(CGRectGetHeight(rect) * 0.00000 + 0.5), floor(CGRectGetWidth(rect) * 1.00000 + 0.5) - floor(CGRectGetWidth(rect) * 0.00000 + 0.5), floor(CGRectGetHeight(rect) * 1.00000 + 0.5) - floor(CGRectGetHeight(rect) * 0.00000 + 0.5));
    
    CATransform3D transform = CATransform3DMakeScale(segmentRect.size.width / 159, segmentRect.size.height / 370, 1);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = UIColor.clearColor.CGColor;
    layer.transform = transform;
    layer.frame = rect;
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentCondensedA {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentCondensedA];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(14, 20, 93, 33);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentCondensedB {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentCondensedB];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(86, 22, 35, 161);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentCondensedC {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentCondensedC];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(86, 187, 35, 161);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentCondensedD {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentCondensedD];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(14, 317, 93, 33);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentCondensedE {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentCondensedE];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(0, 187, 35, 161);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentCondensedF {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentCondensedF];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(0, 22, 35, 161);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentCondensedG {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentCondensedG];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(9, 168, 102, 34);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentCondensedDP {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentDP];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(120, 330, 32, 32);
    
    return layer;
}

+ (CAShapeLayer*) layerBackgroundPlumpWithRect:(CGRect) rect {
    
    CGRect segmentRect = CGRectMake(CGRectGetMinX(rect) + floor(CGRectGetWidth(rect) * 0.00000 + 0.5), CGRectGetMinY(rect) + floor(CGRectGetHeight(rect) * 0.00000 + 0.5), floor(CGRectGetWidth(rect) * 1.00000 + 0.5) - floor(CGRectGetWidth(rect) * 0.00000 + 0.5), floor(CGRectGetHeight(rect) * 1.00000 + 0.5) - floor(CGRectGetHeight(rect) * 0.00000 + 0.5));
    
    CATransform3D transform = CATransform3DMakeScale(segmentRect.size.width / 225, segmentRect.size.height / 370, 1);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = UIColor.clearColor.CGColor;
    layer.transform = transform;
    layer.frame = rect;
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentPlumpA {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentPlumpA];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(15, 16, 159, 33);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentPlumpB {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentPlumpB];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(152, 19, 35, 161);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentPlumpC {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentPlumpC];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(152, 185, 35, 161);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentPlumpD {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentPlumpD];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(15, 316, 159, 33);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentPlumpE {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentPlumpE];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(1, 185, 35, 161);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentPlumpF {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentPlumpF];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(1, 19, 35, 161);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentPlumpG {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentPlumpG];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(10, 166, 168, 34);
    
    return layer;
}

+ (CAShapeLayer*) layerSegmentPlumpDP {
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath *layerPath = [[self class] bezierSegmentDP];
    layer.path = layerPath.CGPath;
    layer.transform = CATransform3DIdentity;
    
    layer.frame = CGRectMake(189, 330, 32, 32);
    
    return layer;
}

#pragma mark - UIBezierPath Segments

+ (UIBezierPath*) bezierSegmentCondensedA {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(92.84, 0)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.2, 0) controlPoint1: CGPointMake(61.87, 0) controlPoint2: CGPointMake(31.49, 0)];
    [segmentBezierPath addCurveToPoint: CGPointMake(3.21, 4.09) controlPoint1: CGPointMake(1.39, 1.62) controlPoint2: CGPointMake(2.26, 2.88)];
    [segmentBezierPath addCurveToPoint: CGPointMake(23.02, 29.16) controlPoint1: CGPointMake(9.77, 12.48) controlPoint2: CGPointMake(16.22, 20.96)];
    [segmentBezierPath addCurveToPoint: CGPointMake(29.13, 32.22) controlPoint1: CGPointMake(24.37, 30.79) controlPoint2: CGPointMake(27.03, 32.17)];
    [segmentBezierPath addCurveToPoint: CGPointMake(64.09, 32.26) controlPoint1: CGPointMake(40.77, 32.51) controlPoint2: CGPointMake(52.44, 32.45)];
    [segmentBezierPath addCurveToPoint: CGPointMake(69.16, 30.1) controlPoint1: CGPointMake(65.82, 32.24) controlPoint2: CGPointMake(68.11, 31.38)];
    [segmentBezierPath addCurveToPoint: CGPointMake(91.64, 2.04) controlPoint1: CGPointMake(76.8, 20.86) controlPoint2: CGPointMake(84.19, 11.43)];
    [segmentBezierPath addCurveToPoint: CGPointMake(92.84, 0) controlPoint1: CGPointMake(92.01, 1.57) controlPoint2: CGPointMake(92.26, 1)];
    [segmentBezierPath closePath];
    
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentCondensedB {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(25.14, 0)];
    [segmentBezierPath addCurveToPoint: CGPointMake(1.39, 29.23) controlPoint1: CGPointMake(17.09, 9.85) controlPoint2: CGPointMake(9.14, 19.46)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.15, 34.33) controlPoint1: CGPointMake(0.4, 30.49) controlPoint2: CGPointMake(0.16, 32.61)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.19, 133.25) controlPoint1: CGPointMake(0.08, 67.3) controlPoint2: CGPointMake(0.07, 100.28)];
    [segmentBezierPath addCurveToPoint: CGPointMake(2.16, 138.34) controlPoint1: CGPointMake(0.19, 134.98) controlPoint2: CGPointMake(0.92, 137.32)];
    [segmentBezierPath addCurveToPoint: CGPointMake(29.47, 160.06) controlPoint1: CGPointMake(11.15, 145.74) controlPoint2: CGPointMake(20.37, 152.88)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.17, 152.25) controlPoint1: CGPointMake(33.3, 158.65) controlPoint2: CGPointMake(34.18, 156)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.29, 17.86) controlPoint1: CGPointMake(34.06, 107.45) controlPoint2: CGPointMake(33.9, 62.66)];
    [segmentBezierPath addCurveToPoint: CGPointMake(25.14, 0) controlPoint1: CGPointMake(34.36, 10.1) controlPoint2: CGPointMake(31.51, 4.95)];
    [segmentBezierPath closePath];
    
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentCondensedC {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(25.14, 160.06)];
    [segmentBezierPath addCurveToPoint: CGPointMake(1.39, 130.83) controlPoint1: CGPointMake(17.09, 150.21) controlPoint2: CGPointMake(9.14, 140.6)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.15, 125.73) controlPoint1: CGPointMake(0.4, 129.58) controlPoint2: CGPointMake(0.16, 127.46)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.19, 26.82) controlPoint1: CGPointMake(0.08, 92.76) controlPoint2: CGPointMake(0.07, 59.79)];
    [segmentBezierPath addCurveToPoint: CGPointMake(2.16, 21.72) controlPoint1: CGPointMake(0.19, 25.08) controlPoint2: CGPointMake(0.92, 22.74)];
    [segmentBezierPath addCurveToPoint: CGPointMake(29.47, 0) controlPoint1: CGPointMake(11.15, 14.32) controlPoint2: CGPointMake(20.37, 7.19)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.17, 7.81) controlPoint1: CGPointMake(33.3, 1.42) controlPoint2: CGPointMake(34.18, 4.07)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.29, 142.2) controlPoint1: CGPointMake(34.06, 52.61) controlPoint2: CGPointMake(33.9, 97.41)];
    [segmentBezierPath addCurveToPoint: CGPointMake(25.14, 160.06) controlPoint1: CGPointMake(34.36, 149.97) controlPoint2: CGPointMake(31.51, 155.11)];
    [segmentBezierPath closePath];
    
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentCondensedD {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(92.84, 32.92)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.2, 32.92) controlPoint1: CGPointMake(61.87, 32.92) controlPoint2: CGPointMake(31.49, 32.92)];
    [segmentBezierPath addCurveToPoint: CGPointMake(3.21, 28.84) controlPoint1: CGPointMake(1.39, 31.3) controlPoint2: CGPointMake(2.26, 30.04)];
    [segmentBezierPath addCurveToPoint: CGPointMake(23.02, 3.77) controlPoint1: CGPointMake(9.77, 20.44) controlPoint2: CGPointMake(16.22, 11.96)];
    [segmentBezierPath addCurveToPoint: CGPointMake(29.13, 0.7) controlPoint1: CGPointMake(24.37, 2.13) controlPoint2: CGPointMake(27.03, 0.75)];
    [segmentBezierPath addCurveToPoint: CGPointMake(64.09, 0.66) controlPoint1: CGPointMake(40.77, 0.41) controlPoint2: CGPointMake(52.44, 0.47)];
    [segmentBezierPath addCurveToPoint: CGPointMake(69.16, 2.83) controlPoint1: CGPointMake(65.82, 0.69) controlPoint2: CGPointMake(68.11, 1.55)];
    [segmentBezierPath addCurveToPoint: CGPointMake(91.64, 30.88) controlPoint1: CGPointMake(76.8, 12.06) controlPoint2: CGPointMake(84.19, 21.5)];
    [segmentBezierPath addCurveToPoint: CGPointMake(92.84, 32.92) controlPoint1: CGPointMake(92.01, 31.35) controlPoint2: CGPointMake(92.26, 31.92)];
    [segmentBezierPath closePath];
    
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentCondensedE {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(9.86, 160.07)];
    [segmentBezierPath addCurveToPoint: CGPointMake(33.6, 130.83) controlPoint1: CGPointMake(17.91, 150.21) controlPoint2: CGPointMake(25.86, 140.61)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.84, 125.73) controlPoint1: CGPointMake(34.6, 129.58) controlPoint2: CGPointMake(34.84, 127.46)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.81, 26.82) controlPoint1: CGPointMake(34.91, 92.76) controlPoint2: CGPointMake(34.92, 59.79)];
    [segmentBezierPath addCurveToPoint: CGPointMake(32.83, 21.72) controlPoint1: CGPointMake(34.8, 25.08) controlPoint2: CGPointMake(34.08, 22.74)];
    [segmentBezierPath addCurveToPoint: CGPointMake(5.53, 0) controlPoint1: CGPointMake(23.84, 14.32) controlPoint2: CGPointMake(14.63, 7.19)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.83, 7.81) controlPoint1: CGPointMake(1.69, 1.42) controlPoint2: CGPointMake(0.82, 4.07)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.7, 142.2) controlPoint1: CGPointMake(0.93, 52.61) controlPoint2: CGPointMake(1.1, 97.41)];
    [segmentBezierPath addCurveToPoint: CGPointMake(9.86, 160.07) controlPoint1: CGPointMake(0.63, 149.97) controlPoint2: CGPointMake(3.49, 155.11)];
    [segmentBezierPath closePath];
    
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentCondensedF {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(9.86, 0)];
    [segmentBezierPath addCurveToPoint: CGPointMake(33.6, 29.23) controlPoint1: CGPointMake(17.91, 9.86) controlPoint2: CGPointMake(25.86, 19.46)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.84, 34.33) controlPoint1: CGPointMake(34.6, 30.49) controlPoint2: CGPointMake(34.84, 32.61)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.81, 133.25) controlPoint1: CGPointMake(34.91, 67.3) controlPoint2: CGPointMake(34.92, 100.28)];
    [segmentBezierPath addCurveToPoint: CGPointMake(32.83, 138.34) controlPoint1: CGPointMake(34.8, 134.98) controlPoint2: CGPointMake(34.08, 137.32)];
    [segmentBezierPath addCurveToPoint: CGPointMake(5.53, 160.06) controlPoint1: CGPointMake(23.84, 145.74) controlPoint2: CGPointMake(14.63, 152.88)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.83, 152.25) controlPoint1: CGPointMake(1.69, 158.65) controlPoint2: CGPointMake(0.82, 156)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.7, 17.86) controlPoint1: CGPointMake(0.93, 107.45) controlPoint2: CGPointMake(1.1, 62.66)];
    [segmentBezierPath addCurveToPoint: CGPointMake(9.86, 0) controlPoint1: CGPointMake(0.63, 10.1) controlPoint2: CGPointMake(3.49, 4.95)];
    [segmentBezierPath closePath];
    
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentCondensedG {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(102.02, 16.33)];
    [segmentBezierPath addCurveToPoint: CGPointMake(81.7, 32.68) controlPoint1: CGPointMake(94.56, 22.09) controlPoint2: CGPointMake(88.71, 27.49)];
    [segmentBezierPath addCurveToPoint: CGPointMake(77.36, 33.54) controlPoint1: CGPointMake(80.63, 33.47) controlPoint2: CGPointMake(78.83, 33.53)];
    [segmentBezierPath addCurveToPoint: CGPointMake(24.81, 33.53) controlPoint1: CGPointMake(61.18, 33.59) controlPoint2: CGPointMake(41, 33.59)];
    [segmentBezierPath addCurveToPoint: CGPointMake(20.5, 32.61) controlPoint1: CGPointMake(23.36, 33.53) controlPoint2: CGPointMake(21.58, 33.4)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0, 16.36) controlPoint1: CGPointMake(13.45, 27.45) controlPoint2: CGPointMake(7.54, 22.1)];
    [segmentBezierPath addCurveToPoint: CGPointMake(21.02, 1.07) controlPoint1: CGPointMake(7.69, 10.98) controlPoint2: CGPointMake(13.78, 5.91)];
    [segmentBezierPath addCurveToPoint: CGPointMake(25.44, 0.43) controlPoint1: CGPointMake(22.12, 0.32) controlPoint2: CGPointMake(23.95, 0.43)];
    [segmentBezierPath addCurveToPoint: CGPointMake(76.45, 0.43) controlPoint1: CGPointMake(41.11, 0.39) controlPoint2: CGPointMake(60.78, 0.39)];
    [segmentBezierPath addCurveToPoint: CGPointMake(80.86, 1.05) controlPoint1: CGPointMake(77.94, 0.43) controlPoint2: CGPointMake(79.75, 0.32)];
    [segmentBezierPath addCurveToPoint: CGPointMake(102.02, 16.33) controlPoint1: CGPointMake(88.13, 5.88) controlPoint2: CGPointMake(94.25, 10.94)];
    [segmentBezierPath closePath];
    
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentPlumpA {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(158.17, 0)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.12, 0) controlPoint1: CGPointMake(126.48, 0) controlPoint2: CGPointMake(32.14, 0)];
    [segmentBezierPath addCurveToPoint: CGPointMake(3.2, 4.1) controlPoint1: CGPointMake(1.34, 1.62) controlPoint2: CGPointMake(2.23, 2.89)];
    [segmentBezierPath addCurveToPoint: CGPointMake(23.47, 29.22) controlPoint1: CGPointMake(9.91, 12.51) controlPoint2: CGPointMake(16.52, 21)];
    [segmentBezierPath addCurveToPoint: CGPointMake(29.72, 32.29) controlPoint1: CGPointMake(24.86, 30.85) controlPoint2: CGPointMake(27.58, 32.24)];
    [segmentBezierPath addCurveToPoint: CGPointMake(128.75, 32.33) controlPoint1: CGPointMake(41.64, 32.58) controlPoint2: CGPointMake(116.82, 32.52)];
    [segmentBezierPath addCurveToPoint: CGPointMake(133.94, 30.16) controlPoint1: CGPointMake(130.52, 32.3) controlPoint2: CGPointMake(132.86, 31.44)];
    [segmentBezierPath addCurveToPoint: CGPointMake(156.94, 2.05) controlPoint1: CGPointMake(141.75, 20.91) controlPoint2: CGPointMake(149.31, 11.45)];
    [segmentBezierPath addCurveToPoint: CGPointMake(158.17, 0) controlPoint1: CGPointMake(157.32, 1.57) controlPoint2: CGPointMake(157.58, 1)];
    [segmentBezierPath closePath];
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentPlumpB {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(25.62, 0)];
    [segmentBezierPath addCurveToPoint: CGPointMake(1.32, 29.29) controlPoint1: CGPointMake(17.38, 9.88) controlPoint2: CGPointMake(9.25, 19.5)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.05, 34.4) controlPoint1: CGPointMake(0.31, 30.55) controlPoint2: CGPointMake(0.06, 32.68)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.09, 133.52) controlPoint1: CGPointMake(-0.02, 67.44) controlPoint2: CGPointMake(-0.03, 100.48)];
    [segmentBezierPath addCurveToPoint: CGPointMake(2.11, 138.63) controlPoint1: CGPointMake(0.09, 135.26) controlPoint2: CGPointMake(0.84, 137.6)];
    [segmentBezierPath addCurveToPoint: CGPointMake(30.05, 160.4) controlPoint1: CGPointMake(11.31, 146.04) controlPoint2: CGPointMake(20.74, 153.19)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.86, 152.56) controlPoint1: CGPointMake(33.97, 158.98) controlPoint2: CGPointMake(34.87, 156.32)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.99, 17.9) controlPoint1: CGPointMake(34.75, 107.68) controlPoint2: CGPointMake(34.58, 62.79)];
    [segmentBezierPath addCurveToPoint: CGPointMake(25.62, 0) controlPoint1: CGPointMake(35.06, 10.12) controlPoint2: CGPointMake(32.14, 4.96)];
    [segmentBezierPath closePath];
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentPlumpC {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(25.62, 160.4)];
    [segmentBezierPath addCurveToPoint: CGPointMake(1.32, 131.1) controlPoint1: CGPointMake(17.38, 150.52) controlPoint2: CGPointMake(9.25, 140.9)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.05, 125.99) controlPoint1: CGPointMake(0.31, 129.85) controlPoint2: CGPointMake(0.06, 127.72)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.09, 26.87) controlPoint1: CGPointMake(-0.02, 92.95) controlPoint2: CGPointMake(-0.03, 59.91)];
    [segmentBezierPath addCurveToPoint: CGPointMake(2.11, 21.76) controlPoint1: CGPointMake(0.09, 25.13) controlPoint2: CGPointMake(0.84, 22.79)];
    [segmentBezierPath addCurveToPoint: CGPointMake(30.05, 0) controlPoint1: CGPointMake(11.31, 14.35) controlPoint2: CGPointMake(20.74, 7.2)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.86, 7.83) controlPoint1: CGPointMake(33.97, 1.42) controlPoint2: CGPointMake(34.87, 4.08)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.99, 142.49) controlPoint1: CGPointMake(34.75, 52.72) controlPoint2: CGPointMake(34.58, 97.61)];
    [segmentBezierPath addCurveToPoint: CGPointMake(25.62, 160.4) controlPoint1: CGPointMake(35.06, 150.28) controlPoint2: CGPointMake(32.14, 155.43)];
    [segmentBezierPath closePath];
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentPlumpD {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(158.17, 32.49)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.12, 32.49) controlPoint1: CGPointMake(126.48, 32.49) controlPoint2: CGPointMake(32.14, 32.49)];
    [segmentBezierPath addCurveToPoint: CGPointMake(3.2, 28.39) controlPoint1: CGPointMake(1.34, 30.87) controlPoint2: CGPointMake(2.23, 29.6)];
    [segmentBezierPath addCurveToPoint: CGPointMake(23.47, 3.27) controlPoint1: CGPointMake(9.91, 19.98) controlPoint2: CGPointMake(16.52, 11.49)];
    [segmentBezierPath addCurveToPoint: CGPointMake(29.72, 0.2) controlPoint1: CGPointMake(24.86, 1.64) controlPoint2: CGPointMake(27.58, 0.25)];
    [segmentBezierPath addCurveToPoint: CGPointMake(128.75, 0.16) controlPoint1: CGPointMake(41.64, -0.09) controlPoint2: CGPointMake(116.82, -0.03)];
    [segmentBezierPath addCurveToPoint: CGPointMake(133.94, 2.33) controlPoint1: CGPointMake(130.52, 0.19) controlPoint2: CGPointMake(132.86, 1.05)];
    [segmentBezierPath addCurveToPoint: CGPointMake(156.94, 30.44) controlPoint1: CGPointMake(141.75, 11.58) controlPoint2: CGPointMake(149.31, 21.04)];
    [segmentBezierPath addCurveToPoint: CGPointMake(158.17, 32.49) controlPoint1: CGPointMake(157.32, 30.92) controlPoint2: CGPointMake(157.58, 31.49)];
    [segmentBezierPath closePath];
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentPlumpE {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(9.37, 160.4)];
    [segmentBezierPath addCurveToPoint: CGPointMake(33.67, 131.1) controlPoint1: CGPointMake(17.61, 150.52) controlPoint2: CGPointMake(25.75, 140.9)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.94, 125.99) controlPoint1: CGPointMake(34.68, 129.85) controlPoint2: CGPointMake(34.93, 127.72)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.9, 26.87) controlPoint1: CGPointMake(35.01, 92.95) controlPoint2: CGPointMake(35.02, 59.91)];
    [segmentBezierPath addCurveToPoint: CGPointMake(32.88, 21.77) controlPoint1: CGPointMake(34.9, 25.13) controlPoint2: CGPointMake(34.15, 22.79)];
    [segmentBezierPath addCurveToPoint: CGPointMake(4.94, 0) controlPoint1: CGPointMake(23.68, 14.35) controlPoint2: CGPointMake(14.25, 7.2)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.13, 7.83) controlPoint1: CGPointMake(1.02, 1.42) controlPoint2: CGPointMake(0.12, 4.08)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0, 142.49) controlPoint1: CGPointMake(0.24, 52.72) controlPoint2: CGPointMake(0.41, 97.61)];
    [segmentBezierPath addCurveToPoint: CGPointMake(9.37, 160.4) controlPoint1: CGPointMake(-0.07, 150.28) controlPoint2: CGPointMake(2.85, 155.43)];
    [segmentBezierPath closePath];
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentPlumpF {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(9.37, 0)];
    [segmentBezierPath addCurveToPoint: CGPointMake(33.67, 29.29) controlPoint1: CGPointMake(17.61, 9.88) controlPoint2: CGPointMake(25.75, 19.5)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.94, 34.4) controlPoint1: CGPointMake(34.68, 30.55) controlPoint2: CGPointMake(34.93, 32.68)];
    [segmentBezierPath addCurveToPoint: CGPointMake(34.9, 133.52) controlPoint1: CGPointMake(35.01, 67.44) controlPoint2: CGPointMake(35.02, 100.48)];
    [segmentBezierPath addCurveToPoint: CGPointMake(32.88, 138.63) controlPoint1: CGPointMake(34.9, 135.26) controlPoint2: CGPointMake(34.15, 137.61)];
    [segmentBezierPath addCurveToPoint: CGPointMake(4.94, 160.4) controlPoint1: CGPointMake(23.68, 146.05) controlPoint2: CGPointMake(14.25, 153.19)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.13, 152.57) controlPoint1: CGPointMake(1.02, 158.98) controlPoint2: CGPointMake(0.12, 156.32)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0, 17.9) controlPoint1: CGPointMake(0.24, 107.68) controlPoint2: CGPointMake(0.41, 62.79)];
    [segmentBezierPath addCurveToPoint: CGPointMake(9.37, 0) controlPoint1: CGPointMake(-0.07, 10.12) controlPoint2: CGPointMake(2.85, 4.97)];
    [segmentBezierPath closePath];
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentPlumpG {
    //// Segment Bezier Drawing
    UIBezierPath* segmentBezierPath = [UIBezierPath bezierPath];
    [segmentBezierPath moveToPoint: CGPointMake(167.88, 15.96)];
    [segmentBezierPath addCurveToPoint: CGPointMake(147.08, 32.35) controlPoint1: CGPointMake(160.24, 21.74) controlPoint2: CGPointMake(154.26, 27.14)];
    [segmentBezierPath addCurveToPoint: CGPointMake(142.64, 33.2) controlPoint1: CGPointMake(145.99, 33.14) controlPoint2: CGPointMake(144.14, 33.2)];
    [segmentBezierPath addCurveToPoint: CGPointMake(25.62, 33.2) controlPoint1: CGPointMake(126.08, 33.26) controlPoint2: CGPointMake(42.18, 33.26)];
    [segmentBezierPath addCurveToPoint: CGPointMake(21.2, 32.28) controlPoint1: CGPointMake(24.13, 33.19) controlPoint2: CGPointMake(22.31, 33.07)];
    [segmentBezierPath addCurveToPoint: CGPointMake(0.23, 15.99) controlPoint1: CGPointMake(13.99, 27.11) controlPoint2: CGPointMake(7.95, 21.75)];
    [segmentBezierPath addCurveToPoint: CGPointMake(21.73, 0.67) controlPoint1: CGPointMake(8.1, 10.6) controlPoint2: CGPointMake(14.33, 5.52)];
    [segmentBezierPath addCurveToPoint: CGPointMake(26.26, 0.03) controlPoint1: CGPointMake(22.87, -0.08) controlPoint2: CGPointMake(24.73, 0.03)];
    [segmentBezierPath addCurveToPoint: CGPointMake(141.71, 0.03) controlPoint1: CGPointMake(42.29, -0.01) controlPoint2: CGPointMake(125.67, -0.01)];
    [segmentBezierPath addCurveToPoint: CGPointMake(146.22, 0.65) controlPoint1: CGPointMake(143.23, 0.03) controlPoint2: CGPointMake(145.09, -0.08)];
    [segmentBezierPath addCurveToPoint: CGPointMake(167.88, 15.96) controlPoint1: CGPointMake(153.66, 5.5) controlPoint2: CGPointMake(159.93, 10.56)];
    [segmentBezierPath closePath];
    return segmentBezierPath;
}

+ (UIBezierPath*) bezierSegmentDP {
    //// Segment Bezier Drawing
    UIBezierPath* segmentDPPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1, 1, 30, 30)];
    [segmentDPPath closePath];
    
    return segmentDPPath;
}
@end
