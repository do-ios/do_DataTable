//
//  DoRowStyle.m
//  Do_Test
//
//  Created by yz on 16/11/1.
//  Copyright © 2016年 DoExt. All rights reserved.
//

#import "DoHeaderStyle.h"
#import "doJsonHelper.h"
#import "doUIModuleHelper.h"
#import "doServiceContainer.h"
#import "doIGlobal.h"

@interface DoHeaderStyle()

@end

@implementation DoHeaderStyle

- (instancetype)initWithDict:(NSDictionary *)_dictParas
{
    self = [super init];
    if (self) {
        [self calculateZoom];
        NSString *height = [doJsonHelper GetOneText:_dictParas :@"height" :@"80"];
        self.height = [height floatValue] * _yZoom;
        NSString *fontColor = [doJsonHelper GetOneText:_dictParas :@"fontColor" :@"000000FF"];
        self.fontColor = [doUIModuleHelper GetColorFromString:fontColor :[UIColor blackColor]];
        NSString *fontStyle = [doJsonHelper GetOneText:_dictParas :@"fontStyle" :@"normal"];
        self.fontStyle = fontStyle;
        NSString *textFlag = [doJsonHelper GetOneText:_dictParas :@"textFlag" :@"normal"];
        self.textFlag = textFlag;
        int fontSize = [doJsonHelper GetOneInteger:_dictParas :@"fontSize" :17];
        self.fontSize = [self setFontDeviceFontSize:fontSize];
    }
    return self;
}
+ (instancetype)doStyleWithDict:(NSDictionary *)_dictParas
{
    return  [[self alloc]initWithDict:_dictParas];
}
- (int)setFontDeviceFontSize:(int)fontSize
{
    return  [doUIModuleHelper GetDeviceFontSize:fontSize :_xZoom :_yZoom];
}
- (void)calculateZoom
{
    double screenwidth = (double)([doServiceContainer Instance].Global.ScreenWidth);
    double screenheight = (double)([doServiceContainer Instance].Global.ScreenHeight);
    double designWidth = [doServiceContainer Instance].Global.DesignScreenWidth;
    double designHeight = [doServiceContainer Instance].Global.DesignScreenHeight;
    CGFloat xZoom,yZoom;
    if (screenwidth <= 0) {
        xZoom = 1;
    }else{
        xZoom = screenwidth / designWidth;
    }
    if (screenheight <= 0)
    {
        yZoom = 1;
    }
    else
    {
        yZoom = screenheight / designHeight;
    }
    _xZoom = xZoom;
    _yZoom = yZoom;
}
@end
