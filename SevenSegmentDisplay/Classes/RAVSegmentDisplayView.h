//
//  RAVSegmentDisplay.h
//  glass
//
//  Created by Aleksey Rochev on 18.03.16.
//  Copyright © 2016 Aleksey Rochev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SevenSegmentIndicator/RAVSegmentIndicatorView.h>

IB_DESIGNABLE

@protocol RAVSegmentDisplayViewDelegate;

@interface RAVSegmentDisplayView : UIView

@property (nonatomic, weak) id <RAVSegmentDisplayViewDelegate> delegate;

/**
 *@brief Number of indicators on display
 *@note By default is == 3,
 *
 */
@property (nonatomic) IBInspectable NSInteger countIndicators;
/**
 *@brief Font
 *@note Is can be Condensed or Plump
 *
 */
@property (nonatomic) IBInspectable RAVSegmentIndicatorViewFontType typeFont;
/**
 *@brief Backlight indicator color
 *@note When you set color animation will broke
 *@warning You don't need set color often!
 *
 */
@property (nonatomic, copy) IBInspectable UIColor *colorActive;
/**
 *@brief Backlight indicator color for disabale state (фон)
 *@note When you set color animation will broke
 *@warning You don't need set color often!
 *
 */
@property (nonatomic, copy) IBInspectable UIColor *colorDefault;
/**
 *@brief Integer value
 *@note If `animation == YES` will start animation
 *
 */
@property (nonatomic) NSInteger integerValue;
/**
 *@brief CGFloat value
 *@note If `animation == YES` will start animation. Value will rounded to 10!
 *
 */
@property (nonatomic) CGFloat floatValue;
/**
 *@brief String value
 *@note If `animation == YES` will start animation
 *
 */
@property (nonatomic) NSString *stringValue;
/**
 *@brief Animation
 *@note  Animation can be start
 *
 */
@property (nonatomic) IBInspectable BOOL animation;
/**
 *@brief Animation duration
 *@note Animation duration for value changing
 *
 */
@property (nonatomic) NSTimeInterval animationDuration;
/**
 *@brief Disable indicator with value == 0
 *@note When value is zero indicator will hidden
 *
 */
@property (nonatomic, getter=isDisableNullValue) IBInspectable BOOL disableNullValue;
/**
 *@brief Disable all display
 *@note  This is not clearAllIndicators
 *
 */
@property (nonatomic, getter=isOff) IBInspectable BOOL off;
/**
 *@brief Indicators array
 *@note All indicator on display
 *
 */
@property (nonatomic, readonly) NSArray *indicators;
/**
 *@brief All indicators will not active state
 *
 */
- (void) clearAllIndicators;
/**
 *@brief All indicators will active state
 *
 */
- (void) setAllIndicators;

@end

@protocol RAVSegmentDisplayViewDelegate <NSObject>

@optional
- (void) display: (RAVSegmentDisplayView *) display touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) display: (RAVSegmentDisplayView *) display touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
