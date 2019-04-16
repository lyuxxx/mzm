//
//  ChapterDirectoryViewController.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "ChapterDirectoryViewController.h"
#import <YBPopupMenu.h>
#import "ChaptersResponseModel.h"
#import "ChapterInfoCell.h"
#import "WriterViewController.h"
#import "LoadingView.h"

@interface NavigationItemCustomView: UIButton
@property (nonatomic, assign) UIEdgeInsets alignmentRectInsetsOverride;
@end

@implementation NavigationItemCustomView

- (UIEdgeInsets)alignmentRectInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(self.alignmentRectInsetsOverride, UIEdgeInsetsZero)) {
        return super.alignmentRectInsets;
    } else {
        return self.alignmentRectInsetsOverride;
    }
}

@end

@interface ChapterDirectoryViewController () <UITableViewDelegate, UITableViewDataSource, YBPopupMenuDelegate, ChapterInfoCellDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ChapterInfo *> *dataSource;
@property (nonatomic, strong) NSMutableArray<ChapterInfo *> *selectedDatas;

@property (nonatomic, strong) NSArray *moreMenuTitles;
@property (nonatomic, strong) NSArray *moreMenuIcons;

@property (nonatomic, strong) UIButton *syncBtn;
@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) UIButton *allBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) NSMutableArray<NSAttributedString *> *infoMenuDataSource;

///是否正序排列
@property (nonatomic, assign) BOOL isPositive;

@end

@implementation ChapterDirectoryViewController

#pragma mark - setter -

- (void)setIsPositive:(BOOL)isPositive {
    _isPositive = isPositive;
    if (isPositive) {
        _moreMenuTitles = @[
                                NSLocalizedString(@"编辑章节", nil),
                                NSLocalizedString(@"章节倒序", nil),
                                NSLocalizedString(@"回收站", nil)
                                ];
        _moreMenuIcons = @[
                           @"catalog_icon_editor",
                           @"catalog_icon_positive_sequence",
                           @"catalog_icon_recycle bin"
                           ];
    } else {
        _moreMenuTitles = @[
                            NSLocalizedString(@"编辑章节", nil),
                            NSLocalizedString(@"章节正序", nil),
                            NSLocalizedString(@"回收站", nil)
                            ];
        _moreMenuIcons = @[
                           @"catalog_icon_editor",
                           @"catalog_icon_positive_sequence",
                           @"catalog_icon_recycle bin"
                           ];
    }
}

#pragma mark - life cycle -

- (void)viewDidLoad {
    [self setupUI];
    [self pullChapters];
}

#pragma mark - private func -

- (void)setupUI {
    self.navigationItem.title = NSLocalizedString(@"章节目录", nil);
    [self setupBarButton];
    [self.view addSubview:self.tableView];
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIView *botView = [[UIView alloc] init];
    botView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:botView];
    [botView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.tableView.bottom);
        make.height.equalTo(49 + kBottomHeight);
    }];
    
    [botView addSubview:self.deleteBtn];
    [self.deleteBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(botView);
        make.height.equalTo(49);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"e9e9e9"];
    [botView addSubview:line];
    [line makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(0.5);
        make.left.top.right.equalTo(botView);
    }];
    
    self.isPositive = NO;///默认为倒序
}

- (void)setupBarButton {
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //https://juejin.im/post/5a52d4316fb9a01c9657f93d 解决leftItem偏移
    CGFloat offset = 25;
    NavigationItemCustomView *backBtn = [NavigationItemCustomView buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"set_icon_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    backBtn.alignmentRectInsetsOverride = UIEdgeInsetsMake(0, offset, 0, -offset);
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [backBtn.widthAnchor constraintEqualToConstant:44].active = YES;
    [backBtn.heightAnchor constraintEqualToConstant:44].active = YES;
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -offset;
    
    self.navigationItem.leftBarButtonItems = @[spaceItem, backItem];
    
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreBtn.adjustsImageWhenHighlighted = NO;
    [self.moreBtn setImage:[UIImage imageNamed:@"catalog_icon_more"] forState:UIControlStateNormal];
    [self.moreBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right0 = [[UIBarButtonItem alloc] initWithCustomView:self.moreBtn];
    
    self.syncBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.syncBtn.adjustsImageWhenHighlighted = NO;
    [self.syncBtn setImage:[UIImage imageNamed:@"bookshelf_icon_icloud"] forState:UIControlStateNormal];
    [self.syncBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithCustomView:self.syncBtn];
    
    self.navigationItem.rightBarButtonItems = @[right0, right1];
    
    [self.moreBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(28);
    }];
    [self.syncBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(28);
    }];
}

