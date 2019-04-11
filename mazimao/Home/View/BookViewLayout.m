//
//  BookViewLayout.m
//  mazimao
//
//  Created by wuhan006 on 2019/4/11.
//  Copyright © 2019 intelligent. All rights reserved.
//

#import "BookViewLayout.h"

@interface BookViewLayout ()
@property (nonatomic, assign) NSInteger columnCount;
@property (nonatomic, assign) CGFloat columnSpace;
@property (nonatomic, assign) CGFloat rowSpace;
@property (nonatomic, assign) UIEdgeInsets sectionInsets;

@property (nonatomic, assign) CGFloat contentX;

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributesArray;

@end

@implementation BookViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.columnCount = [self.collectionView numberOfItemsInSection:0];
    self.columnSpace = 50.0;
    self.rowSpace = 10.0;
    self.sectionInsets = UIEdgeInsetsMake(0, self.collectionView.bounds.size.width * 0.1, 0, self.collectionView.bounds.size.width * 0.1);
    self.contentX = self.sectionInsets.left;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    [self.attributesArray removeAllObjects];
    for (NSInteger index = 0; index < [self.collectionView numberOfItemsInSection:0]; index++) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [self.attributesArray addObject:attributes];
        }
    }
    return self.attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat width = self.collectionView.bounds.size.width;
    CGFloat height = self.collectionView.bounds.size.height;
    
    CGFloat w = width * 0.8;
    CGFloat h = height * 0.8;
    
    CGFloat x = self.sectionInsets.left + (self.columnSpace + w) * indexPath.item;
    CGFloat y = height * 0.1;
    
    attributes.frame = CGRectMake(x, y, w, h);
    
    self.contentX = attributes.frame.origin.x + attributes.frame.size.width;
    
    return attributes;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.contentX + self.sectionInsets.right, 0);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat midCenterX = self.collectionView.center.x;
    CGFloat cellWidth = self.collectionView.bounds.size.width * 0.8;
    
    CGFloat realMidX = proposedContentOffset.x + midCenterX;
    
    CGFloat more = fmodf(realMidX - self.sectionInsets.left, cellWidth + self.columnSpace);
    
    return CGPointMake(proposedContentOffset.x - (more - cellWidth * 0.5), 0);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)attributesArray {
    if (!_attributesArray) {
        _attributesArray = [NSMutableArray array];
    }
    return _attributesArray;
}

@end
