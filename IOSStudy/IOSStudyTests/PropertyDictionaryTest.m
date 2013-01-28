//
//  PropertyDictionaryTest.m
//  IOSStudy
//
//  Created by lili on 13-1-14.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "PropertyDictionaryTest.h"

@implementation PropertyDictionaryTest
-(void)testPropDict{
    B *a = [[B alloc]init];
    a.age = 24;
    a.name = @"lili";
    NSDictionary *dict = [a propertyDictionary];
    DebugLog(@"属性字典：%@",dict);
}
@end

@implementation B
@end