//
//  DoHeaderStyle.h
//  Do_Test
//
//  Created by yz on 16/11/1.
//  Copyright © 2016年 DoExt. All rights reserved.
//

#import "DoHeaderStyle.h"

/**
 列标头样式
 */
@interface DoColumnHeaderStyle : DoHeaderStyle
/**
 背景色
 */
@property(nonatomic,strong)     UIColor *bgColor;
/**
 宽度数组
 */
@property(nonatomic,strong)     NSMutableArray*widthArray;

-(instancetype)initWithDict:(NSDictionary *)_dictParas;

/**
 初始化方法

 @param _dictParas <#_dictParas description#>
 @return <#return value description#>
 */
+(instancetype)doHeaderStyleWithDict:(NSDictionary *)_dictParas;
@end
