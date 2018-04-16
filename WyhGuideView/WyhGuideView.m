//
//  WyhGuideView.m
//
//
//  Created by wyh on 2018/4/13.
//  Copyright wyh All rights reserved.
//

#import "WyhGuideView.h"

typedef NS_ENUM(NSInteger, WyhGuideViewItemDirection)
{
    WyhGuideViewItemDirectionLeftTop = 0,
    WyhGuideViewItemDirectionLeftBottom,
    WyhGuideViewItemDirectionRightTop,
    WyhGuideViewItemDirectionRightBottom
};

CGFloat const wyh_defaultEdgeInset = 8.f;

static CGFloat const _textLabelEdgeInsetX = 50.f;
static CGFloat const _arrowSpaceY = 10.f;
static CGFloat const _defaultCornerRadius = 5.f;

@interface WyhGuideView ()

@property (nonatomic, strong) UIImageView *arrowImgView;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) NSInteger itemCount;

@end

@implementation WyhGuideView

+ (instancetype)guideViewWithDataSource:(id<WyhGuideViewDataSource>)dataSource Delegate:(id<WyhGuideViewLayoutDelegate>)delegate {
    WyhGuideView *guide = [[WyhGuideView alloc]initWithDataSource:dataSource Delegate:delegate];
    return guide;
}

- (instancetype)initWithDataSource:(id<WyhGuideViewDataSource>)dataSource Delegate:(id<WyhGuideViewLayoutDelegate>)delegate {
    
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _dataSource = dataSource;
        _delegate = delegate;
        [self configUI];
        [self initialize];
    }
    return self;
}

- (void)configUI {
    
    [self addSubview:self.maskView];
    [self addSubview:self.arrowImgView];
    [self addSubview:self.textLabel];
    
}

- (void)initialize {
    
    self.backgroundColor     = [UIColor clearColor];
    self.currentIndex = 0;
    self.maskBackgroundColor = [UIColor blackColor];
    self.maskAlpha  = .7f;
    self.arrowImage = [UIImage imageNamed:@"arrow"];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [UIFont systemFontOfSize:15];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGuideView:)];
    [self addGestureRecognizer:tap];
}

#pragma mark - API

- (void)show {
    
    self.currentIndex = 0;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInGuideView:)]) {
        self.itemCount = [self.dataSource numberOfItemsInGuideView:self];
    }
    
    if (self.itemCount < 1)  {
        NSAssert(NO, @"numberOfItemsInGuideView: must be valid !");
    };
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.alpha = 0;
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = 1;
    }];
    
    [self showUI];
}

- (void)showUI {
    
    [self showMask];
    [self configGuideViewFrame];
    
}

#pragma mark - Methods

- (void)dismiss {
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)tapGuideView:(UITapGestureRecognizer *)tapGesture {
    
    if (self.currentIndex == self.itemCount - 1) {
        [self dismiss];
    } else {
        self.currentIndex++;
        [self showUI];
    }
}

#pragma mark - Private

