//
//  do_DataTable_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_DataTable_UIView.h"

#import "doInvokeResult.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doJsonHelper.h"
#import "doServiceContainer.h"
#import "doILogEngine.h"
#import "doIOHelper.h"
#import "doFormScrollView.h"
#import "DoColumnHeaderStyle.h"
#import "DoSectionHeaderStyle.h"
#import "doFormScrollView.h"
#import "DoCellStyle.h"


@interface do_DataTable_UIView()<FdoFormScrollViewDelegate,FdoFormScrollViewDataSource>
{
    NSInteger _freezeColumn;
    BOOL _isHeaderVisible;
    
    NSArray *_headerDataArray;
    NSArray *_rowDataArray;
    
    DoColumnHeaderStyle *_headerStyle;
    DoSectionHeaderStyle *_rowStyle;
    doFormScrollView *_formScrollView;
    //调用setCellData方法设置的cell样式集合
    NSMutableDictionary *_cellStyleDict;
}

@end

@implementation do_DataTable_UIView
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    _formScrollView = [[doFormScrollView alloc]init];
    _formScrollView.frame = [self getCurrentFrame];
    _formScrollView.backgroundColor = [UIColor clearColor];
    _formScrollView.fDelegate = self;
    _formScrollView.fDataSource = self;
    //调用一次默认值
    _formScrollView.isHeaderVisible = YES;
    _isHeaderVisible = YES;
    _freezeColumn = 1;
    [self addSubview:_formScrollView];
    [self commonInit];
}
//销毁所有的全局对象
- (void) OnDispose
{
//    UITableView
    //自定义的全局属性,view-model(UIModel)类销毁时会递归调用<子view-model(UIModel)>的该方法，将上层的引用切断。所以如果self类有非原生扩展，需主动调用view-model(UIModel)的该方法。(App || Page)-->强引用-->view-model(UIModel)-->强引用-->view
    _formScrollView.fDelegate = nil;
    _formScrollView.fDataSource = nil;
    [_formScrollView removeFromSuperview];
    _formScrollView = nil;
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改,如果添加了非原生的view需要主动调用该view的OnRedraw，递归完成布局。view(OnRedraw)<显示布局>-->调用-->view-model(UIModel)<OnRedraw>
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
    _formScrollView.frame = [self getCurrentFrame];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_freezeColumn:(NSString *)newValue
{
    //自己的代码实现
    _freezeColumn = [newValue integerValue];
}
- (void)change_isHeaderVisible:(NSString *)newValue
{
    //自己的代码实现
    _isHeaderVisible = [newValue boolValue];
    _formScrollView.isHeaderVisible = _isHeaderVisible;
    [_formScrollView reloadData];
}

#pragma mark -
#pragma mark - 同步异步方法的实现
//同步
- (void)setHeaderData:(NSArray *)parms
{
    //参数字典_dictParas
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    _headerDataArray = [doJsonHelper GetOneArray:_dictParas :@"data"];
    _formScrollView.isHeaderVisible = _headerDataArray.count > 0 ? true : false;
}
- (void)setHeaderStyle:(NSArray *)parms
{
    //参数字典_dictParas
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //列样式
    _headerStyle = [DoColumnHeaderStyle doHeaderStyleWithDict:_dictParas];
}

- (void)setRowData:(NSArray *)parms
{
    _rowDataArray = nil;
    //参数字典_dictParas
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSString *rowDataStr = [doJsonHelper GetOneText:_dictParas :@"data" :@""];
    @try {
        NSArray *tempArray;
        if ([rowDataStr hasPrefix:@"data://"]) {//文件
            NSString *filePath = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentApp :rowDataStr];
            NSError *error;
            NSData *rowData = [NSData dataWithContentsOfFile:filePath];
            tempArray = [NSJSONSerialization JSONObjectWithData:rowData options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                [NSException raise:@"do_DataTable" format:@"setRowData方法的data参数异常"];
            }
        }
        else
        {
            NSData  *rowData = [rowDataStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            tempArray = [NSJSONSerialization JSONObjectWithData:rowData options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                [NSException raise:@"do_DataTable" format:@"setRowData方法的data参数异常"];
            }
        }
        _rowDataArray = tempArray;
    } @catch (NSException *exception) {
        [[doServiceContainer Instance].LogEngine WriteError:exception :@"setRowData方法的data参数异常"];
    }
    [_cellStyleDict removeAllObjects];
    [_formScrollView reloadData];
}
- (void)setRowStyle:(NSArray *)parms
{
    //参数字典_dictParas
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //行数据的样式
    _rowStyle = [DoSectionHeaderStyle sectionHeaderStyle:_dictParas];
}
- (void)setCellDatas:(NSArray *)parms
{
    if (_rowDataArray.count < 1) {//调用在setRowData之前不处理
        return;
    }
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    NSArray *cells = [doJsonHelper GetOneArray:_dictParas :@"data"];
    if (cells.count == 1) {
        NSDictionary *cellDict = [cells firstObject];
        int x = [doJsonHelper GetOneInteger:cellDict :@"row" :0];
        int y = [doJsonHelper GetOneInteger:cellDict :@"column" :0];
        NSString *text = [doJsonHelper GetOneText:cellDict :@"text" :@""];
        NSDictionary *style = [doJsonHelper GetOneNode:cellDict :@"style"];
        DoCellStyle *cellStyle = [DoCellStyle cellStyleWithDict:style];
        cellStyle.text = text;
        if (!cellStyle.bgColor ) {
            cellStyle.bgColor = _rowStyle.bgColors[x/2];
        }
        if (!cellStyle.fontColor &&_rowStyle.fontColor) {
            cellStyle.fontColor = _rowStyle.fontColor;
        }
        if ([cellStyle.fontStyle isEqualToString:@"normal"]) {
            cellStyle.fontStyle = _rowStyle.fontStyle;
        }
        if ([cellStyle.textFlag isEqualToString:@"normal"]) {
            cellStyle.textFlag = _rowStyle.textFlag;
        }
        if (cellStyle.fontSize < 8) {
            cellStyle.fontSize = _rowStyle.fontSize;
        }
        //构造key
        NSString *cellKey = [NSString stringWithFormat:@"%d-%d",x,y];
        [_cellStyleDict setObject:cellStyle forKey:cellKey];
        [_formScrollView reloadCellWithIndexPath:[DoIndexPath indexPathForSection:x inColumn:y]];
        return;
    }
    for (NSDictionary *dict in cells) {
        int x = [doJsonHelper GetOneInteger:dict :@"row" :0];
        int y = [doJsonHelper GetOneInteger:dict :@"column" :0];
        NSString *text = [doJsonHelper GetOneText:dict :@"text" :@""];
        NSDictionary *style = [doJsonHelper GetOneNode:dict :@"style"];
        DoCellStyle *cellStyle = [DoCellStyle cellStyleWithDict:style];
        cellStyle.text = text;
        //构造key
        if (!cellStyle.bgColor ) {
            cellStyle.bgColor = _rowStyle.bgColors[x/2];
        }
        if (!cellStyle.fontColor &&_rowStyle.fontColor) {
            cellStyle.fontColor = _rowStyle.fontColor;
        }
        if ([cellStyle.fontStyle isEqualToString:@"normal"]) {
            cellStyle.fontStyle = _rowStyle.fontStyle;
        }
        if ([cellStyle.textFlag isEqualToString:@"normal"]) {
            cellStyle.textFlag = _rowStyle.textFlag;
        }
        if (cellStyle.fontSize < 8) {
            cellStyle.fontSize = _rowStyle.fontSize;
        }
        NSString *cellKey = [NSString stringWithFormat:@"%d-%d",x,y];
        [_cellStyleDict setObject:cellStyle forKey:cellKey];
        
    }
    [_formScrollView reloadData];
}
#pragma mark - 代理方法
- (void)form:(doFormScrollView *)formScrollView didSelectCellAtIndexPath:(DoIndexPath *)indexPath
{
    [self fireEvent:@"touch" withParma:indexPath];
}
- (void)form:(doFormScrollView *)formScrollView didSelectSessionAtIndexPath:(DoIndexPath *)indexPath
{
    [self fireEvent:@"touch" withParma:indexPath];
}
- (void)form:(doFormScrollView *)formScrollView didLongTouchCellAtIndexPath:(DoIndexPath *)indexPath
{
    [self fireEvent:@"longTouch" withParma:indexPath];
}
#pragma mark - 数据源方法 FdoFormScrollViewDataSource
- (NSInteger)numberOfColumn:(doFormScrollView *)formScrollView
{
    //如果headerData没有数据，则以rowData的第一行的列数为准
    if (_headerDataArray) {
       return _headerDataArray.count;
    }
    else
    {
        return  ((NSArray *)[_rowDataArray objectAtIndex:0]).count;
    }
}
- (NSInteger)numberOfSection:(doFormScrollView *)formScrollView
{
    return _rowDataArray.count;
}

/**
 冻结列

 @param formScrollView <#formScrollView description#>
 @return <#return value description#>
 */
-(NSInteger)numberOfFreezeColumn:(doFormScrollView *)formScrollView
{
    return _freezeColumn;
}

/**
 行高

 @param formScrollView <#formScrollView description#>
 @param section <#section description#>
 @return <#return value description#>
 */
- (CGFloat)form:(doFormScrollView *)formScrollView heightForRowAtSection:(NSInteger)section
{
    return _rowStyle.height;
}

- (DoColumnHeaderStyle *)styleForFormScrollView
{
    if (_headerDataArray.count <=0) {//没有headData不显示header
        _formScrollView.isHeaderVisible = NO;
    }
    return _headerStyle;
}
- (DoFormLeftTopView *)form:(doFormScrollView *)formScrollView columnLeftTopAtColumn:(NSInteger)column
{
    if (!_isHeaderVisible) {
        return nil;
    }
    if (_freezeColumn <= 0) {
        return nil;
    }
    if (_headerDataArray.count <=0) {//没有headData不显示header
        return nil;
    }
    NSString *content = [_headerDataArray objectAtIndex:column];
    DoFormLeftTopView *leftTopView = [[DoFormLeftTopView alloc]init];
    [leftTopView setContent:content withHeaderStyle:_headerStyle];
    return leftTopView;
}

- (DoFormColumnHeaderView *)form:(doFormScrollView *)formScrollView columnHeaderAtColumn:(NSInteger)column
{
    DoFormColumnHeaderView *header = [formScrollView dequeueReusableColumnWithIdentifier:@"Column"];
    if (!header) {
        header = [[DoFormColumnHeaderView alloc]initWithIdentifier:@"Column"];
    }
    NSString *content = [_headerDataArray objectAtIndex:column];
    header.column = column;
    [header setContent:content withHeaderStyle:_headerStyle];
    return header;
}

- (DoFormSectionHeaderView *)form:(doFormScrollView *)formScrollView sectionHeaderAtIndexPath:(DoIndexPath *)indexPath;
{
    //1,2:x,y
    NSString *format = [NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.column];
    DoFormSectionHeaderView *header = [formScrollView dequeueReusableSectionWithIdentifier:@"Section"];
    if (!header) {
        header = [[DoFormSectionHeaderView alloc]initWithIdentifier:@"Section"];
    }
    NSString *content = [[_rowDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.column];
    [header setIndexPath:indexPath];
    if ([self isContainIndexPath:format]) {
        
        DoCellStyle *cellStyle = [_cellStyleDict objectForKey:format];
        if (cellStyle.text.length < 1) {
            [header setContent:content withHeaderStyle:cellStyle];
        }
        else{
           [header setContent:cellStyle.text withHeaderStyle:cellStyle];
        }
        return header;
    }
    [header setContent:content withHeaderStyle:_rowStyle];
    return header;
}
- (DoFormCell *)form:(doFormScrollView *)formScrollView cellForColumnAtIndexPath:(DoIndexPath *)indexPath
{
    //1,2:x,y
    NSString *format = [NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.column];
    
    DoFormCell *cell = [formScrollView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[DoFormCell alloc]initWithIdentifier:@"Cell"];
    }
    NSString *content = @"";
    @try {
        content = [[_rowDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.column];
    } @catch (NSException *exception) {
        content = @"";
    }
    cell.indexPath = indexPath;
    if ([self isContainIndexPath:format]) {
        DoCellStyle *cellStyle = [_cellStyleDict objectForKey:format];
        if (cellStyle.text.length < 1) {//默认处理
            [cell setContent:content withHeaderStyle:cellStyle];
        }
        else
        {
            [cell setContent:cellStyle.text withHeaderStyle:cellStyle];
        }
        return cell;
    }
    [cell setContent:content withHeaderStyle:_rowStyle];
    return cell;
}
#pragma mark - 私有方法
- (BOOL)isContainIndexPath:(NSString *)format
{
    for (NSString *cellKey in _cellStyleDict.allKeys) {
        if ([format isEqualToString:cellKey]) {
            return YES;
        }
    }
    return  NO;
}
/**
 得到frame
 */
-(CGRect)getCurrentFrame
{
    CGRect frame = CGRectMake(0, 0, _model.RealWidth, _model.RealHeight);
    return frame;
}

/**
 默认初始化
 */
- (void)commonInit
{
    NSDictionary *headerStyleDict = [NSDictionary dictionaryWithObjectsAndKeys:@"100",@"width",@"80",@"height",@"00000000",@"bgColor",@"000000FF",@"fontColor",@"normal",@"fontStyle",@"normal",@"textFlag", @"17",@"fontSize",nil];
    _headerStyle = [DoColumnHeaderStyle doHeaderStyleWithDict:headerStyleDict];
    
    NSDictionary *rowStyleDict = [NSDictionary dictionaryWithObjectsAndKeys:@"80",@"height",@[@"00000000"],@"bgColor",@"000000FF",@"fontColor",@"normal",@"fontStyle",@"normal",@"textFlag",@"17",@"fontSize",nil];
    _rowStyle = [DoSectionHeaderStyle sectionHeaderStyle:rowStyleDict];
    
    _cellStyleDict = [NSMutableDictionary dictionary];
}
- (void)fireEvent:(NSString *)eventName withParma:(DoIndexPath *)indexPath
{
    NSLog(@"section = %ld, column = %ld",(long)indexPath.section,(long)indexPath.column);
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:@(indexPath.section) forKey:@"row"];
    [node setObject:@(indexPath.column) forKey:@"column"];
    doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
    [invokeResult SetResultNode:node];
    [_model.EventCenter FireEvent:eventName :invokeResult];
}
#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}

@end
