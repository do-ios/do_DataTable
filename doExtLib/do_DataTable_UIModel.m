//
//  do_DataTable_Model.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_DataTable_UIModel.h"
#import "doProperty.h"

@implementation do_DataTable_UIModel

#pragma mark - 注册属性（--属性定义--）
/*
[self RegistProperty:[[doProperty alloc]init:@"属性名" :属性类型 :@"默认值" : BOOL:是否支持代码修改属性]];
 */
-(void)OnInit
{
    [super OnInit];    
    //属性声明
    [self RegistProperty:[[doProperty alloc]init:@"freezeColumn" :Number :@"1" :YES]];
    [self RegistProperty:[[doProperty alloc]init:@"isHeaderVisible" :Bool :@"true" :NO]];}

@end
