//
//  PropertyDictionaryTest.h
//  IOSStudy
//
//  Created by lili on 13-1-14.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSObject+Property.h"
@class B;

@interface PropertyDictionaryTest : SenTestCase
-(void)testPropDict;
@end


@interface B : NSObject
@property(assign,nonatomic)int age;
@property(copy,nonatomic)NSString *name;
@end