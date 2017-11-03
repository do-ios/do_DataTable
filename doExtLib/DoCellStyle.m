//
//  DoCellStyle.m
//  Do_Test
//
//  Created by yz on 16/11/23.
//  Copyright © 2016年 DoExt. All rights reserved.
//

#import "DoCellStyle.h"
#import "doUIModuleHelper.h"

@implementation DoCellStyle

- (instancetype)initCellStyleWithDict:(NSDictionary *)dict
{
    self = [super initWithDict:dict];
    if (self) {
        self.text = [dict objectForKey:@"text"];
        NSString *bgColor = [dict objectForKey:@"bgColor"];
        self.bgColor = [doUIModuleHelper GetColorFromString:bgColor :[UIColor whiteColor]];
    }
    return self;
}
+ (instancetype)cellStyleWithDict:(NSDictionary *)dict
{
    return [[self alloc]initCellStyleWithDict:dict];
}
@end
