//
//  doFromScrollView.h
//  Do_Test
//
//  Created by yz on 16/10/31.
//  Copyright © 2016年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoReusableView.h"

@class doFormScrollView;
@class DoFormCell;
@class DoFormLeftTopView;
@class DoFormColumnHeaderView;
@class DoFormSectionHeaderView;
@class DoIndexPath;
@class DoColumnHeaderStyle;
@class DoCellStyle;

/**
 代理方法
 */
@protocol FdoFormScrollViewDelegate <NSObject>
- (void)form:(doFormScrollView *)formScrollView didSelectSessionAtIndexPath:(DoIndexPath *)indexPath;
- (void)form:(doFormScrollView *)formScrollView didSelectColumnAtIndexPath:(DoIndexPath *)indexPath;

- (void)form:(doFormScrollView *)formScrollView didSelectCellAtIndexPath:(DoIndexPath *)indexPath;

- (void)form:(doFormScrollView *)formScrollView didLongTouchCellAtIndexPath:(DoIndexPath *)indexPath;

@end

/**
 数据源
 */
@protocol FdoFormScrollViewDataSource <NSObject>

@required
- (NSInteger)numberOfSection:(doFormScrollView *)formScrollView;
- (NSInteger)numberOfColumn:(doFormScrollView *)formScrollView;
- (NSInteger)numberOfFreezeColumn:(doFormScrollView *)formScrollView;
- (CGFloat)form:(doFormScrollView *)formScrollView heightForRowAtSection:(NSInteger)section;

- (DoColumnHeaderStyle *)styleForFormScrollView;

- (DoFormLeftTopView *)form:(doFormScrollView *)formScrollView columnLeftTopAtColumn:(NSInteger)column;
- (DoFormSectionHeaderView *)form:(doFormScrollView *)formScrollView sectionHeaderAtIndexPath:(DoIndexPath *)indexPath;
- (DoFormColumnHeaderView *)form:(doFormScrollView *)formScrollView columnHeaderAtColumn:(NSInteger)column;
- (DoFormCell *)form:(doFormScrollView *)formScrollView cellForColumnAtIndexPath:(DoIndexPath *)indexPath;
@end

@interface doFormScrollView : UIScrollView
@property (nonatomic, assign) BOOL isHeaderVisible;
@property (nonatomic, assign) id<FdoFormScrollViewDelegate>fDelegate;
@property (nonatomic, assign) id<FdoFormScrollViewDataSource>fDataSource;
- (DoFormColumnHeaderView *)dequeueReusableColumnWithIdentifier:(NSString *)identifier;
- (DoFormSectionHeaderView *)dequeueReusableSectionWithIdentifier:(NSString *)identifier;
- (DoFormCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)reloadData;
- (void)reloadCellWithIndexPath:(DoIndexPath *)indexPath;

@end


/**
 Cell
 */
@interface DoFormCell : DoReusableView
@property (nonatomic,strong,readonly) DoIndexPath *indexPath;
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (void)setIndexPath:(DoIndexPath *)indexPath;
@end


/**
 ColumnView
 */
@interface DoFormColumnHeaderView : DoReusableView
@property (nonatomic, assign, readonly) NSInteger column;
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (void)setColumn:(NSInteger)column;
@end


/**
 SectionView
 */
@interface DoFormSectionHeaderView : DoReusableView
@property (nonatomic, strong, readonly) DoIndexPath *indexPath;
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (void)setIndexPath:(DoIndexPath *)indexPath;
@end
/**
 LeftTopView
 */
@interface DoFormLeftTopView : DoReusableView;
@property (nonatomic,assign,readonly) NSInteger column;
-(void)setColumn:(NSInteger)column;
@end

/**
 IndexPath
 */
@interface DoIndexPath : NSObject
+ (instancetype)indexPathForSection:(NSInteger)section inColumn:(NSInteger)column;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger column;
- (NSString *)description;
@end








