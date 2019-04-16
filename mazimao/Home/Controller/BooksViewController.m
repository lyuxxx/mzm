//
//  BooksViewController.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "BooksViewController.h"
#import "EllipsePageControl.h"
#import <UIViewController+CWLateralSlide.h>
#import "BookCell.h"
#import "ProfileViewController.h"
#import "LoadingView.h"
#import "ChapterDirectoryViewController.h"
#import "UserInfoResponseModel.h"
#import <UIButton+WebCache.h>
#import <SDCycleScrollView.h>

@interface BooksViewController () <SDCycleScrollViewDelegate>
@property (nonatomic, strong) UIButton *profileBtn;
@property (nonatomic, strong) UIButton *downloadedBtn;
@property (nonatomic, strong) UIButton *syncBtn;
@property (nonatomic, strong) SDCycleScrollView *cycleView;
@property (nonatomic, strong) EllipsePageControl *pageControl;
@property (nonatomic, strong) UIButton *enterBtn;

@property (nonatomic, strong) NSMutableArray<Book *> *dataSource;

@property (nonatomic, strong) User *user;
@end

@implementation BooksViewController

#pragma mark - setter -

- (void)setUser:(User *)user {
    _user = user;
    [self.profileBtn sd_setImageWithURL:[NSURL URLWithString:_user.image] forState:UIControlStateNormal];
}

#pragma mark - life cycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self registerGesture];
    [self pullUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [self pullData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - private func -

- (void)setupUI {
    self.navigationItem.title = NSLocalizedString(@"书籍", nil);
    [self setupBarButton];
    [self.view addSubview:self.cycleView];
    [self.cycleView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(-150);
    }];
    
    [self.view addSubview:self.enterBtn];
    [self.enterBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(156);
        make.height.equalTo(40);
        make.centerX.equalTo(0);
        make.top.equalTo(self.cycleView.bottom).offset(48);
    }];
}

- (void)setupBarButton {
    self.profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.profileBtn.layer.cornerRadius = 14;
    self.profileBtn.layer.masksToBounds = YES;
    self.profileBtn.adjustsImageWhenHighlighted = NO;
    [self.profileBtn setImage:[UIImage imageNamed:@"bookshelf_icon_persal"] forState:UIControlStateNormal];
    [self.profileBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.profileBtn];
    [self.profileBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(28);
    }];
    
    self.downloadedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadedBtn.adjustsImageWhenHighlighted = NO;
    [self.downloadedBtn setImage:[UIImage imageNamed:@"loading"] forState:UIControlStateNormal];
    [self.downloadedBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem0 = [[UIBarButtonItem alloc] initWithCustomView:self.downloadedBtn];
    
    self.syncBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.syncBtn.adjustsImageWhenHighlighted = NO;
    [self.syncBtn setImage:[UIImage imageNamed:@"bookshelf_icon_icloud"] forState:UIControlStateNormal];
    [self.syncBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithCustomView:self.syncBtn];
    
    self.navigationItem.rightBarButtonItems = @[rightItem0, rightItem1];
    
    [self.downloadedBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(28);
    }];
    
    [self.syncBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(28);
    }];
}

- (void)setupPageControl {
    [self.pageControl removeFromSuperview];
    self.pageControl.frame = CGRectMake(0, 0, (6 + 5) * self.dataSource.count + 6 - 5, 6);
    self.pageControl.center = CGPointMake(kScreenWidth * 0.5, self.cycleView.frame.origin.y + self.cycleView.frame.size.height);
    [self.view addSubview:self.pageControl];
     self.pageControl.numberOfPages = self.dataSource.count;
    if (self.dataSource.count > 1) {
        self.pageControl.hidden = NO;
    } else {
        self.pageControl.hidden = YES;
    }
}

//注册左滑手势
- (void)registerGesture {
    // 注册手势驱动
    __weak typeof(self)weakSelf = self;
    [self cw_registerShowIntractiveWithEdgeGesture:YES transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        if (direction == CWDrawerTransitionFromLeft) { // 左侧滑出
            [weakSelf btnClick:self.profileBtn];
        } else if (direction == CWDrawerTransitionFromRight) { // 右侧滑出
            
        }
    }];
}

