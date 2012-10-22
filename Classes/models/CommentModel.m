//
//  CommentModel.m
//  Neonan
//
//  Created by capricorn on 12-10-19.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "CommentModel.h"

@implementation CommentModel

- (id)init {
    if ((self = [super init]))
    {
        self.userName = @"user";
        self.time = @"12分钟前";
        self.text = @"杨棋涵毕业于中国音乐学院，有“小范冰冰”之称。以性感、冷艳、奢华、高贵等多种造型成为2010年娱乐媒体关注的焦点，更是频频亮相《男人装》、《瑞丽》、《时尚芭莎》等时尚杂志。杨棋涵毕业于中国音乐学院，有“小范冰冰”之称。以性感、冷艳、奢华、高贵等多种造型成为2010年娱乐媒体关注的焦点，更是频频亮相《男人装》、《瑞丽》、《时尚芭莎》等时尚杂志。";
    }
    return self;
}

@end
