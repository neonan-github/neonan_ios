//
//  UserInfoModel.m
//  Bang
//
//  Created by capricorn on 13-1-8.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *vipMapping = [DCObjectMapping mapKeyPath:@"is_vip" toAttribute:@"vip" onClass:self];
    [config addObjectMapping:vipMapping];
    
    DCObjectMapping *expirationMapping = [DCObjectMapping mapKeyPath:@"vip_ended_at" toAttribute:@"expiration" onClass:self];
    [config addObjectMapping:expirationMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

- (NSString *)expirationText {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_expiration.doubleValue / 1000]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeInteger:self.point forKey:@"point"];
    [aCoder encodeInteger:self.exp forKey:@"exp"];
    [aCoder encodeInteger:self.rank forKey:@"rank"];
    [aCoder encodeInteger:self.level forKey:@"level"];
    [aCoder encodeObject:self.expiration forKey:@"expiration"];
    [aCoder encodeBool:self.vip forKey:@"vip"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.point = [aDecoder decodeIntegerForKey:@"point"];
        self.exp = [aDecoder decodeIntegerForKey:@"exp"];
        self.rank = [aDecoder decodeIntegerForKey:@"rank"];
        self.level = [aDecoder decodeIntegerForKey:@"level"];
        self.expiration = [aDecoder decodeObjectForKey:@"expiration"];
        self.vip = [aDecoder decodeBoolForKey:@"vip"];
    }
    
    return self;
}

@end
