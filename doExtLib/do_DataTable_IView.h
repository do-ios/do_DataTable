//
//  do_DataTable_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol do_DataTable_IView <NSObject>

@required
//属性方法
- (void)change_freezeColumn:(NSString *)newValue;
- (void)change_isHeaderVisible:(NSString *)newValue;

//同步或异步方法
- (void)setHeaderData:(NSArray *)parms;
- (void)setHeaderStyle:(NSArray *)parms;
- (void)setRowData:(NSArray *)parms;
- (void)setRowStyle:(NSArray *)parms;
- (void)setCellDatas:(NSArray *)parms;

@end
