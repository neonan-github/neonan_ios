//
//  ResponseError.m
//  Neonan
//
//  Created by capricorn on 12-11-2.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ResponseError.h"

@implementation ResponseError

+ (id<Jsonable>)parse:(NSDictionary *)JSON {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *codeToErrorCode = [DCObjectMapping mapKeyPath:@"code" toAttribute:@"errorCode" onClass:self];
    
    [config addObjectMapping:codeToErrorCode];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:self andConfiguration:config];
    return [parser parseDictionary:JSON];
}

- (id)initWithCode:(NSInteger)code andMessage:(NSString *)message {
    if ((self = [super init]))
    {
        self.errorCode = code;
        self.message = message;
    }
    return self;
}

- (NSString *)message {
    if (_errorCode > 0) {
        return NSLocalizedString(_message,);
    }
    
    return _message;
}

@end