- (void)setupEditingBarButton {
    self.allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.allBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.allBtn.adjustsImageWhenHighlighted = NO;
    self.allBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.allBtn setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
    [self.allBtn setTitle:NSLocalizedString(@"取消全选", nil) forState:UIControlStateSelected];
    [self.allBtn setTitleColor:[UIColor colorWithHexString:@"5a5a5a"] forState:UIControlStateNormal];
    [self.allBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:self.allBtn];
    self.navigationItem.leftBarButtonItems = @[left];
    [self.allBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(66);
        make.height.equalTo(32);
    }];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.adjustsImageWhenHighlighted = NO;
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor colorWithHexString:@"5a5a5a"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn];
    self.navigationItem.rightBarButtonItems = @[right];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnClick:(UIButton *)sender {
    if (sender == self.moreBtn) {
        [YBPopupMenu showRelyOnView:self.moreBtn titles:_moreMenuTitles icons:_moreMenuIcons menuWidth:126 delegate:self];
    }
    if (sender == self.cancelBtn) {
        [self.selectedDatas removeAllObjects];
        [self.tableView setEditing:NO animated:YES];
        [self setupBarButton];
        [self hideDeleteButton];
        self.navigationItem.title = NSLocalizedString(@"章节目录", nil);
    }
    if (sender == self.allBtn) {
        sender.selected = !sender.selected;
        if (sender.selected) {//全选
            for (NSInteger i = 0; i < self.dataSource.count; i++) {
                ChapterInfo *item = self.dataSource[i];
                if (![self.selectedDatas containsObject:item]) {
                    [self.selectedDatas addObject:item];
                }
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        } else {//取消全选
            for (NSInteger i = 0; i < self.dataSource.count; i++) {
                ChapterInfo *item = self.dataSource[i];
                if ([self.selectedDatas containsObject:item]) {
                    [self.selectedDatas removeObject:item];
                }
                [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
        
        [self indexPathsForSelectedRowsCountDidChange:self.tableView.indexPathsForSelectedRows];
    }
    if (sender == self.deleteBtn) {
        
        [self deleteSelectedIndexPath:self.tableView.indexPathsForSelectedRows];
        
    }
}

- (void)showDeleteAlertWithResult:(void(^)(BOOL))result {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"温馨提示", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"222222"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    [alertController setValue:title forKey:@"attributedTitle"];
    
    NSAttributedString *message = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"确认删除所选章节吗?", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"919191"],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    [alertController setValue:message forKey:@"attributedMessage"];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"删除", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        result(YES);
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        result(NO);
    }];
    [defaultAction setValue:[UIColor colorWithHexString:@"ffc627"] forKey:@"titleTextColor"];
    [cancelAction setValue:[UIColor colorWithHexString:@"222222"] forKey:@"titleTextColor"];
    [alertController addAction:cancelAction];
    [alertController addAction:defaultAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//delete
- (void)deleteSelectedIndexPath:(NSArray *)indexPaths {
    
    [self showDeleteAlertWithResult:^(BOOL result) {
        if (result) {
            //成功
            //删除数据源
            [self.dataSource removeObjectsInArray:self.selectedDatas];
            [self.selectedDatas removeAllObjects];
            
            //删除选中项
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            
            //验证
            [self indexPathsForSelectedRowsCountDidChange:self.tableView.indexPathsForSelectedRows];
            
            if (self.dataSource.count == 0) {
                //没有章节数据，取消编辑状态
                [self btnClick:self.cancelBtn];
            }
        }
    }];
    
    
}

- (void)indexPathsForSelectedRowsCountDidChange:(NSArray *)selectedRows {
    NSInteger currentCount = [selectedRows count];
    NSInteger allCount = self.dataSource.count;
    self.allBtn.selected = (currentCount == allCount);
    NSString *title = (currentCount > 0) ? [NSString localizedStringWithFormat:NSLocalizedString(@"删除(%zd)", nil),currentCount] : NSLocalizedString(@"删除", nil);
    [self.deleteBtn setTitle:title forState:UIControlStateNormal];
    self.deleteBtn.enabled = currentCount > 0;
}

- (void)showDeleteButton {
    [self.tableView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-49 - kBottomHeight);
    }];
    [self updateConstraints];
}

- (void)hideDeleteButton {
    [self.deleteBtn setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
    [self.tableView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom);
    }];
    
    [self updateConstraints];
}