- (void)btnClick:(UIButton *)sender {
    if (sender == self.profileBtn) {
        ProfileViewController *vc = [[ProfileViewController alloc] init];
        vc.user = self.user;
        
        CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration defaultConfiguration];
        conf.direction = CWDrawerTransitionFromLeft;
        conf.maskAlpha = 0.02;
        [self cw_showDrawerViewController:vc animationType:CWDrawerAnimationTypeDefault configuration:conf];
    }
    if (sender == self.downloadedBtn) {
        UIViewController *vc = [[NSClassFromString(@"DownloadBooksViewController") alloc] init];
//        UIViewController *vc = [[NSClassFromString(@"WriterViewController") alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (sender == self.enterBtn) {
        ChapterDirectoryViewController *vc = [[ChapterDirectoryViewController alloc] init];
        vc.book = self.dataSource[self.pageControl.currentPage];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pullUserInfo {
    NSDictionary *paras = @{
                            @"token": [[NSUserDefaults standardUserDefaults] stringForKey:@"token"]
                            };
    DefaultServerRequest *request = [[DefaultServerRequest alloc] initWithType:URITypeUserInfo paras:paras];
    weakifySelf
    [request startWithSuccess:^(YBNetworkResponse * _Nonnull response) {
        strongifySelf
        UserInfoResponseModel *responseModel = [UserInfoResponseModel yy_modelWithDictionary:response.responseObject];
        self.user = responseModel.model.data;
    } failure:^(YBNetworkResponse * _Nonnull response) {
        
    }];
}

- (void)pullData {
    
    NSDictionary *paras = @{
                            @"token": [[NSUserDefaults standardUserDefaults] stringForKey:@"token"],
                            };
    DefaultServerRequest *request = [[DefaultServerRequest alloc] initWithYype:URITypeBookList paras:paras delegate:self];
    [request start];
    
}

#pragma mark - YBResponseDelegate -

- (void)request:(__kindof YBBaseRequest *)request successWithResponse:(YBNetworkResponse *)response {
    BooksResponseModel *booksResponse = [BooksResponseModel yy_modelWithDictionary:response.responseObject];
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:booksResponse.model.data];
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        [tmp addObject:@""];
    }
    self.cycleView.imageURLStringsGroup = tmp;
    [self setupPageControl];
}

- (void)request:(__kindof YBBaseRequest *)request failureWithResponse:(YBNetworkResponse *)response {
    
}

#pragma mark - SDCycleScrollViewDelegate -

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    ChapterDirectoryViewController *vc = [[ChapterDirectoryViewController alloc] init];
    vc.book = self.dataSource[index];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    if (self.pageControl.currentPage != index) {
        self.pageControl.currentPage = index;
    }
}

- (Class)customCollectionViewCellClassForCycleScrollView:(SDCycleScrollView *)view {
    return [BookCell class];
}

- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index cycleScrollView:(SDCycleScrollView *)view {
    BookCell *bookCell = (BookCell *)cell;
    [bookCell configWithBook:self.dataSource[index]];
}

#pragma mark - lazy load -

- (SDCycleScrollView *)cycleView {
    if (!_cycleView) {
        _cycleView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:nil];
        _cycleView.backgroundColor = [UIColor whiteColor];
        _cycleView.infiniteLoop = YES;
        _cycleView.showPageControl = NO;
        _cycleView.autoScroll = NO;
    }
    return _cycleView;
}

- (EllipsePageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[EllipsePageControl alloc] init];
        _pageControl.currentColor = [UIColor colorWithHexString:@"ffc627"];
        _pageControl.otherColor = [UIColor colorWithHexString:@"d9d9d9"];
        _pageControl.controlSize = 6;
        _pageControl.controlSpacing = 5;
    }
    return _pageControl;
}

- (UIButton *)enterBtn {
    if (!_enterBtn) {
        _enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _enterBtn.adjustsImageWhenHighlighted = NO;
        _enterBtn.layer.cornerRadius = 3;
        _enterBtn.layer.masksToBounds = YES;
        _enterBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_enterBtn setTitle:NSLocalizedString(@"进入书籍", nil) forState:UIControlStateNormal];
        [_enterBtn setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, 156, 40);
        gradient.colors = @[(id)[UIColor colorWithHexString:@"ffd450"].CGColor,(id)[UIColor colorWithHexString:@"ffc627"].CGColor];
        gradient.startPoint = CGPointMake(0, 0.5);
        gradient.endPoint = CGPointMake(1, 0.5);
        
        [_enterBtn setBackgroundImage:[gradient snapshotImage] forState:UIControlStateNormal];
        [_enterBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterBtn;
}

- (NSMutableArray<Book *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
