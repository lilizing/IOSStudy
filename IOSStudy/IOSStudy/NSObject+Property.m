//
//  NSObject+Property.m
//  IOSStudy
//
//  Created by lili on 13-1-14.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "NSObject+Property.h"

@implementation NSObject (Property)
-(NSDictionary *)propertyDictionary
{
    //创建可变字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
    for(int i=0;i<outCount;i++){
        objc_property_t prop = props[i];
        NSString *propName = [[NSString alloc]initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
        id propValue = [self valueForKey:propName];
        if(propValue){
            [dict setObject:propValue forKey:propName];
        }
    }
    free(props);
    return dict;
}
@end
