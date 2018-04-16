//
//  ViewController.m
//  WyhGuideViewTest
//
//  Created by wyh on 2018/4/13.
//  Copyright © 2018年 Wyh. All rights reserved.
//

#import "ViewController.h"
#import "WyhGuideView.h"

@interface ViewController ()<WyhGuideViewDataSource,WyhGuideViewLayoutDelegate>

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;

@property (nonatomic, strong) NSArray *viewArray;
@property (nonatomic, strong) NSArray *textArr;

@property (nonatomic, strong) WyhGuideView *guideView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.guideView = [WyhGuideView guideViewWithDataSource:self Delegate:self];
    
    self.viewArray = @[self.view1,self.view2,self.view3];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.guideView show];
}

- (IBAction)start:(id)sender {
    
    [self.guideView show];
}

#pragma mark - dataSource

- (NSInteger)numberOfItemsInGuideView:(WyhGuideView *)guideView {
    return self.textArr.count;
}

- (UIView *)guideView:(WyhGuideView *)guideView viewForItemAtIndex:(NSInteger)index {
    return self.viewArray[index];
}

- (NSString *)guideView:(WyhGuideView *)guideView descriptionTextForItemAtIndex:(NSInteger)index {
    return self.textArr[index];
}

- (CGFloat)guideView:(WyhGuideView *)guideView cornerRadiusForItemAtIndex:(NSInteger)index {
    if (index == 2) {
        return (58.f + 2*wyh_defaultEdgeInset)/2; // If you want to show a circle mask, don't forget the edge.
    }
    return 5.f;
}

- (NSArray *)textArr {
    if (!_textArr) {
        _textArr = @[@"① 这里记录您每日的动态",@"② 发现页面入口",@"③ 开启您的视野"];
    }
    return _textArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
