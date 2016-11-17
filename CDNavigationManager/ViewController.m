//
//  ViewController.m
//  CDNavigationManager
//
//  Created by chendi on 16/11/17.
//  Copyright © 2016年 chendi. All rights reserved.
//  lao liu ge dou bi kan bu dao zhe ju hua de ha ha zzz

#import "ViewController.h"
#import "FirstViewController.h"
#import "UIView+CDExtension.h"

@interface ViewController ()<UIScrollViewDelegate>

/** 顶部的所有标签 */
@property (nonatomic, weak) UIView *titlesView;

/** 标签栏底部的红色指示器 */
@property (nonatomic, weak) UIView *indicatorView;

/** 当前选中的按钮 */
@property (nonatomic, weak) UIButton *selectedButton;

/** 底部的所有内容 */
@property (nonatomic, weak) UIScrollView *contentView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化子控制器
    [self setupChidVces];
    
    // 设置顶部的标签栏
    [self setupTitlesView];
    
    // 底部的scrollView
    [self setupContentView];
}

/**
 * 底部的scrollView
 */
- (void)setupContentView{
    // 不要自动调整inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIScrollView *contentView = ({
        UIScrollView *view = [[UIScrollView alloc] init];
        view.frame = self.view.bounds;
        view.delegate = self;
        view.pagingEnabled = YES;
        [self.view insertSubview:view atIndex:0];
        view.contentSize = CGSizeMake(view.width * self.childViewControllers.count, 0);
        view;
    });
    self.contentView = contentView;
    
    // 添加第一个控制器的view
    [self scrollViewDidEndScrollingAnimation:contentView];
}

/**
 * 设置顶部的标签栏
 */
- (void)setupTitlesView{
    // 标签栏整体
    UIView *titlesView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        view.width = self.view.width;
        view.height = 35;
        view.y = 64;
        [self.view addSubview:view];
        view;
    });
    self.titlesView = titlesView;
    
    // 底部的红色指示器
    UIView *indicatorView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor redColor];
        view.height = 2;
        view.tag = -1;
        view.y = titlesView.height - view.height;
        [self.view addSubview:view];
        view;
    });
    self.indicatorView = indicatorView;
    
    // 内部子标签
    CGFloat width = titlesView.width / self.childViewControllers.count;
    CGFloat height = titlesView.height;
    for (NSInteger i = 0; i < self.childViewControllers.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = i;
        button.height = height;
        button.width = width;
        button.x = i * width;
        // 取出子控制器
        UIViewController *vc = self.childViewControllers[i];
        [button setTitle:vc.title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        [titlesView addSubview:button];
        // 默认点击了第一个按钮
        if (i == 0) {
            button.enabled = NO;
            self.selectedButton = button;
            
            // 让按钮内部的label根据文字内容来计算尺寸
            [button.titleLabel sizeToFit];// 设置了固定宽高的Label的文字会随着文字的多少来自适应大小，在国际化中常用（ps有些语言真的很长）
            self.indicatorView.width = button.titleLabel.width;
            self.indicatorView.centerX = button.centerX;
        }
    }
    
    [titlesView addSubview:indicatorView];
}

- (void)titleClick:(UIButton *)button{
    // 修改按钮状态
    self.selectedButton.enabled = YES;
    button.enabled = NO;
    self.selectedButton = button;
    
    // 动画
    [UIView animateWithDuration:0.25 animations:^{
        self.indicatorView.width = button.titleLabel.width;
        self.indicatorView.centerX = button.centerX;
    }];
    
    // 滚动
    CGPoint offset = self.contentView.contentOffset;
    offset.x = button.tag * self.contentView.width;
    [self.contentView setContentOffset:offset animated:YES];
}

/**
 * 初始化子控制器 
 */
- (void)setupChidVces{
    FirstViewController *vc1 = [[FirstViewController alloc] init];
    vc1.title = @"vc1";
    vc1.backgroundColor = [UIColor cyanColor];
    [self addChildViewController:vc1];
    
    FirstViewController *vc2 = [[FirstViewController alloc] init];
    vc2.title = @"vc2";
    vc2.backgroundColor = [UIColor blueColor];
    [self addChildViewController:vc2];
    
    FirstViewController *vc3 = [[FirstViewController alloc] init];
    vc3.title = @"vc3";
    vc3.backgroundColor = [UIColor yellowColor];
    [self addChildViewController:vc3];
    
    FirstViewController *vc4 = [[FirstViewController alloc] init];
    vc4.title = @"vc4";
    vc4.backgroundColor = [UIColor redColor];
    [self addChildViewController:vc4];
    
    FirstViewController *vc5 = [[FirstViewController alloc] init];
    vc5.title = @"vc5";
    vc5.backgroundColor = [UIColor greenColor];
    [self addChildViewController:vc5];
}


#pragma mark -- UIScrollViewDelegate --

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    // 当前的索引
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    
    // 取出子控制器
    UIViewController *vc = self.childViewControllers[index];
    vc.view.x = scrollView.contentOffset.x;
    vc.view.y = 0; // 设置控制器view的y值为0(默认是20)
    vc.view.height = scrollView.height; // 设置控制器view的height值为整个屏幕的高度(默认是比屏幕高度少个20)
    
    [scrollView addSubview:vc.view];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
    // 点击按钮
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    [self titleClick:self.titlesView.subviews[index]];
}

@end