// 更新布局
- (void)updateConstraints
{
    // tell constraints they need updating
    [self.view setNeedsUpdateConstraints];
    
    // update constraints now so we can animate the change
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)pullChapters {
    [LoadingView showOnView:self.view];
    
    NSDictionary *paras = @{
                            @"token": [[NSUserDefaults standardUserDefaults] stringForKey:@"token"],
                            @"id": self.book.bookid,
                            @"cpage": @"1"
                            };
    
    DefaultServerRequest *request = [[DefaultServerRequest alloc] initWithYype:URITypeChapterList paras:paras delegate:self];
    [request start];
}

- (void)pullChapterContentWithChapterInfo:(ChapterInfo *)info {
    
    NSDictionary *paras = @{
                            @"token": [[NSUserDefaults standardUserDefaults] stringForKey:@"token"],
                            @"id": info.chapterid
                            };
    
    DefaultServerRequest *request = [[DefaultServerRequest alloc] initWithType:URITypeChapterContent paras:paras];
    [request startWithSuccess:^(YBNetworkResponse * _Nonnull response) {
        ChapterInfo *output = [ChapterInfo yy_modelWithDictionary:[(NSDictionary *)response.responseObject objectForKey:@"model"]];
        info.content = output.content;
    } failure:^(YBNetworkResponse * _Nonnull response) {
        
    }];
}

- (void)generateInfoMenuDataSourceWithChapterInfo:(ChapterInfo *)chapterInfo {
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:5];
    
    UIImage *image = [UIImage imageNamed:@"catalog_icon_audit_failure"];
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = image;
    attach.bounds = CGRectMake(0, 0, 14, 14);
    NSAttributedString *attachStr = [NSAttributedString attributedStringWithAttachment:attach];
    
    NSMutableAttributedString *attr0 = [[NSMutableAttributedString alloc] initWithString:@"审核状态:未过审 "];
    [attr0 insertAttributedString:attachStr atIndex:[@"审核状态:未过审 " length]];
    
    NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc] initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"审核结果:%@", nil),chapterInfo.checkMessage] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"5a5a5a"],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSMutableAttributedString *attr2 = [[NSMutableAttributedString alloc] initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"本章字数:%ld", nil),chapterInfo.word_count] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"5a5a5a"],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSMutableAttributedString *attr3 = [[NSMutableAttributedString alloc] initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"上架状态:%@", nil),chapterInfo.status] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"5a5a5a"],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSMutableAttributedString *attr4 = [[NSMutableAttributedString alloc] initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"更新时间:%@", nil),chapterInfo.update_time] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"5a5a5a"],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    [arr addObject:attr0];
    [arr addObject:attr1];
    [arr addObject:attr2];
    [arr addObject:attr3];
    [arr addObject:attr4];
    
    [self.infoMenuDataSource removeAllObjects];
    self.infoMenuDataSource = arr;
}

#pragma mark - YBResponseDelegate -

- (void)request:(__kindof YBBaseRequest *)request successWithResponse:(YBNetworkResponse *)response {
    ChaptersResponseModel *chaptersReponseModel = [ChaptersResponseModel yy_modelWithDictionary:response.responseObject];
    [LoadingView hide];
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:chaptersReponseModel.model.data];
    [self.tableView reloadData];
    
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        [self pullChapterContentWithChapterInfo:self.dataSource[i]];
    }
}

- (void)request:(__kindof YBBaseRequest *)request failureWithResponse:(YBNetworkResponse *)response {
    [LoadingView hide];
}

#pragma mark - YBPopupMenuDelegate -

- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index {
    if (ybPopupMenu.tag == 111) {
        return;
    }
    if (index == 0) {//编辑
        if (self.dataSource.count == 0) {
            return;
        }
        // 这个是fix掉:当你左滑删除的时候，再点击右上角编辑按钮， cell上的删除按钮不会消失掉的bug。且必须放在 设置tableView.editing = YES;的前面。
        [self.tableView reloadData];
        [self.tableView setEditing:YES animated:YES];
        self.allBtn.selected = NO;
        [self setupEditingBarButton];
        [self showDeleteButton];
        self.navigationItem.title = NSLocalizedString(@"编辑章节", nil);
    }
    if (index == 1) {//章节正序倒序
        if (self.dataSource.count == 0) {
            return;
        }
        self.isPositive = !self.isPositive;
    }
    if (index == 2) {//回收站
        UIViewController *binVC = [[NSClassFromString(@"RecycleBinViewController") alloc] init];
        [self.navigationController pushViewController:binVC animated:YES];
    }
}

