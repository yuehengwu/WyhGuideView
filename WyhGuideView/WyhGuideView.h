//
//  WyhGuideView.h
//
//
//  Created by wyh on 2018/4/13.
//  Copyright wyh All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WyhGuideViewProtocol.h"

UIKIT_EXTERN CGFloat const wyh_defaultEdgeInset;

@interface WyhGuideView : UIView

@property (nonatomic, assign) id<WyhGuideViewDataSource> dataSource;
@property (nonatomic, assign) id<WyhGuideViewLayoutDelegate> delegate;

@property (nonatomic, strong) UIImage *arrowImage;
@property (nonatomic, strong) UIColor *maskBackgroundColor;
@property (nonatomic, assign) CGFloat maskAlpha;

+ (instancetype)guideViewWithDataSource:(id<WyhGuideViewDataSource>)dataSource Delegate:(id<WyhGuideViewLayoutDelegate>)delegate;
/**
 Please perform this function in 'viewDidAppear:' or layout finished.
 */
- (void)show;

@end
