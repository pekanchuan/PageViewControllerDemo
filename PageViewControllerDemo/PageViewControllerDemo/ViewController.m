//
//  ViewController.m
//  PageViewControllerDemo
//
//  Created by chia on 2019/2/19.
//  Copyright © 2019 pekanchuan. All rights reserved.
//

#import "ViewController.h"
#import "ContentViewController.h"

@interface ViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, copy) NSArray *pageContentArray;
@property (nonatomic, strong) NSMutableArray *contentVCs;
@property (nonatomic, strong) NSCache *contentVCCache;

@end

@implementation ViewController

#pragma mark - Lazy Load

- (NSArray *)pageContentArray {
    if (!_pageContentArray) {
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSInteger i = 0; i < 10; i++) {
            NSString *contentString = [[NSString alloc] initWithFormat:@"This is the page %ld of content displayed using UIPageViewController", i];
            [arrayM addObject:contentString];
        }
        _pageContentArray = [[NSArray alloc] initWithArray:arrayM];
    }
    return _pageContentArray;
}

- (NSMutableArray *)contentVCs {
    if (_contentVCs == nil) {
        _contentVCs = [NSMutableArray array];
    }
    return _contentVCs;
}

- (NSCache *)contentVCCache {
    if (_contentVCCache == nil) {
        _contentVCCache = [[NSCache alloc] init];
    }
    return _contentVCCache;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey: @(20)};
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    ContentViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
    self.pageViewController.view.frame = self.view.bounds;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
}

#pragma mark - UIPageViewControllerDataSource And UIPageViewControllerDelegate

#pragma mark 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(ContentViewController *)viewController];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法,自动来维护次序
    // 不用我们去操心每个ViewController的顺序问题
    return [self viewControllerAtIndex:index];
}

#pragma mark 返回下一个ViewController对象

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(ContentViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == self.pageContentArray.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - 根据index得到对应的UIViewController

- (ContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (self.pageContentArray.count == 0 || index >= self.pageContentArray.count) {
        return nil;
    }
    
    /*
     * 此处可以用数组来保存已创建的 controller
     * NSCache 的好处是当遇到内存警告的时候会自动释放
     */
    
    //    ContentViewController *contentVC;
    //    if (self.contentVCs.count == 0 || index >= self.contentVCs.count) {
    //        contentVC = [[ContentViewController alloc] init];
    //        [self.contentVCs addObject:contentVC];
    //    } else {
    //        contentVC = [self.contentVCs objectAtIndex:index];
    //    }
    ContentViewController *contentVC = [self.contentVCCache objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    if (contentVC == nil) {
        contentVC = [[ContentViewController alloc] init];
        [self.contentVCCache setObject:contentVC forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
    //    contentVC = [[ContentViewController alloc] init];
    contentVC.content = [self.pageContentArray objectAtIndex:index];
    return contentVC;
}

#pragma mark - 数组元素值，得到下标值

- (NSUInteger)indexOfViewController:(ContentViewController *)viewController {
    return [self.pageContentArray indexOfObject:viewController.content];
}


@end
