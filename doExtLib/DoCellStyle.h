//
//  DoCellStyle.h
//  Do_Test
//
//  Created by yz on 16/11/23.
//  Copyright © 2016年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DoHeaderStyle.h"

@interface DoCellStyle : DoHeaderStyle

@property (nonatomic,copy)      NSString *text;
@property (nonatomic,strong)    UIColor  *bgColor;
- (instancetype)initCellStyleWithDict:(NSDictionary *)dict;
+ (instancetype)cellStyleWithDict:(NSDictionary *)dict;
@end