- (void)configGuideViewFrame {
    
    // text color.
    if ([self.delegate respondsToSelector:@selector(guideView:colorForDescriptionLabelAtIndex:)])
    {
        self.textLabel.textColor = [self.delegate guideView:self colorForDescriptionLabelAtIndex:self.currentIndex];
    }
    // text font.
    if ([self.delegate respondsToSelector:@selector(guideView:fontForDescriptionLabelAtIndex:)])
    {
        self.textLabel.font = [self.delegate guideView:self fontForDescriptionLabelAtIndex:self.currentIndex];
    }
    
    // text description.
    NSString *desc = @"";
    if ([self.dataSource respondsToSelector:@selector(guideView:descriptionTextForItemAtIndex:)]) {
        desc = [self.dataSource guideView:self descriptionTextForItemAtIndex:self.currentIndex];
    }
    self.textLabel.text = desc;
    [self.textLabel sizeToFit];
    
    // get every item on the edge of the screen.
    CGFloat descInsetsX = _textLabelEdgeInsetX;
    if ([self.delegate respondsToSelector:@selector(guideView:horizontalSpaceForDescriptionLabelAtIndex:)]) {
        descInsetsX = [self.delegate guideView:self horizontalSpaceForDescriptionLabelAtIndex:self.currentIndex];
    }
    
    // get arrow space.
    CGFloat space = _arrowSpaceY;
    if ([self.delegate respondsToSelector:@selector(guideView:spaceForSubviewsAtIndex:)]) {
        space = [self.delegate guideView:self spaceForSubviewsAtIndex:self.currentIndex];
    }
    
    
    // config textLabel and arrow imageView of the direction.
    
    CGRect textRect, arrowRect;
    CGSize imgSize   = self.arrowImgView.image.size;
    CGFloat maxWidth = self.bounds.size.width - descInsetsX * 2;
    CGSize textSize  = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName : self.textLabel.font}
                                          context:NULL].size;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    /// 获取 item 的 方位
    WyhGuideViewItemDirection itemRegion = [self getCurrentItemDirection];
    
    CGFloat x = 0;
    
    switch (itemRegion) {
        case WyhGuideViewItemDirectionLeftTop: {
            transform = CGAffineTransformMakeScale(-1, 1);
            arrowRect = CGRectMake(CGRectGetMidX([self getCurrentItemFrame]) - imgSize.width * 0.5,
                                   CGRectGetMaxY([self getCurrentItemFrame]) + space,
                                   imgSize.width,
                                   imgSize.height);
            
            
            if (textSize.width < CGRectGetWidth([self getCurrentItemFrame])) {
                x = CGRectGetMaxX(arrowRect) - textSize.width * 0.5;
            } else {
                x = descInsetsX;
            }
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + space, textSize.width, textSize.height);
        } break;
        case WyhGuideViewItemDirectionRightTop: {
            arrowRect = CGRectMake(CGRectGetMidX([self getCurrentItemFrame]) - imgSize.width * 0.5,
                                   CGRectGetMaxY([self getCurrentItemFrame]) + space,
                                   imgSize.width,
                                   imgSize.height);
            
            if (textSize.width < CGRectGetWidth([self getCurrentItemFrame])) {
                x = CGRectGetMinX(arrowRect) - textSize.width * 0.5;
            }
            else {
                x = descInsetsX + maxWidth - textSize.width;
            }
            
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + space, textSize.width, textSize.height);
        } break;
        case WyhGuideViewItemDirectionLeftBottom:
        {
            /// 左下
            transform = CGAffineTransformMakeScale(-1, -1);
            arrowRect = CGRectMake(CGRectGetMidX([self getCurrentItemFrame]) - imgSize.width * 0.5,
                                   CGRectGetMinY([self getCurrentItemFrame]) - space - imgSize.height,
                                   imgSize.width,
                                   imgSize.height);
            
            if (textSize.width < CGRectGetWidth([self getCurrentItemFrame])) {
                x = CGRectGetMaxX(arrowRect) - textSize.width * 0.5;
            }
            else {
                x = descInsetsX;
            }
            
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - space - textSize.height, textSize.width, textSize.height);
        } break;
        case WyhGuideViewItemDirectionRightBottom: {
            
            transform = CGAffineTransformMakeScale(1, -1);
            arrowRect = CGRectMake(CGRectGetMidX([self getCurrentItemFrame]) - imgSize.width * 0.5,
                                   CGRectGetMinY([self getCurrentItemFrame]) - space - imgSize.height,
                                   imgSize.width,
                                   imgSize.height);
            
            if (textSize.width < CGRectGetWidth([self getCurrentItemFrame])) {
                x = CGRectGetMinX(arrowRect) - textSize.width * 0.5;
            } else {
                x = descInsetsX + maxWidth - textSize.width;
            }
            
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - space - textSize.height, textSize.width, textSize.height);
        } break;
    }
    
    self.arrowImgView.transform = transform;
    self.textLabel.frame = textRect;
    self.arrowImgView.frame = arrowRect;
    
    // Animation.
    self.arrowImgView.alpha = 0;
    self.textLabel.alpha = 0;
    [UIView animateWithDuration:.3f animations:^{
        self.arrowImgView.alpha = 1;
        self.textLabel.alpha = 1;
    }];
}

