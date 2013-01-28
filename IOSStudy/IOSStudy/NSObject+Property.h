//
//  NSObject+Property.h
//  IOSStudy
//
//  Created by lili on 13-1-14.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@interface NSObject (Property)
//将对象属性封装到字典，并返回字典
-(NSDictionary *)propertyDictionary;
@end
