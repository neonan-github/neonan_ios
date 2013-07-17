//
//  MottoModel.m
//  Neonan
//
//  Created by capricorn on 13-6-25.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "MottoModel.h"

@implementation MottoModel

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *imgMapping = [DCObjectMapping mapKeyPath:@"image" toAttribute:@"imageUrl" onClass:self];
    [config addObjectMapping:imgMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.imageUrl = [aDecoder decodeObjectForKey:@"url"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.imageUrl forKey:@"url"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.content forKey:@"content"];
}

@end
