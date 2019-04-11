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
#import "BookViewLayout.h"
#import "ProfileViewController.h"
#import "LoadingView.h"
#import "ChapterDirectoryViewController.h"
#import "UserInfoResponseModel.h"
#import <UIButton+WebCache.h>

@interface BooksViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIButton *profileBtn;
@property (nonatomic, strong) UIButton *downloadedBtn;
@property (nonatomic, strong) UIButton *syncBtn;
@property (nonatomic, strong) UICollectionView *collectionView;
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
    [self.view addSubview:self.collectionView];
    [self.collectionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(-150);
    }];
    
    [self.view addSubview:self.enterBtn];
    [self.enterBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(156);
        make.height.equalTo(40);
        make.centerX.equalTo(0);
        make.top.equalTo(self.collectionView.bottom).offset(48);
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
    self.pageControl.center = CGPointMake(kScreenWidth * 0.5, self.collectionView.frame.origin.y + self.collectionView.frame.size.height);
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
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (sender == self.enterBtn) {
        ChapterDirectoryViewController *vc = [[ChapterDirectoryViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pullUserInfo {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *paras = @{
                            @"token": [[NSUserDefaults standardUserDefaults] stringForKey:@"token"]
                            };
    
    NSString *url = @"https://www.qingoo.cn/api/user/get";
    [manager GET:url parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        UserInfoResponseModel *responseModel = [UserInfoResponseModel yy_modelWithDictionary:responseObject];
        self.user = responseModel.model.data;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)pullData {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *paras = @{
                            @"token": [[NSUserDefaults standardUserDefaults] stringForKey:@"token"],
                            @"source": @"mazimao"
                            };
    
    NSString *url = @"https://www.qingoo.cn/api/book/list";
    [manager GET:url parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BooksResponseModel *booksResponse = [BooksResponseModel yy_modelWithDictionary:responseObject];
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:booksResponse.model.data];
        [self.collectionView reloadData];
        [self setupPageControl];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BookCell reuseIdentifier] forIndexPath:indexPath];
    [cell configWithBook:self.dataSource[indexPath.item]];
    return cell;
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //1.根据偏移量判断一下应该显示第几个item
    CGFloat offSetX = targetContentOffset->x;
    
    CGFloat itemWidth = self.collectionView.bounds.size.width * 0.8;
    
    //item的宽度+行间距 = 页码的宽度
    NSInteger pageWidth = itemWidth + 50.0;
    
    //根据偏移量计算是第几页
    NSInteger pageNum = (offSetX+pageWidth/2)/pageWidth;
    
    self.pageControl.currentPage = pageNum;
}

#pragma mark - lazy load -

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        BookViewLayout *layout = [[BookViewLayout alloc] init];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:[BookCell class] forCellWithReuseIdentifier:[BookCell reuseIdentifier]];
    }
    return _collectionView;
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
