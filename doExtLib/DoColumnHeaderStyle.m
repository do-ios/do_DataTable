//
//  DoHeaderStyle.m
//  Do_Test
//
//  Created by yz on 16/11/1.
//  Copyright © 2016年 DoExt. All rights reserved.
//

#import "DoColumnHeaderStyle.h"
#import "doJsonHelper.h"
#import "doServiceContainer.h"
#import "doILogEngine.h"
#import "doUIModuleHelper.h"

@implementation DoColumnHeaderStyle
-(instancetype)initWithDict:(NSDictionary *)_dictParas
{
    self = [super initWithDict:_dictParas];
    if (self) {
        @try {
            NSString *widthStr = [doJsonHelper GetOneText:_dictParas :@"width" :@"100"];
            NSString *bgColor = [doJsonHelper GetOneText:_dictParas :@"bgColor" :@"00000000"];
            self.bgColor = [doUIModuleHelper GetColorFromString:bgColor :[UIColor whiteColor]];
            //需要注意zoom
            if ([widthStr hasPrefix:@"["]) {//数组
                NSData  *rowData = [widthStr dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSArray *temp = [NSJSONSerialization JSONObjectWithData:rowData options:NSJSONReadingAllowFragments error:&error];
                if (error) {
                    [NSException raise:@"do_DataTable" format:@"setHeaderStyle方法的width参数异常"];
                }
                self.widthArray = [NSMutableArray array];
                for (id objc in temp) {
                    if ([objc isKindOfClass:[NSString class]]) {
                        NSNumber *widthNum = [[NSNumber alloc] initWithFloat:((NSString*)objc).floatValue * self.xZoom];
                        [self.widthArray addObject:widthNum];
                    }else if ([objc isKindOfClass:[NSNumber class]]) {
                        NSNumber *widthNum = [NSNumber numberWithFloat:((NSNumber*)objc).floatValue * self.xZoom];
                        [self.widthArray addObject:widthNum];
                    }
                }
            }
            else
            {
                self.widthArray = [NSMutableArray arrayWithObject:@([widthStr floatValue] * self.xZoom)];
            }
        } @catch (NSException *exception) {
            [[doServiceContainer Instance].LogEngine WriteError:exception :@"setHeaderStyle的参数异常"];
        }
    }
    return self;
}
+ (instancetype)doHeaderStyleWithDict:(NSDictionary *)_dictParas
{
    return  [[self alloc]initWithDict:_dictParas];
}
@end