- (void)showMask
{
//    CGPathRef fromPath = self.maskLayer.path; // get last path.
    self.maskLayer.frame = self.bounds;
    self.maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    // get radius.
    CGFloat maskCornerRadius = _defaultCornerRadius;
    if ([self.delegate respondsToSelector:@selector(guideView:cornerRadiusForItemAtIndex:)]) {
        maskCornerRadius = [self.delegate guideView:self cornerRadiusForItemAtIndex:self.currentIndex];
    }
    
    // draw the path.
    UIBezierPath *itemPath = [UIBezierPath bezierPathWithRoundedRect:[self getCurrentItemFrame] cornerRadius:maskCornerRadius];
    UIBezierPath *toPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [toPath appendPath:itemPath];
    
    self.maskLayer.path = toPath.CGPath;
    self.maskLayer.fillRule = kCAFillRuleEvenOdd; // will be hollow.
    self.layer.mask = self.maskLayer;
    
    
    // Move animation.
    /*
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.duration  = .3f;
    anim.fromValue = (__bridge id _Nullable)(fromPath);
    anim.toValue   = (__bridge id _Nullable)(toPath.CGPath);
    [self.maskLayer addAnimation:anim forKey:NULL];
     */
}

- (CGRect)getCurrentItemFrame
{
    if (self.currentIndex >= self.itemCount)
    {
        NSAssert(NO, @"Current index was more than item count");
        return CGRectZero;
    }
    
    UIView *currentView = [self.dataSource guideView:self viewForItemAtIndex:self.currentIndex];
    
    CGRect visualRect = [currentView convertRect:currentView.bounds toView:[UIApplication sharedApplication].delegate.window];// get current covertRect to the screen.
    
    UIEdgeInsets maskInsets = UIEdgeInsetsMake(wyh_defaultEdgeInset, wyh_defaultEdgeInset, wyh_defaultEdgeInset, wyh_defaultEdgeInset);
    
    if ([self.delegate respondsToSelector:@selector(guideView:insetsForItemAtIndex:)])
    {
        maskInsets = [self.delegate guideView:self insetsForItemAtIndex:self.currentIndex];
    }
    
    visualRect.origin.x -= maskInsets.left;
    visualRect.origin.y -= maskInsets.top;
    visualRect.size.width  += (maskInsets.left + maskInsets.right);
    visualRect.size.height += (maskInsets.top + maskInsets.bottom);
    
    return visualRect;
}


- (WyhGuideViewItemDirection)getCurrentItemDirection
{
    
    CGPoint itemCenter = CGPointMake(CGRectGetMidX([self getCurrentItemFrame]),
                                       CGRectGetMidY([self getCurrentItemFrame]));
    CGPoint screenCenter = CGPointMake(CGRectGetMidX(self.bounds),
                                       CGRectGetMidY(self.bounds));
    
    if (itemCenter.x <= screenCenter.x && itemCenter.y <= screenCenter.y) {
        return WyhGuideViewItemDirectionLeftTop;
    }
    
    if (itemCenter.x > screenCenter.x && itemCenter.y <= screenCenter.y) {
        return WyhGuideViewItemDirectionRightTop;
    }
    
    if (itemCenter.x <= screenCenter.x && itemCenter.y > screenCenter.y) {
        return WyhGuideViewItemDirectionLeftBottom;
    }
    
    return WyhGuideViewItemDirectionRightBottom;
}

#pragma mark - Setter

- (void)setArrowImage:(UIImage *)arrowImage {
    _arrowImage = arrowImage;
    self.arrowImgView.image = arrowImage;
}

- (void)setMaskBackgroundColor:(UIColor *)maskBackgroundColor {
    _maskBackgroundColor = maskBackgroundColor;
    self.maskView.backgroundColor = maskBackgroundColor;
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    _maskAlpha = maskAlpha;
    self.maskView.alpha = maskAlpha;
}

#pragma mark - Lazy

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
    }
    return _maskLayer;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _maskView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [UIImageView new];
    }
    return _arrowImgView;
}


@end
