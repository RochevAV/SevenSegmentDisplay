//
//  RAVSegmentIndicatorView.h
//  RAVSevenSegmentView
//
//  Created by Aleksey Rochev on 18.03.16.
//  Copyright © 2016 Aleksey Rochev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, RAVSegmentIndicatorViewFontType) {
    RAVSegmentIndicatorViewFontCondensed,
    RAVSegmentIndicatorViewFontPlump
};

#pragma mark -

IB_DESIGNABLE

@interface RAVSegmentIndicatorView : UIView <NSCopying>
/**
 *@brief Font type
 *@note Condensed &Plump
 *
 */
@property RAVSegmentIndicatorViewFontType typeFont;

/**
 *@brief Segment backlight color
 *@note If set color then animation break
 *@warning It is not necessary to often set color!
 *
 */
@property (nonatomic, copy) IBInspectable UIColor *colorActive;
/**
 *@brief Indicator color
 *@note If set color then animation break
 *@warning It is not necessary to often set color!
 *
 */
@property (nonatomic, copy) IBInspectable UIColor *colorDefault;
/**
 *@brief Value
 *@note If property 'animation' == YES then after setting value start animation
 *
 */
@property (nonatomic) NSInteger value;
/**
 *@brief Code - binary value
 *@note  If property 'animation' == YES then after setting value start animation
 *
 */
@property (nonatomic) NSInteger codeIndicator;
/**
 *@brief Animation
 *@note Enabled animation after change value
 *
 */
@property (nonatomic) IBInspectable BOOL animation;
/**
 *@brief Animation Duration
 *
 */
@property (nonatomic) IBInspectable NSTimeInterval animationDuration;
/*!
 *@brief Array layers
 */
@property (nonatomic, readonly) NSDictionary *layers;
/**
 *@brief Indicator with point
 *
 */
@property (nonatomic, getter=isOne) IBInspectable BOOL one;
/**
 *@brief Indicator is off
 *@note  All elements disabled
 *
 */
@property (nonatomic, getter=isOff) BOOL off;
/**
 *@brief All segments in not active
 *
 */
- (void) clearAllSegments;
/**
 *@brief All segments in active
 *
 */
- (void) setAllSegments;

@end

#pragma mark -

@interface RAVSegmentIndicatorView (Alphabet)

+ (NSInteger) codeWithInteger:(NSInteger)value;

+ (NSInteger) codeWithChar:(char)value;
+ (NSInteger) codeWithString:(NSString *)value;

+ (NSInteger) codeForClearSegments;
+ (NSInteger) codeForSetAllSegments;

@end

#pragma mark -

@interface RAVSegmentIndicatorView (Paint)

+ (NSArray<UIBezierPath *> *) arrBezierSegmentsWithType: (RAVSegmentIndicatorViewFontType) type;
+ (NSArray<UIBezierPath *> *) arrLayerSegmentsWithType: (RAVSegmentIndicatorViewFontType) type;

+ (CAShapeLayer*) layerBackgroundWithRect:(CGRect) rect withType: (RAVSegmentIndicatorViewFontType) type;

@end

#pragma mark -

@interface RAVSegmentIndicatorView (Animation)

+ (CABasicAnimation*) transformAnimationFromAngle: (CGFloat) fromAngle
                                          toAngle:(CGFloat) toAngle
                                         duration:(CGFloat) duration;

+ (CAKeyframeAnimation*) fillColorAnimationFromColor: (UIColor *) fromColor
                                             toColor: (UIColor *) toColor
                                            duration: (NSTimeInterval) duration;

@end
