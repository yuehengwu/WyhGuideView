//
//  WyhGuideViewProtocol.h
//
//
//  Created by wyh on 2018/4/13.
//  Copyright wyh All rights reserved.
//

#import <Foundation/Foundation.h>

@class WyhGuideView;

@protocol WyhGuideViewDataSource <NSObject>

@required
/**
 return all the guideViews' count.
 */
- (NSInteger)numberOfItemsInGuideView:(WyhGuideView *)guideView;

/**
 return every guideView item.
 */
- (UIView *)guideView:(WyhGuideView *)guideView viewForItemAtIndex:(NSInteger)index;

/**
 return each guideView's description.
 */
- (NSString *)guideView:(WyhGuideView *)guideView descriptionTextForItemAtIndex:(NSInteger)index;

@end

@protocol WyhGuideViewLayoutDelegate <NSObject>

@optional

/**
 The text color / default is white.
 */
- (UIColor *)guideView:(WyhGuideView *)guideView colorForDescriptionLabelAtIndex:(NSInteger)index;

/**
 The font / default is 15.f
 */
- (UIFont *)guideView:(WyhGuideView *)guideView fontForDescriptionLabelAtIndex:(NSInteger)index;

/**
 The corner radius of item.
 */
- (CGFloat)guideView:(WyhGuideView *)guideView cornerRadiusForItemAtIndex:(NSInteger)index;

/**
 The edgeInset of each item. / default is UIEdgeInsetsMake(8, 8, 8, 8)
 */
- (UIEdgeInsets)guideView:(WyhGuideView *)guideView insetsForItemAtIndex:(NSInteger)index;

/**
 The space between textlabel, arrowimage and item. / default is 10.f
 */
- (CGFloat)guideView:(WyhGuideView *)guideView spaceForSubviewsAtIndex:(NSInteger)index;

/**
 The max space between textlabel and screen edge. / default is 50.f
 */
- (CGFloat)guideView:(WyhGuideView *)guideView horizontalSpaceForDescriptionLabelAtIndex:(NSInteger)index;

@end