- (UITableViewCell *)ybPopupMenu:(YBPopupMenu *)ybPopupMenu cellForRowAtIndex:(NSInteger)index {
    if (ybPopupMenu.tag != 111) {
        return nil;
    }
    static NSString *cellId = @"menuCellId";
    UITableViewCell *cell = [ybPopupMenu.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.attributedText = self.infoMenuDataSource[index];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - ChapterInfoCellDelegate -

- (void)chapterInfoCell:(ChapterInfoCell *)cell didClickInfoBtn:(UIButton *)sender {
    NSIndexPath *indexPath = [self. tableView indexPathForCell:cell];
    [self generateInfoMenuDataSourceWithChapterInfo:self.dataSource[indexPath.row]];
    [YBPopupMenu showRelyOnView:sender titles:@[@"",@"",@"",@"",@""] icons:nil menuWidth:235 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.delegate = self;
        popupMenu.showMaskView = NO;
        popupMenu.priorityDirection = YBPopupMenuPriorityDirectionRight;
        popupMenu.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        popupMenu.arrowDirection = YBPopupMenuArrowDirectionRight;
        popupMenu.arrowPosition = 20;
        popupMenu.itemHeight = 30;
        popupMenu.tag = 111;
    }];
}

#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChapterInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:[ChapterInfoCell reuseIdentifier]];
    if (!cell) {
        cell = [[ChapterInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ChapterInfoCell reuseIdentifier]];
    }
    cell.delegate = self;
    [cell configWithChapterInfo:self.dataSource[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) {
        ChapterInfo *item = self.dataSource[indexPath.row];
        if (![self.selectedDatas containsObject:item]) {
            [self.selectedDatas addObject:item];
        }
        [self indexPathsForSelectedRowsCountDidChange:tableView.indexPathsForSelectedRows];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        WriterViewController *vc = [[WriterViewController alloc] initWithChapter:self.dataSource[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) {
        ChapterInfo *item = self.dataSource[indexPath.row];
        if ([self.selectedDatas containsObject:item]) {
            [self.selectedDatas removeObject:item];
        }
        [self indexPathsForSelectedRowsCountDidChange:tableView.indexPathsForSelectedRows];
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"删除", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [tableView setEditing:NO animated:YES];
        ChapterInfo *item = self.dataSource[indexPath.row];
        if (![self.selectedDatas containsObject:item]) {
            [self.selectedDatas addObject:item];
        }
        [self deleteSelectedIndexPath:@[indexPath]];
    }];
    return @[deleteAction];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //只要实现这个方法，就实现了默认滑动删除
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ChapterInfo *item = self.dataSource[indexPath.row];
        if (![self.selectedDatas containsObject:item]) {
            [self.selectedDatas addObject:item];
        }
        [self deleteSelectedIndexPath:@[indexPath]];
    }
}

#pragma mark - DZNEmptyDataSetSource -

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"暂无内容", nil) attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"919191"],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"default_page_icon_kong"];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return - 50;
}

#pragma mark - DZNEmptyDataSetDelegate -

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return NO;
}

- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.25 animations:^{
        scrollView.contentOffset = CGPointZero;
    }];
}

#pragma mark - lazy load -

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.tableFooterView = [UIView new];
//        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [_tableView registerClass:[ChapterInfoCell class] forCellReuseIdentifier:[ChapterInfoCell reuseIdentifier]];
    }
    return _tableView;
}

- (NSMutableArray<ChapterInfo *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray<ChapterInfo *> *)selectedDatas {
    if (!_selectedDatas) {
        _selectedDatas = [NSMutableArray array];
    }
    return _selectedDatas;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.adjustsImageWhenHighlighted = NO;
        [_deleteBtn setTitleColor:[UIColor colorWithHexString:@"ffba15"] forState:UIControlStateNormal];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_deleteBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_deleteBtn setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
    }
    return _deleteBtn;
}

@end
