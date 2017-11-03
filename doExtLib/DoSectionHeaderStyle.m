//
//  DoSectionHeaderStyle.m
//  Do_Test
//
//  Created by yz on 16/11/3.
//  Copyright © 2016年 DoExt. All rights reserved.
//

#import "DoSectionHeaderStyle.h"
#import "doUIModuleHelper.h"
#import "doJsonHelper.h"
#import "doServiceContainer.h"
#import "doILogEngine.h"


@implementation DoSectionHeaderStyle
- (instancetype)initWithDict:(NSDictionary *)_dictParas
{
    self = [super initWithDict:_dictParas];
    if (self) {
        self.bgColors = [NSMutableArray array];
        @try {
            NSArray *colors = [doJsonHelper GetOneArray:_dictParas :@"bgColor"];
            for (NSString *color in colors) {
                UIColor *temp = [doUIModuleHelper GetColorFromString:color :[UIColor whiteColor]];
                [self.bgColors addObject:temp];
            }
        } @catch (NSException *exception) {
            [[doServiceContainer Instance].LogEngine WriteError:exception :@"setRowStyle的参数异常"];
        }
    }
    return  self;
}
+(instancetype)sectionHeaderStyle:(NSDictionary *)_dictParas
{
    return [[self alloc]initWithDict:_dictParas];
}
@end
